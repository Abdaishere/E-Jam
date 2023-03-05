use std::sync::Mutex;

use chrono::{serde::ts_seconds, DateTime, Utc};
use serde::{Deserialize, Serialize};
use validator::Validate;

use super::{
    process::{ProcessStatus, ProcessType},
    IP_ADDRESS, MAC_ADDRESS,
};

#[doc = r"Device Model
A device is a computer that is connected to the system and can run a process either a verification process or a generation process or both
## Values
* `name` - A string that represents the name of the device (used for identification and clarification) the name must be greater than 0 characters long if it is not provided the default value is the ip address of the device
* `description` - A string that represents the description of the device (used for clarification)
* `location` - A string that represents the location of the device (used for clarification)
* `last_updated` - A DateTime that represents the last time the device status was updated (used for clarification)
* `ip_address` - A string that represents the ip address of the device (used for Communication) IP_ADDRESS is a regex that is used to validate the ip address
* `port` - A u16 that represents the port number of the device (used for Communication) the port number must be between 1 and 65535
* `gen_processes` - A u16 that represents the number of generation processes that are running on the device
* `ver_processes` - A u16 that represents the number of verification processes that are running on the device
* `status` - A DeviceStatus that represents the status of the device (Offline, Idle, Running)
* `mac_address` - A string that represents the mac address of the device (used for authentication) MAC_ADDRESS is a regex that is used to validate the mac address
## DeviceStatus
* `Offline` - the device is offline (not connected to the system)
* `Idle` - the device is idle (connected to the system but not running any process)
* `Running` - the device is running (connected to the system and running at least one process)"]
#[derive(Serialize, Deserialize, Validate, Debug, Clone)]
pub struct Device {
    #[validate(length(
        min = 1,
        max = 50,
        message = "name must be between 1 and 50 characters long"
    ))]
    #[serde(default, rename = "name")]
    name: String,

    #[validate(length(
        min = 1,
        max = 255,
        message = "description must be between 1 and 255 characters long"
    ))]
    #[serde(default, rename = "description")]
    description: String,

    #[validate(length(
        min = 1,
        max = 255,
        message = "location must be between 1 and 255 characters long"
    ))]
    location: String,

    #[serde(with = "ts_seconds")]
    last_updated: DateTime<Utc>,

    #[validate(
        regex(path = "IP_ADDRESS", message = "ip must be a valid ip address"),
        length(
            min = 7,
            max = 15,
            message = "ip must be between 7 and 15 characters long"
        )
    )]
    #[serde(rename = "ip")]
    ip_address: String,
    #[validate(range(
        min = 1,
        max = 65535,
        message = "port number must be between 1 and 65535"
    ))]
    port: u16,

    #[validate(
        regex(
            path = "MAC_ADDRESS",
            message = "mac_address must be a valid mac address"
        ),
        length(equal = 17, message = "mac_address must be 17 characters long")
    )]
    #[serde(rename = "mac")]
    mac_address: String,

    #[serde(default, skip_deserializing)]
    gen_processes: u16,

    #[serde(default, skip_deserializing)]
    ver_processes: u16,

    #[serde(rename = "status", skip_deserializing, default)]
    status: DeviceStatus,
}

#[doc = r"Device implementation"]
impl Device {
    #[doc = r"update the device status
this function is used to update the device status according to the status of the process that is running on the device
# Arguments
* `ip` - A string that represents the ip address of the device
* `status` - A ProcessStatus that represents the status of the process that is running on the device
* `type_of_process` - A ProcessType that represents the type of the process that is running on the device
* `DEVICE_LIST` - A Mutex<Vec<Device>> that represents the list of devices that are added to the system
## Panics
* `Error: Failed to Change the device status` - if the mutex is locked
* `Error: Device not found {}` - if the device is not found in the list of devices"]
    pub fn update_device_status(
        device_mac: &String,
        status: &ProcessStatus,
        type_of_process: &ProcessType,
        device_list: &Mutex<Vec<Device>>,
    ) {
        // TODO: Recheck the logic of this function
        let mut devices = device_list
            .lock()
            .expect("Error: Failed to Change the device status");

        let index = devices.iter().position(|x| &x.mac_address == device_mac);

        // if the device is not found then panic
        let index = match index {
            Some(index) => index,
            None => panic!("Error: Device not found {}", device_mac),
        };

        // update the number of processes that are running on the device
        if type_of_process == &ProcessType::Generation {
            if status == &ProcessStatus::Queued {
                devices[index].gen_processes += 1;
            } else if status == &ProcessStatus::Completed {
                devices[index].gen_processes -= 1;
            }
        } else {
            if status == &ProcessStatus::Queued {
                devices[index].ver_processes += 1;
            } else if status == &ProcessStatus::Completed {
                devices[index].ver_processes -= 1;
            }
        }

        // update the status of the device according to the number of processes that are running on the device
        // The device is offline if the status of the process is failed (the process failed to start)
        if devices[index].gen_processes == 0 && devices[index].ver_processes == 0 {
            if status == &ProcessStatus::Failed {
                devices[index].status = DeviceStatus::Offline;
            } else {
                devices[index].status = DeviceStatus::Online;
            }
        } else if devices[index].gen_processes > 0 || devices[index].ver_processes > 0 {
            if status == &ProcessStatus::Failed {
                devices[index].status = DeviceStatus::Offline;
            } else {
                if status == &ProcessStatus::Running {
                    devices[index].status = DeviceStatus::Running;
                } else if status == &ProcessStatus::Queued {
                    devices[index].status = DeviceStatus::Idle;
                } else if status == &ProcessStatus::Completed {
                    devices[index].status = DeviceStatus::Online;
                }
            }
        } else {
            // if for some reason the number of processes is less than 0 then set the status of the device to offline
            devices[index].status = DeviceStatus::Offline;
        }
    }

    #[doc = r"Find the device by name, ip address or mac address and return the device if found else return None
this is used to find the device by ip first then by mac address and then by name if the ip address or mac address is not known
this is done to make sure that the device is found even if the user enters the wrong ip address or mac address OR if the user can find the device by name if you want to add name refrence to the device
this is also done to mimic the behaviour of another device by changing the name of the device to the ip address of the other device if the device does not exist in the list of devices
# Arguments
* `name` - the name of the device
* `device_list` - the list of devices that are added to the system
# Returns
* `Option<Device>` - the device if found else None
# Panics
* `Error: Failed to find the device` - if the device list is locked"]
    pub fn find_device(name: &str, device_list: &Mutex<Vec<Device>>) -> Option<Device> {
        let device_list = device_list
            .lock()
            .expect("Error: Failed to find the device");

        // find in all mac addresses
        for device in device_list.iter() {
            if device.mac_address == name {
                return Some(device.clone());
            }
        }

        // find in all ip addresses
        for device in device_list.iter() {
            if device.ip_address == name {
                return Some(device.clone());
            }
        }

        // find in all names
        for device in device_list.iter() {
            if device.name == name {
                return Some(device.clone());
            }
        }

        None
    }

    #[doc = r"Get the device MAC address
this is used to get the device MAC address
# Returns
* `String` - the device MAC address with Regex for MAC address"]
    pub fn get_device_mac(&self) -> String {
        self.mac_address.clone()
    }

    #[doc = r"Get the device IP address
this is used to get the device IP address
# Returns
* `String` - the device IP address with Regex for IP address"]
    pub fn get_ip_address(&self) -> String {
        self.ip_address.clone()
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
            self.get_ip_address(),
            self.get_port(),
            self.get_device_mac(),
        )
    }

    #[doc = r"Implment Is readchable for the device
this is used to set the device to reachable or unreachable
# Arguments
* `reachable` - A Boolean the reachable status of the device"]
    pub fn set_is_reachable(&mut self, reachable: bool) {
        self.status = if reachable {
            DeviceStatus::Online
        } else {
            DeviceStatus::Offline
        };
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
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(tag = "devicestatus")]
pub enum DeviceStatus {
    #[serde(rename = "Online")]
    Online,
    #[default]
    #[serde(rename = "Offline")]
    Offline,
    #[serde(rename = "Running")]
    Running,
    #[serde(rename = "Idle")]
    Idle,
}

#[doc = r"## Get Devices Table
This is used to get the devices html table in the form of a string that can be used to display in the web interface
# Arguments
* `DEVICE_LIST` - the list of devices that are added to the system"]
pub fn get_devices_table(device_list: &Mutex<Vec<Device>>) -> String {
    let device_list = device_list
        .lock()
        .expect("Error: Failed to lock the device list");

    let mut data = String::from(
        "<table>
    <tr>
        <th>Device name</th>
        <th>Device ip</th>
        <th>Device mac</th>
        <th>Device status</th>
        <th>Generation processes</th>
        <th>Verification processes</th>
    </tr>
    ",
    );
    for device in device_list.iter() {
        let row = format!(
            "<tr>
            <td>{}</td>
            <td>{}</td>
            <td>{}</td>
            <td>{:#?}</td>
            <td>{}</td>
            <td>{}</td>
        </tr>",
            &device.name,
            &device.ip_address,
            &device.mac_address,
            &device.status,
            &device.gen_processes,
            &device.ver_processes
        );
        data.push_str(&row);
    }
    data.push_str("</table>");
    data
}
