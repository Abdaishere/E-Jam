use chrono::{serde::ts_seconds, DateTime, Utc};
use log::{info, warn};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, time::Duration};
use tokio::{sync::Mutex, task::JoinHandle};
use validator::Validate;

use super::{
    process::{ProcessStatus, ProcessType},
    IP_ADDRESS, MAC_ADDRESS, RUNTIME,
};

#[doc = r" # Device Model
A device is a computer that is connected to the system and can run a process either a verification process or a generation process or both
## Values
- `Name` - A string that represents the name of the device (used for identification and clarification) the default value is the ip address of the device if it is not provided
- `Description` - A string that represents the description of the device (used for clarification)
- `Location` - A string that represents the location of the device (used for clarification)
- `Last Updated` - A DateTime that represents the last time the device status was updated (used for clarification)
- `Ip Address` - A string that represents the ip address of the device (used for Communication)
- `Port` - A number that represents the port number of the device (used for Communication)
- `Gen Processes` - A number that represents the number of generation processes that are running on the device (used for clarification)
- `Ver Processes` - A number that represents the number of verification processes that are running on the device (used for clarification)
- `Status` - A Device Status Enumerator that represents the status of the device (Offline, Idle, Running)
- `Mac address` - A string that represents the mac address of the device (used for authentication)
"]
#[derive(Serialize, Deserialize, Validate, Debug, Clone, PartialEq, Hash, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Device {
    #[doc = " ## Device Name
    A string that represents the name of the device (used for identification and clarification)
    ## Constraints
    * The name must be less than 50 characters long
    ## Default Value
    * The default value is the ip address of the device if it is not provided
    "]
    #[validate(length(
        min = 0,
        max = 50,
        message = "Name must be less than 50 characters long"
    ))]
    #[serde(default)]
    name: String,

    #[doc = " ## Device Description
    A string that represents the description of the device (used for clarification)
    ## Constraints
    * The description must be less than 255 characters long
    "]
    #[validate(length(
        min = 0,
        max = 255,
        message = "Description must be less than 255 characters long"
    ))]
    #[serde(default)]
    description: String,

    #[doc = " ## Device Location
    A string that represents the location of the device (used for clarification)
    ## Constraints
    * The location must be less than 50 characters long
    "]
    #[validate(length(
        min = 0,
        max = 50,
        message = "Location must be less than 50 characters long"
    ))]
    #[serde(default)]
    location: String,

    #[doc = " ## Device Last Updated
    A DateTime that represents the last time the device status was updated (used for clarification)
    ## Constraints
    * The last_updated must be a valid DateTime
    ## Default Value
    * The default value is the current DateTime
    "]
    #[serde(with = "ts_seconds", default = "Utc::now", skip_deserializing)]
    last_updated: DateTime<Utc>,

    #[doc = " ## Device IP Address
    A string that represents the ip address of the device (used for Communication)
    ## Constraints
    * The ip_address must be a valid ip address
    * The ip_address must be greater than 7 characters long
    * The ip_address must be less than 15 characters long
    * check the IP_ADDRESS regex for more information
    "]
    #[validate(
        regex(
            path = "IP_ADDRESS",
            message = "Device IP Address must be a valid ip address"
        ),
        length(
            min = 7,
            max = 15,
            message = "Device IP Address be between 7 and 15 characters long"
        )
    )]
    ip_address: String,

    #[doc = " ## Device Port Number
    A u16 that represents the port number of the device (used for Communication)
    ## Constraints
    * The port number must be between 1 and 65535
    "]
    #[validate(range(
        min = 1,
        max = 65535,
        message = "Device Port Number must be between 1 and 65535"
    ))]
    port: u16,

    #[doc = " ## Device MAC Address
    A string that represents the mac address of the device (used for authentication)
    ## Constraints
    * The MAC Address must be a valid mac address
    * The MAC Address must be 17 characters long
    "]
    #[validate(
        regex(
            path = "MAC_ADDRESS",
            message = "MAC Address must be a valid mac address"
        ),
        length(equal = 17, message = "Device MAC Address must be 17 characters long")
    )]
    mac_address: String,

    #[doc = " ## Device Generation Processes Number
    A u16 that represents the number of generation processes that are running on the device"]
    #[serde(default, skip_deserializing)]
    gen_processes: u64,

    #[doc = " ## Device Verification Processes Number
    A u16 that represents the number of verification processes that are running on the device"]
    #[serde(default, skip_deserializing)]
    ver_processes: u64,

    #[doc = " ## Device Status
    A Device Status Enum that represents the status of the device at any given time (Offline, Online, Idle, Running)
    ## see also
    The Device State Machine: ./docs/device_state_machine.png"]
    #[serde(default, skip_deserializing)]
    status: DeviceStatus,
}

impl Device {
    #[doc = r" ## Update The Device Status
this function is used to update the device status according to the status of the process that is running on the device
## Arguments
* `status` - The status of the process that is running on the device
* `type_of_process` - The type of the process that is running on the device
"]
    pub fn update_device_status(&mut self, status: &ProcessStatus, type_of_process: &ProcessType) {
        let prev_status = self.status.to_owned();

        // update the number of processes that are running on the device
        self.update_device_processes(status, type_of_process);

        // update the status of the device according to the number of processes that are running on the device
        // The device is offline if the status of the process is failed (the process failed to start)
        match self.gen_processes + self.ver_processes {
            0 => {
                self.status = if status == &ProcessStatus::Failed {
                    DeviceStatus::Offline
                } else {
                    DeviceStatus::Online
                }
            }
            d if d > 0 => {
                self.status = match status {
                    ProcessStatus::Running => DeviceStatus::Running,
                    ProcessStatus::Queued => DeviceStatus::Idle,
                    ProcessStatus::Failed => DeviceStatus::Offline,
                    _ => self.status.to_owned(),
                }
            }
            // if for some reason the number of processes is less than 0 then set the status of the device to offline (this should never happen)
            _ => self.status = DeviceStatus::Offline,
        }

        if prev_status != self.status {
            info!(
                "Device {} status changed from {} to {}",
                self.get_device_mac(),
                prev_status.to_string(),
                self.status.to_string()
            );
            self.last_updated = Utc::now();
        } else {
            info!(
                "Device {} notified status is {} since {}",
                self.get_device_mac(),
                &self.status.to_string(),
                self.last_updated.format("%Y-%m-%d %H:%M:%S")
            );
        }
    }

    fn update_device_processes(&mut self, status: &ProcessStatus, type_of_process: &ProcessType) {
        match type_of_process {
            ProcessType::Generation => match status {
                ProcessStatus::Queued => self.add_ver_processes(),
                ProcessStatus::Running => {}
                _ => self.remove_gen_process(),
            },
            ProcessType::Verification => match status {
                ProcessStatus::Queued => self.add_ver_processes(),
                ProcessStatus::Running => {}
                _ => self.remove_ver_processes(),
            },
            ProcessType::GeneratingAndVerification => match status {
                ProcessStatus::Queued => {
                    self.add_gen_process();
                    self.add_ver_processes();
                }
                ProcessStatus::Running => {}
                _ => {
                    self.remove_gen_process();
                    self.remove_ver_processes();
                }
            },
        }
    }

    pub fn add_gen_process(&mut self) {
        self.gen_processes += 1;
    }

    pub fn remove_gen_process(&mut self) {
        if self.gen_processes > 0 {
            self.gen_processes -= 1
        } else {
            warn!(
                "Device {} has no generation processes to remove",
                self.get_device_mac()
            );
        }
    }

    pub fn add_ver_processes(&mut self) {
        self.ver_processes += 1;
    }

    pub fn remove_ver_processes(&mut self) {
        if self.ver_processes > 0 {
            self.ver_processes -= 1
        } else {
            warn!(
                "Device {} has no verification processes to remove",
                self.get_device_mac()
            );
        }
    }

    #[doc = r" ## Find Device
Find the device by mac address, ip address or name and return the device if found else return None
## Note
this is used if the user wants to add a device to the system and the device is not in the list of devices but the user knows the ip address of the device or the name of the device.
this is also use to mimic the behavior of another device by changing the name of the device to the ip address of the other device if the device does not exist in the list of devices.
# Arguments
* `key` - The mac address, ip address or name of the device
* `device_list` - The list of devices that are currently in the system
# Returns
* `Option of Device` - the device if found else None"]
    pub async fn find_device(
        key: &str,
        device_list: &Mutex<HashMap<String, Device>>,
    ) -> Option<String> {
        // find in all mac addresses first then in all ip addresses then in all names
        let device_list = device_list.lock().await;

        if device_list.get(key).is_some() {
            return Some(key.to_string());
        }

        // iterate and find in all ip addresses
        for (device_key, device) in device_list.iter() {
            if device.ip_address == key {
                return Some(device_key.to_owned());
            }
        }

        // iterate and find in all names
        for (device_key, device) in device_list.iter() {
            if device.name == key {
                return Some(device_key.to_owned());
            }
        }

        None
    }

    pub fn get_device_mac(&self) -> &String {
        &self.mac_address
    }

    pub fn get_ip_address(&self) -> &String {
        &self.ip_address
    }

    pub fn get_port(&self) -> u16 {
        self.port
    }

    #[doc = r"## Get the Device Connection Address
this is used to get the device connection address in a tuple format (ip address, port, mac address)
# Returns
* `(String, u16, String)` - the device connection address Ip of the device host and port of the device host and the MAC address of the card used in testing"]
    pub fn get_device_info_tuple(&self) -> (String, u16, String) {
        (
            self.get_ip_address().to_owned(),
            self.get_port(),
            self.get_device_mac().to_owned(),
        )
    }

    #[doc = r"## Send Stream
this is used to send a stream to the device to start processing the stream and return the response from the device
this is awaited in another thread to not block the main thread
# Arguments
* `stream_id` - The id of the stream
* `stream_details` - The details of the stream
# Returns
* `JoinHandle of Result of Response, Error` - the response from the device or the error if the request failed"]
    pub fn send_stream(
        &self,
        stream_id: &String,
        stream_details: &String,
    ) -> JoinHandle<Result<reqwest::Response, reqwest::Error>> {
        let target = format!("http://{}:{}/start", self.get_ip_address(), self.get_port());
        let mac = self.get_device_mac().to_owned();
        let stream_id = stream_id.to_owned();
        let stream_details = stream_details.to_owned();
        RUNTIME.spawn(async {
            reqwest::Client::new()
                .post(target)
                .header("mac-address", mac)
                .header("stream-id", stream_id)
                .body(stream_details)
                .timeout(Duration::from_secs(2))
                .send()
                .await
        })
    }

    #[doc = r"## Stop Stream
this is used to stop a stream that is currently being processed by the device and return the response from the device
this is awaited in another thread to not block the main thread
# Arguments
* `stream_id` - The id of the stream
# Returns
* `JoinHandle of Result of Response, Error` - the response from the device or the error if the request failed"]
    pub fn stop_stream(
        &self,
        stream_id: &String,
    ) -> JoinHandle<Result<reqwest::Response, reqwest::Error>> {
        let target = format!("http://{}:{}/stop", self.get_ip_address(), self.get_port());
        let mac = self.get_device_mac().to_owned();
        let stream_id = stream_id.to_owned();
        RUNTIME.spawn(async {
            reqwest::Client::new()
                .post(target)
                .header("mac-address", mac)
                .header("stream-id", stream_id)
                .timeout(Duration::from_secs(2))
                .send()
                .await
        })
    }

    #[doc = r"## Set Reachable
this is used to set the device to reachable or unreachable and update the last updated time
# Arguments
* `is_online` - true if the device is reachable else false"]
    pub fn set_reachable(&mut self, is_online: bool) {
        if is_online {
            info!(
                "Device {} is reachable after being {} since {} UTC",
                self.get_device_mac(),
                &self.status.to_string(),
                self.last_updated
            );
        } else {
            info!(
                "Device {} is not reachable after being {} since {} UTC",
                self.get_device_mac(),
                &self.status.to_string(),
                self.last_updated
            );
        };
        self.status = if is_online {
            DeviceStatus::Online
        } else {
            DeviceStatus::Offline
        }
    }

    #[doc = r"## Ping Device
this is used to ping the device to check if it is reachable or not
this is awaited in another thread to not block the main thread
# Returns
* `JoinHandle of bool` - true if the device is reachable else false"]
    pub fn ping_device(&self) -> JoinHandle<bool> {
        let url = format!("http://{}:{}/connect", self.ip_address, self.port);
        let mac_address = self.mac_address.to_owned();

        RUNTIME.spawn(async {
            let request = reqwest::Client::new()
                .post(url)
                .header("mac-address", mac_address)
                .timeout(Duration::from_secs(5))
                .send();

            match request.await {
                Ok(request) => request.status().is_success(),
                Err(_) => false,
            }
        })
    }

    #[doc = r"## Update Device Details
this is used to update the device details with the new details
# Arguments
* `device` - The new device details"]
    pub fn update(&mut self, device: &Device) {
        self.name = device.name.to_owned();
        self.description = device.description.to_owned();
        self.location = device.location.to_owned();
        self.ip_address = device.ip_address.to_owned();
        self.port = device.port;
        self.last_updated = Utc::now();
    }

    #[cfg(feature = "fake_data")]
    pub async fn generate_fake_device() -> Device {
        use chrono::{prelude::*, Duration};
        use fake::{
            faker::address::en::CityName,
            faker::company::en::Buzzword,
            faker::internet::en::{MACAddress, UserAgent, Username, IP},
            Fake, Faker,
        };

        const WORDS: [&str; 20] = [
            "raspberry ",
            "pine64 ",
            "linux ",
            "linux ",
            "linux ",
            "printer ",
            "printer ",
            "router ",
            "firewall ",
            "switch ",
            "home ",
            "",
            "",
            "",
            "",
            "",
            "",
            "laptop ",
            "microsoft ",
            "hub ",
        ];

        const STATUSES: [DeviceStatus; 4] = [
            DeviceStatus::Online,
            DeviceStatus::Offline,
            DeviceStatus::Running,
            DeviceStatus::Idle,
        ];

        loop {
            let start_time = Utc::now() - Duration::days(365);
            let updates = start_time
                + Duration::seconds(
                    Faker
                        .fake::<i64>()
                        .rem_euclid((Utc::now() - start_time).num_seconds()),
                );

            let device = Device {
                name: format!(
                    "{} {}{}",
                    Buzzword().fake::<String>(),
                    WORDS[(0..WORDS.len()).fake::<usize>()],
                    Username().fake::<String>()
                ),
                description: UserAgent().fake::<String>(),
                location: CityName().fake::<String>(),
                mac_address: MACAddress().fake(),
                ip_address: IP().fake(),
                last_updated: updates,
                port: Faker.fake(),
                gen_processes: 0,
                ver_processes: 0,
                status: STATUSES[(0..4).fake::<usize>()].to_owned(),
            };

            match device.validate() {
                Ok(_) => return device,
                Err(e) => println!("Invalid device generated, trying again {}", e),
            }
        }
    }
}

#[doc = r"## DeviceStatus
This is used to represent the status of the device
## Variants
* `Online` - the device is online
* `Offline` - the device is offline
* `Running` - the device is running a process
* `Idle` - the device is idle
## Notes
* `Online` is the default value
* `Running` is used when the device is running a process
* `Idle` is used when the device is idle and not running any process
* `Offline` is used when the device is offline and unreachable, or failed to run a process"]
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq, Eq, Hash)]
#[serde(rename_all = "PascalCase")]
pub enum DeviceStatus {
    #[default]
    Online,
    Offline,
    Running,
    Idle,
}

impl ToString for DeviceStatus {
    fn to_string(&self) -> String {
        match self {
            DeviceStatus::Offline => "Offline".to_string(),
            DeviceStatus::Online => "Online".to_string(),
            DeviceStatus::Running => "Running".to_string(),
            DeviceStatus::Idle => "Idle".to_string(),
        }
    }
}

#[doc = r"## Get Devices Table
This is used to get the devices html table in the form of a string to be used in the index route
# Arguments
* `DEVICE_LIST` - the list of devices that are added to the system"]
pub fn get_devices_table(device_list: HashMap<String, Device>) -> String {
    let mut data = String::from(
        "| Device name | Device ip | Device mac | Device status | Generation processes | Verification processes |
        | --- | --- | --- | --- | --- | --- |
        
    ",
    );
    for device in device_list.values() {
        let row = format!(
            "| {} | {} | {} | {} | {} | {} |",
            &device.name,
            &device.ip_address,
            &device.mac_address,
            &device.status.to_string(),
            &device.gen_processes,
            &device.ver_processes
        );
        data.push_str(&row);
    }
    data
}
