use lazy_static::lazy_static;
use regex::Regex;
use reqwest::{header::HeaderName, StatusCode};
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use validator::Validate;

lazy_static! {
    static ref STREAM_ID_COUNTER: Mutex<u32> = Mutex::new(0); // stream id counter (3 alphanumeric characters)
    static ref STREAM_ID : Regex = Regex::new(r"^[a-zA-Z0-9]+$").unwrap(); // 3 alphanumeric characters
    static ref QUEUED_STREAMS : Mutex<Vec<String>> = Mutex::new(Vec::new()); // stream id, sleep
    static ref MAC_ADDRESS : Regex = Regex::new(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$").unwrap(); // mac address
    static ref IP_ADDRESS : Regex = Regex::new(r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$").unwrap(); // ip address
    pub static ref DEVICE_LIST : Mutex<Vec<Device>> =  Mutex::new(Vec::new()); // mac address, device name and ip address for all devices
}

pub struct AppState {
    pub streams_entries: Mutex<Vec<StreamEntry>>,
}

impl Default for AppState {
    fn default() -> Self {
        AppState {
            streams_entries: Mutex::new(Vec::new()),
        }
    }
}

#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone)]
pub struct StreamEntry {
    #[serde(default, rename = "delay")]
    #[validate(range(min = 0, message = "delay must be greater than 0"))]
    delay: u64,
    // max number for three alphanumeric characters is 46655 (36^3) so the max number of streams is 46655
    #[validate(
        length(equal = 3, message = "stream_id must be 3 characters long"),
        regex(path = "STREAM_ID", message = "stream_id must be alphanumeric")
    )]
    #[serde(rename = "id")]
    stream_id: String,
    #[validate(length(min = 1, message = "number_of_senders must be greater than 0"))]
    #[serde(rename = "generators")]
    generators_name: Vec<String>,
    #[validate(length(min = 1, message = "number_of_receivers must be greater than 0"))]
    #[serde(rename = "verifiers")]
    verifiers_name: Vec<String>,
    #[validate(range(min = 0, max = 2, message = "payload_type must be 0, 1 or 2"))]
    payload_type: u8,
    #[validate(range(min = 0, message = "number_of_packets must be greater than 0"))]
    number_of_packets: u32,
    #[validate(range(
        min = 0,
        max = 1500,
        message = "payload_length must be between 0 and 1500"
    ))]
    payload_length: u16,
    #[validate(range(min = 0, message = "seed must be greater than 0"))]
    #[serde(default)]
    seed: u32,
    #[validate(range(min = 0, message = "broadcast_frames must be greater than 0"))]
    broadcast_frames: u32,
    // time in ms
    #[validate(range(min = 0, message = "inter_frame_gap must be greater than 0"))]
    inter_frame_gap: u32,
    // time in ms
    #[validate(range(min = 0, message = "time_to_live must be greater than 0"))]
    time_to_live: u64,
    #[serde(default)]
    transport_layer_protocol: TransportLayerProtocol,
    #[serde(default)]
    flow_type: FlowType,
    #[serde(default)]
    check_content: bool,
    #[serde(default, rename = "running_devices")]
    running_devices: Vec<String>, // ip address of the devices that are running the stream
    #[serde(default, rename = "status")]
    stream_status: StreamStatus,
}

impl StreamEntry {
    pub fn generate_new_stream_id(&mut self) {
        let mut stream_id_counter = STREAM_ID_COUNTER.lock().unwrap();
        if (*stream_id_counter) > 46655 {
            *stream_id_counter = 0;
        }
        let stream_id = char::from_digit(*stream_id_counter / 36 / 36, 36)
            .unwrap()
            .to_uppercase()
            .to_string()
            + &char::from_digit((*stream_id_counter / 36) % 36, 36)
                .unwrap()
                .to_uppercase()
                .to_string()
            + &char::from_digit(*stream_id_counter % 36, 36)
                .unwrap()
                .to_uppercase()
                .to_string();
        *stream_id_counter += 1;
        self.stream_id = stream_id
    }

    pub fn get_delay(&self) -> &u64 {
        &self.delay
    }
    // start the stream by sending a start request to all the senders and receivers
    // this will force the stream to start immediately
    pub async fn send_stream(&mut self, delay: u64) -> Result<(), reqwest::Error> {
        // send the start request to all the senders and receivers
        // if the request is successful, add the device to the running devices list
        // if the request fails, set the device status to offline

        for name in &self.verifiers_name {
            let receiver = Device::find_device(name);
            if receiver.is_none() {
                println!("Device not found: {}, skipping", name);
                continue;
            }
            let mut receiver = receiver.unwrap();
            let response = reqwest::Client::new()
                .post(&format!("http://{}/verify", &receiver.get_device_address()))
                // send the stream details as a json
                .body(serde_json::to_string(&self).unwrap())
                .header(HeaderName::from_static("Delay"), delay)
                .send()
                .await?;
            match response.status() {
                StatusCode::OK => {
                    receiver.status = DeviceStatus::Running;
                    self.running_devices.push(receiver.get_device_address());
                }
                _ => {
                    println!("Error: {}", response.text().await.unwrap());

                    // set the receiver status to offline (generic error)
                    receiver.status = DeviceStatus::Offline;
                }
            }
        }

        for name in &self.generators_name {
            let sender = Device::find_device(name);
            if sender.is_none() {
                println!("Device not found: {}, skipping", name);
                continue;
            }
            let mut sender = sender.unwrap();
            let response = reqwest::Client::new()
                .post(&format!("http://{}/generate", &sender.get_device_address()))
                .body(serde_json::to_string(&self).unwrap())
                .header(HeaderName::from_static("Delay"), delay)
                .send()
                .await?;
            match response.status() {
                StatusCode::OK => {
                    sender.status = DeviceStatus::Running;
                    self.running_devices.push(sender.get_device_address());
                }
                _ => {
                    println!("Error: {}", response.text().await.unwrap());

                    // set the receiver status to offline (generic error)
                    sender.status = DeviceStatus::Offline;
                }
            }
        }

        if self.running_devices.is_empty() {
            self.stream_status = StreamStatus::Error;
            println!("Error: No devices are running the stream")
        } else {
            self.stream_status = StreamStatus::Running;
            println!("Stream started")
        }

        Ok(())
    }

    pub fn start_stream(&mut self) {
        self.stream_status = StreamStatus::Running;
    }

    // force the stream to stop immediately
    // this is done by sending a stop request to all the senders and receivers with the stream id
    pub async fn stop_stream(&mut self, forced: u64) -> Result<(), reqwest::Error> {
        // send the stop reto all the senders and receivers with the stream id
        // if the request is successful, remove the device from the running devices list
        // if the request fails, set the device status to offline

        // stop the stream
        for name in &self.running_devices {
            let receiver = Device::find_device(name);
            if receiver.is_none() {
                println!("Device not found: {}, skipping", name);
                continue;
            }

            let mut receiver = receiver.unwrap();
            let response = reqwest::Client::new()
                .post(&format!("http://{}/stop", &receiver.get_device_address()))
                .body(self.get_stream_id().clone())
                .header(HeaderName::from_static("forced"), forced)
                .send()
                .await?;

            match response.status() {
                StatusCode::OK => {
                    receiver.processes -= 1;
                    if receiver.processes == 0 {
                        receiver.status = DeviceStatus::Idle;
                    }
                }
                _ => {
                    println!("Error: {}", response.text().await.unwrap());
                    // set the receiver status to offline (generic error)
                    receiver.status = DeviceStatus::Offline;
                }
            }
        }

        self.stream_status = StreamStatus::Stopped;
        self.running_devices.clear();

        Ok(())
    }

    // get the stream status
    // this is used to check if the stream is running or not
    // this is also used to check if the stream is queued or not
    pub fn get_stream_status(&self) -> &StreamStatus {
        &self.stream_status
    }

    // queue the stream to start at a later time
    // this will start the stream after the delay time this is used on a low reslution timer and can be implemented differently if needed (e.g. a high resolution timer)
    pub async fn queue_stream(&mut self) {
        // set the stream status to queued
        self.stream_status = StreamStatus::Queued;

        // set the start time
        print!("Stream queued to start in {} seconds", self.delay / 1000);

        self.send_stream(self.delay).await.unwrap();

        // add the thread to the queued streams list
        QUEUED_STREAMS
            .lock()
            .expect("Error: Failed to lock the queued streams list")
            .push(self.get_stream_id().clone());
    }

    // remove the stream from the queue
    // this will stop the stream from starting
    pub async fn remove_stream_from_queue(&mut self) {
        self.stream_status = StreamStatus::Stopped; // set the stream status to stopped

        // stop the stream
        let result = self.stop_stream(self.delay).await;

        if result.is_err() {
            println!("Error: {}", result.err().unwrap());
        }

        // remove the stream from the queued streams list
        let mut queue = QUEUED_STREAMS
            .lock()
            .expect("Error: Failed to lock the queued streams list");

        // remove the stream from the queued streams vector
        let index = queue.iter().position(|x| x == self.get_stream_id());
        if index.is_some() {
            queue.remove(index.unwrap());
        } else {
            println!("Error: Stream not found in the queued streams list!!!");
        }
    }

    pub fn get_stream_id(&self) -> &String {
        &self.stream_id
    }

    pub fn finish_stream(&mut self, device_address: &String) {
        // check if there are any devices left in the running streams list for this stream id
        // if there are no devices left, remove the stream from the running streams list and set the stream status to stopped
        // if there are devices left, set the stream status to finished and remove the device from the running streams list
        let mut device_list = DEVICE_LIST
            .lock()
            .expect("Error: Failed to lock the device list");

        let index = self
            .running_devices
            .iter()
            .position(|x| x.contains(device_address))
            .expect("Error: Device not found");

        self.running_devices.remove(index);

        if self.running_devices.len() == 0 {
            let device = device_list
                .iter()
                .position(|x| &x.ip_address == device_address)
                .expect("Error: Device not found");

            device_list[device].processes -= 1;
            if device_list[device].processes == 0 {
                device_list[device].status = DeviceStatus::Idle;
            }

            self.stream_status = StreamStatus::Stopped;
            return;
        }
        // get all the devices in the running streams list that are offline
        // if there are any devices in the running streams list that are offline, set the stream status to error
        // if there are no devices in the running streams list that are offline, set the stream status to finished
        let mut offline_devices = 0;
        for name in &self.running_devices {
            let device = Device::find_device(name).expect("Device not found");
            if device.status == DeviceStatus::Offline {
                offline_devices += 1;
            }
        }

        if offline_devices > 0 {
            self.stream_status = StreamStatus::Error;
            return;
        }

        self.stream_status = StreamStatus::Finished;
    }
}

#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(tag = "status")]
pub enum StreamStatus {
    #[default]
    #[serde(rename = "Created")]
    Created,
    #[serde(rename = "Stopped")]
    Stopped,
    #[serde(rename = "Running")]
    Running,
    #[serde(rename = "Finished")]
    Finished,
    #[serde(rename = "Queued")]
    Queued,
    #[serde(rename = "Error")]
    Error,
}

#[derive(Serialize, Deserialize, Default, Debug, Clone)]
#[serde(tag = "protocol")]
enum TransportLayerProtocol {
    #[default]
    #[serde(rename = "TCP")]
    TCP,
    #[serde(rename = "UDP")]
    UDP,
}

#[derive(Serialize, Deserialize, Default, Debug, Clone)]
#[serde(tag = "type")]
enum FlowType {
    #[default]
    #[serde(rename = "BtB")]
    BtB,
    #[serde(rename = "Bursts")]
    Bursts,
}

// Devices model
#[derive(Serialize, Deserialize, Validate, Debug, Clone)]
pub struct Device {
    // if name not given then use ip address as name
    #[validate(length(min = 1, message = "name must be greater than 0"))]
    #[serde(default, rename = "name")]
    pub name: String,
    #[validate(
        regex(path = "IP_ADDRESS", message = "ip must be a valid ip address"),
        length(
            min = 7,
            max = 15,
            message = "ip must be between 7 and 15 characters long"
        )
    )]
    #[serde(rename = "ip")]
    pub ip_address: String,
    #[validate(
        regex(
            path = "MAC_ADDRESS",
            message = "mac_address must be a valid mac address"
        ),
        length(equal = 17, message = "mac_address must be 17 characters long")
    )]
    #[serde(rename = "mac")]
    pub mac_address: String,
    // processes is the number of streams running on the device
    #[serde(default, skip_serializing)]
    pub processes: u16,
    #[serde(rename = "status", skip_serializing)]
    pub status: DeviceStatus,
}

// find the device either by name or ip or mac address
impl Device {
    pub fn find_device(name: &str) -> Option<Device> {
        // search for the device in the list of devices by iterating over the list of devices
        // the list of devices is known to be small so this is not a performance issue
        // this is method is used to find the device by ip first then by mac address and then by name
        // this is done to make sure that the device is found even if the user enters the wrong ip address or mac address
        // this is also done to make sure that the user can find the device by name if the ip address or mac address is not known

        let device_list = DEVICE_LIST
            .lock()
            .expect("Error: Failed to lock the device list");

        // find in all ip addresses
        for device in device_list.iter() {
            if device.ip_address == name {
                return Some(device.clone());
            }
        }

        // find in all mac addresses
        for device in device_list.iter() {
            if device.mac_address == name {
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

    pub fn get_device_address(&self) -> String {
        format!("{}:8080", self.ip_address.clone())
    }
}

// Device status
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(tag = "status")]
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

pub fn get_devices_table() -> String {
    let device_list = DEVICE_LIST
        .lock()
        .expect("Error: Failed to lock the device list");

    let mut data = String::from(
        "<table>
    <tr>
        <th>Device name</th>
        <th>Device ip</th>
        <th>Device mac</th>
        <th>Device status</th>
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
        </tr>",
            device.name, device.ip_address, device.mac_address, device.status, device.processes
        );
        data.push_str(&row);
    }
    data.push_str("</table>");
    data
}
