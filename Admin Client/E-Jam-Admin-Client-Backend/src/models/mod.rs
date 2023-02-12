use lazy_static::lazy_static;
use regex::Regex;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, sync::Mutex};
use tokio::time::{sleep, Duration, Sleep};
use validator::Validate;

lazy_static! {
    static ref STREAM_ID_COUNTER: Mutex<u32> = Mutex::new(0); // stream id counter (3 alphanumeric characters)
    static ref QUEUED_STREAMS : Mutex<HashMap<String , Sleep>> = Mutex::new(HashMap::new()); // stream id, sleep
    static ref RUNNING_STREAMS: Mutex<HashMap<String , Vec<String>>> = Mutex::new(HashMap::new()); // stream id, thread
    static ref STREAM_ID : Regex = Regex::new(r"^[a-zA-Z0-9]+$").unwrap(); // 3 alphanumeric characters
    static ref MAC_ADDRESS : Regex = Regex::new(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$").unwrap(); // mac address
    static ref IP_ADDRESS : Regex = Regex::new(r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$").unwrap(); // ip address
}

pub struct AppState {
    pub streams_entries: Mutex<Vec<StreamEntry>>,
    pub device_list: Mutex<Vec<Device>>, // mac address, device name for all devices by name
}

impl Default for AppState {
    fn default() -> Self {
        AppState {
            streams_entries: Mutex::new(Vec::new()),
            device_list: Mutex::new(Vec::new()),
        }
    }
}

// Stream ID (3 alphanumeric characters)
// number of senders		(n)
// sender 1 mac
// sender 2 mac
// ...
// sender n mac
// number of receivers     (m)
// receiver 1 mac
// receiver 2 mac
// ...
// receiver m mac
// Payload Type			(0 or 1 or 2)
// numberOfPackets			(+ve int)
// payloadLength			(+ve int < 1500)
// seed
// broadcast frames		(after x regular frame send a broadcast, x = 0 to disable)
// inter-frame gap			(+ve int in ms)
// Time to live			(+ve int in ms)
// transport layer Protocol(0 TCP or 1 UDP)
// Flow type				(0 BtB or 1 Bursts)
// check content			(0 false or 1 true)

#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone)]
pub struct StreamEntry {
    // max number for three alphanumeric characters is 46655 (36^3) so the max number of streams is 46655
    #[validate(
        length(equal = 3, message = "stream_id must be 3 characters long"),
        regex(path = "STREAM_ID", message = "stream_id must be alphanumeric")
    )]
    stream_id: String,
    #[serde(default)]
    #[validate(range(min = 0, message = "stream_start_time must be greater than 0"))]
    stream_start_time: u64,
    #[validate(length(min = 1, message = "number_of_senders must be greater than 0"))]
    senders_name: Vec<String>,
    #[validate(length(min = 1, message = "number_of_receivers must be greater than 0"))]
    receivers_name: Vec<String>,
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
    seed: u32,
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
    #[serde(default)]
    stream_status: StreamStatus,
}

impl StreamEntry {
    // create a new stream entry
    // the stream id is generated automatically
    // the stream status is set to "created"
    // Default values:
    // the delay is set to 0
    // the transport layer protocol is set to TCP
    // the flow type is set to BtB
    // the check content is set to false
    /*
    pub fn new() -> Self {
        let mut stream_entry = StreamEntry::default();
        // calculate the next stream id
        let mut stream_id_counter = STREAM_ID_COUNTER.lock().unwrap();
        stream_entry.stream_id = format!("{:03}", *stream_id_counter);
        *stream_id_counter += 1;
        stream_entry
    }
    */

    // create a new stream entry from a json string
    pub fn to_string(&self, device_list: &Vec<Device>) -> String {
        let mut stream_entry_string = String::new();

        stream_entry_string.push_str(&format!("Stream ID: {}\n ", self.stream_id));

        stream_entry_string.push_str(&format!("Senders: {}\n ", self.senders_name.len()));
        for name in &self.senders_name {
            stream_entry_string.push_str(&format!(
                "Sender MAC: {}\n ",
                Device::find_device(name, &device_list).unwrap().mac_address
            ));
        }

        stream_entry_string.push_str(&format!("Receivers: {}\n ", self.receivers_name.len()));
        for name in &self.receivers_name {
            stream_entry_string.push_str(&format!(
                "Receiver MAC: {}\n ",
                Device::find_device(name, &device_list).unwrap().mac_address
            ));
        }

        stream_entry_string.push_str(&format!("Payload Type: {}\n ", self.payload_type));
        stream_entry_string.push_str(&format!("Number of Packets: {}\n ", self.number_of_packets));
        stream_entry_string.push_str(&format!("Payload Length: {}\n ", self.payload_length));
        stream_entry_string.push_str(&format!("Seed: {}\n ", self.seed));
        stream_entry_string.push_str(&format!("Broadcast Frames: {}\n ", self.broadcast_frames));
        stream_entry_string.push_str(&format!("Inter Frame Gap: {}\n ", self.inter_frame_gap));
        stream_entry_string.push_str(&format!("Time to Live: {}\n ", self.time_to_live));
        stream_entry_string.push_str(&format!(
            "Transport Layer Protocol: {}\n ",
            self.transport_layer_protocol.to_string()
        ));
        stream_entry_string.push_str(&format!("Flow Type: {}\n ", self.flow_type.to_string()));
        stream_entry_string.push_str(&format!("Check Content: {}\n ", self.check_content));

        stream_entry_string
    }

    // start the stream by sending a start request to all the senders and receivers
    // this will force the stream to start immediately
    pub async fn send_stream(&self, device_list: &Vec<Device>) -> Result<(), reqwest::Error> {
        // add the stream to the list of running streams
        let mut running_streams = RUNNING_STREAMS.lock().unwrap();
        running_streams.insert(self.stream_id.clone(), Vec::new());

        let device = running_streams.get_mut(&self.stream_id).unwrap();

        for name in &self.receivers_name {
            let mut receiver = Device::find_device(name, &device_list).unwrap();
            let response = reqwest::Client::new()
                .post(&format!("http://{}/start", &receiver.get_device_address()))
                .body(self.to_string(&device_list))
                .send()
                .await?;
            match response.status() {
                StatusCode::OK => {
                    receiver.status = DeviceStatus::Running;
                    device.push(receiver.get_device_address());
                }
                _ => {
                    println!("Error: {}", response.text().await.unwrap());

                    // set the receiver status to offline (generic error)
                    receiver.status = DeviceStatus::Offline;
                }
            }
        }

        for name in &self.senders_name {
            let mut sender = Device::find_device(name, &device_list).unwrap();
            let response = reqwest::Client::new()
                .post(&format!("http://{}/start", &sender.get_device_address()))
                .body(self.to_string(&device_list))
                .send()
                .await?;
            match response.status() {
                StatusCode::OK => {
                    sender.status = DeviceStatus::Running;
                    device.push(sender.get_device_address());
                }
                _ => {
                    println!("Error: {}", response.text().await.unwrap());

                    // set the receiver status to offline (generic error)
                    sender.status = DeviceStatus::Offline;
                }
            }
        }

        if device.is_empty() {
            running_streams.remove(&self.stream_id);
        }
        Ok(())
    }

    pub fn run_stream(&mut self) {
        self.stream_status = StreamStatus::Running;
        // add the stream to the list of running streams
        let _time = sleep(Duration::from_millis(self.time_to_live));

        // wait for the stream to finish
        self.stream_status = StreamStatus::Stopped;
    }

    // force the stream to stop immediately
    // this is done by sending a stop request to all the senders and receivers with the stream id
    pub async fn stop_stream(&mut self, device_list: &Vec<Device>) -> Result<(), reqwest::Error> {
        // add the stream to the list of running streams
        let running_streams = RUNNING_STREAMS.lock().unwrap();
        let devices = running_streams
            .get(&self.get_stream_id().to_string())
            .unwrap()
            .clone();

        // stop the stream
        for name in &devices {
            let mut receiver = Device::find_device(name, &device_list).unwrap();
            let response = reqwest::Client::new()
                .post(&format!("http://{}/stop", &receiver.get_device_address()))
                .body(self.get_stream_id().clone())
                .send()
                .await?;

            match response.status() {
                StatusCode::OK => {
                    receiver.running_streams -= 1;
                    if receiver.running_streams == 0 {
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
        let mut running_streams = RUNNING_STREAMS.lock().unwrap();
        running_streams.remove(&self.get_stream_id().clone());

        Ok(())
    }

    // get the stream status
    // this is used to check if the stream is running or not
    // this is also used to check if the stream is queued or not
    pub fn get_stream_status(&self) -> &StreamStatus {
        &self.stream_status
    }

    // queue the stream to start at a later time
    // this will start the stream after the delay time
    pub async fn queue_stream(&mut self) {
        self.stream_status = StreamStatus::Queued;

        // wait for the start time
        let mut queue_stream = QUEUED_STREAMS.lock().unwrap();
        let timer = sleep(Duration::from_millis(self.stream_start_time));
        queue_stream.insert(self.get_stream_id().clone(), timer);

        // start the stream after the delay time if the stream is still queued
        if self.stream_status == StreamStatus::Queued {
            self.stream_status = StreamStatus::Running;

            // call the run stream function
            self.run_stream();
        }
    }

    // remove the stream from the queue
    // this will stop the stream from starting
    pub async fn remove_stream_from_queue(&mut self) {
        self.stream_status = StreamStatus::Stopped; // set the stream status to stopped

        // abort the queued thread
        let mut queue_stream = QUEUED_STREAMS.lock().unwrap();
        queue_stream.remove(&self.get_stream_id().clone());
    }

    pub fn get_stream_id(&self) -> &String {
        &self.stream_id
    }

    pub fn finish_stream(&mut self, device_address: &String, device_list: &mut Vec<Device>) {
        // check if there are any devices left in the running streams list for this stream id
        // if there are no devices left, remove the stream from the running streams list and set the stream status to stopped
        // if there are devices left, set the stream status to finished and remove the device from the running streams list

        let mut running_streams = RUNNING_STREAMS.lock().unwrap();
        let devices = running_streams
            .get_mut(&self.get_stream_id().to_string())
            .unwrap();

        let index = devices
            .iter()
            .position(|x| x.contains(device_address))
            .unwrap();

        devices.remove(index);

        if devices.len() == 0 {
            running_streams.remove(&self.get_stream_id().clone());

            let device = device_list
                .iter()
                .position(|x| &x.ip_address == device_address)
                .unwrap();
            
            device_list[device].running_streams -= 1;
            if device_list[device].running_streams == 0 {
                device_list[device].status = DeviceStatus::Idle;
            }

            self.stream_status = StreamStatus::Stopped;
            return;
        }

        self.stream_status = StreamStatus::Finished;
    }
}

#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(tag = "type")]
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
}

#[derive(Serialize, Deserialize, Default, Debug, Clone)]
#[serde(tag = "type")]
enum TransportLayerProtocol {
    #[default]
    #[serde(rename = "TCP")]
    TCP,
    #[serde(rename = "UDP")]
    UDP,
}

impl TransportLayerProtocol {
    fn to_string(&self) -> String {
        match self {
            TransportLayerProtocol::TCP => "TCP".to_string(),
            TransportLayerProtocol::UDP => "UDP".to_string(),
        }
    }
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

impl FlowType {
    fn to_string(&self) -> String {
        match self {
            FlowType::BtB => "BtB".to_string(),
            FlowType::Bursts => "Bursts".to_string(),
        }
    }
}

// Devices model
#[derive(Serialize, Deserialize, Validate, Debug, Clone)]
pub struct Device {
    // if name not given then use ip address as name
    #[validate(length(min = 1, message = "name must be greater than 0"))]
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
    #[serde(default, skip_serializing)]
    pub running_streams: u16,
    #[serde(rename = "status", skip_serializing)]
    pub status: DeviceStatus,
}

// find the device either by name or ip or mac address
impl Device {
    pub fn find_device(name: &str, device_list: &Vec<Device>) -> Option<Device> {
        // search for the device in the list of devices by iterating over the list of devices
        // the list of devices is known to be small so this is not a performance issue
        // this is method is used to find the device by ip first then by mac address and then by name
        // this is done to make sure that the device is found even if the user enters the wrong ip address or mac address
        // this is also done to make sure that the user can find the device by name if the ip address or mac address is not known

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
#[serde(tag = "type")]
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

// device status to string
impl DeviceStatus {
    fn to_string(&self) -> String {
        match self {
            DeviceStatus::Online => "Online".to_string(),
            DeviceStatus::Offline => "Offline".to_string(),
            DeviceStatus::Running => "Running".to_string(),
            DeviceStatus::Idle => "Idle".to_string(),
        }
    }
}



pub fn get_devices_table(device_list: &Vec<Device>) -> String {
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
            <td>{}</td>
            <td>{}</td>
        </tr>",
            device.name,
            device.ip_address,
            device.mac_address,
            device.status.to_string(),
            device.running_streams
        );
        data.push_str(&row);
    }
    data.push_str("</table>");
    data
}
