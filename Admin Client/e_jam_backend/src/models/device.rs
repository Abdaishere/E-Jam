use chrono::{serde::ts_seconds, DateTime, Utc};
use log::info;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, time::Duration};
use tokio::{sync::Mutex, task::JoinHandle};
use validator::Validate;

use super::{
    process::{ProcessStatus, ProcessType},
    stream_details::StreamDetails,
    IP_ADDRESS, MAC_ADDRESS,
};

#[doc = r"Device Model
A device is a computer that is connected to the system and can run a process either a verification process or a generation process or both
## Values

- `name` - A string that represents the name of the device (used for identification and clarification) the name must be greater than 0 characters long if it is not provided the default value is the ip address of the device
- `description` - A string that represents the description of the device (used for clarification)
- `location` - A string that represents the location of the device (used for clarification)
- `last_updated` - A DateTime that represents the last time the device status was updated (used for clarification)
- `ip_address` - A string that represents the ip address of the device (used for Communication) IP_ADDRESS is a regex that is used to validate the ip address
- `port` - A u16 that represents the port number of the device (used for Communication) the port number must be between 1 and 65535
- `gen_processes` - A u16 that represents the number of generation processes that are running on the device
- `ver_processes` - A u16 that represents the number of verification processes that are running on the device
- `status` - A DeviceStatus that represents the status of the device (Offline, Idle, Running)
- `mac_address` - A string that represents the mac address of the device (used for authentication) MAC_ADDRESS is a regex that is used to validate the mac address
"]
#[derive(Serialize, Deserialize, Validate, Debug, Clone, PartialEq, Hash, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Device {
    #[doc = " ## Device Name
    A string that represents the name of the device (used for identification and clarification)
    ## Constraints
    * The name must be greater than 0 characters long
    * The name must be less than 50 characters long
    ## Default Value
    * The default value is the ip address of the device
    "]
    #[validate(length(
        min = 0,
        max = 50,
        message = "name must be between 1 and 50 characters long"
    ))]
    #[serde(default)]
    name: String,

    #[doc = " ## Device Description
    A string that represents the description of the device (used for clarification)
    ## Constraints
    * The description must be greater than 0 characters long
    * The description must be less than 255 characters long
    ## Default Value
    * The default value is an empty string
    "]
    #[validate(length(
        min = 0,
        max = 255,
        message = "description must be between 1 and 255 characters long"
    ))]
    #[serde(default)]
    description: String,

    #[doc = " ## Device Location
    A string that represents the location of the device (used for clarification)
    ## Constraints
    * The location must be greater than 0 characters long
    * The location must be less than 255 characters long
    ## Default Value
    * The default value is an empty string
    "]
    #[validate(length(
        min = 0,
        max = 255,
        message = "location must be between 1 and 255 characters long"
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
        regex(path = "IP_ADDRESS", message = "ip must be a valid ip address"),
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
    * The mac_address must be a valid mac address
    * The mac_address must be 17 characters long
    "]
    #[validate(
        regex(
            path = "MAC_ADDRESS",
            message = "mac_address must be a valid mac address"
        ),
        length(equal = 17, message = "Device MAC Address must be 17 characters long")
    )]
    mac_address: String,

    #[doc = " ## Device Generation Processes Number
    A u16 that represents the number of generation processes that are running on the device"]
    #[serde(default, skip_deserializing)]
    gen_processes: u16,

    #[doc = " ## Device Verification Processes Number
    A u16 that represents the number of verification processes that are running on the device"]
    #[serde(default)]
    ver_processes: u16,

    #[doc = " ## Device Status
    A DeviceStatus that represents the status of the device at any given time (Offline, Online, Idle, Running)
    ## see also
    The Device State Machine: ./docs/device_state_machine.png"]
    #[serde(default, skip_deserializing)]
    status: DeviceStatus,
}

#[doc = r" This is the implementation of the Device Model used to handle the device data and its functions and services"]
impl Device {
    #[doc = r"update the device status
this function is used to update the device status according to the status of the process that is running on the device
# Arguments
* `ip` - A string that represents the ip address of the device
* `status` - A ProcessStatus that represents the status of the process that is running on the device
* `type_of_process` - A ProcessType that represents the type of the process that is running on the device
* `DEVICE_LIST` - A Mutex for a Vec of Devices that represents the list of devices that are added to the system
## Panics
* `Error: Failed to Change the device status` - if the mutex is locked
* `Error: Device not found {}` - if the device is not found in the list of devices"]
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
            // if for some reason the number of processes is less than 0 then set the status of the device to offline
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
        };
    }

    pub fn add_ver_processes(&mut self) {
        self.ver_processes += 1;
    }

    pub fn remove_ver_processes(&mut self) {
        if self.ver_processes > 0 {
            self.ver_processes -= 1
        };
    }

    #[doc = r"Find the device by name, ip address or mac address and return the device if found else return None
this is used to find the device by ip first then by mac address and then by name if the ip address or mac address is not known
this is done to make sure that the device is found even if the user enters the wrong ip address or mac address OR if the user can find the device by name if you want to add name reference to the device
this is also done to mimic the behavior of another device by changing the name of the device to the ip address of the other device if the device does not exist in the list of devices
# Arguments
* `name` - the name of the device
* `device_list` - the list of devices that are added to the system
# Returns
* `Option of Device` - the device if found else None
# Panics
* `Error: Failed to find the device` - if the device list is locked"]
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

    #[doc = r"Get the device MAC address
this is used to get the device MAC address
# Returns
* `String` - the device MAC address with Regex for MAC address"]
    pub fn get_device_mac(&self) -> &String {
        &self.mac_address
    }

    #[doc = r"Get the device IP address
this is used to get the device IP address
# Returns
* `String` - the device IP address with Regex for IP address"]
    pub fn get_ip_address(&self) -> &String {
        &self.ip_address
    }

    #[doc = r"Get the device port
this is used to get the device port
# Returns
* `u16` - the device port"]
    pub fn get_port(&self) -> u16 {
        self.port
    }

    #[doc = r"Get the Device Connection Address
this is used to get the device connection address
# Returns
* `(String, u16, String)` - the device connection address Ip of the device host and port of the device host and the MAC address of the card used in testing"]
    pub fn get_device_info_tuple(&self) -> (String, u16, String) {
        (
            self.get_ip_address().to_owned(),
            self.get_port(),
            self.get_device_mac().to_owned(),
        )
    }

    pub fn send_stream(
        &self,
        stream_details: StreamDetails,
    ) -> JoinHandle<Result<reqwest::Response, reqwest::Error>> {
        let target = format!("http://{}:{}/start", self.get_ip_address(), self.get_port());
        let mac = self.get_device_mac().to_owned();
        tokio::spawn(async move {
            reqwest::Client::new()
                .post(target)
                .header("mac-address", mac)
                .header("stream-id", stream_details.stream_id.to_owned())
                .body(
                    serde_json::to_string(&stream_details)
                        .expect("Failed to serialize stream details"),
                )
                .timeout(Duration::from_secs(2))
                .send()
                .await
        })
    }

    pub fn stop_stream(
        &self,
        stream_id: String,
    ) -> JoinHandle<Result<reqwest::Response, reqwest::Error>> {
        let mac = self.get_device_mac().to_owned();
        let target = format!("http://{}:{}/stop", self.get_ip_address(), self.get_port());
        tokio::spawn(async {
            reqwest::Client::new()
                .post(target)
                .header("mac-address", mac)
                .header("stream-id", stream_id)
                .timeout(Duration::from_secs(2))
                .send()
                .await
        })
    }

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

    #[doc = r"Implement Is reachable for the device
this is used to set the device to reachable or unreachable and update the last updated time
# Returns
* `bool` - true if the device is reachable else false
"]
    pub fn ping_device(&self) -> JoinHandle<bool> {
        let url = format!("http://{}:{}/connect", self.ip_address, self.port);
        let mac_address = self.mac_address.to_owned();

        tokio::spawn(async {
            let request = reqwest::Client::new()
                .post(url)
                .header("mac-address", mac_address)
                .timeout(Duration::from_secs(5))
                .send()
                .await;
            match request {
                Ok(request) => request.status().is_success(),
                Err(_) => false,
            }
        })
    }

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
* `Offline` is the default value
* `Online` is not used
* `Running` is used when the device is running a process
* `Idle` is used when the device is idle and not running any process
* `Offline` is used when the device is offline and unreachable"]
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq, Eq, Hash)]
#[serde(rename_all = "PascalCase")]
pub enum DeviceStatus {
    #[default]
    Offline,
    Online,
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
This is used to get the devices html table in the form of a string that can be used to display in the web interface
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
