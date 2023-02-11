use lazy_static::lazy_static;
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, sync::Mutex, thread};
use tokio::time::{sleep, Duration, Sleep};
use validator::Validate;

lazy_static! {
    static ref STREAM_ID_COUNTER: Mutex<u32> = Mutex::new(0); // stream id counter (3 alphanumeric characters)
    static ref DEVICE_LIST : Mutex<HashMap<MacAddress,String>> = Mutex::new(HashMap::new()); // mac address, device name
    static ref QUEUED_STREAMS : Mutex<HashMap<String , Sleep>> = Mutex::new(HashMap::new()); // stream id, sleep
    static ref RUNNING_STREAMS: Mutex<HashMap<String ,thread::JoinHandle<()>>> = Mutex::new(HashMap::new()); // stream id, thread
    static ref STREAM_ID : Regex = Regex::new(r"^[a-zA-Z0-9]+$").unwrap(); // 3 alphanumeric characters
    static ref MAC_ADDRESS : Regex = Regex::new(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$").unwrap(); // mac address
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
    #[validate(
        length(equal = 3, message = "stream_id must be 3 characters long"),
        regex(path = "STREAM_ID", message = "stream_id must be alphanumeric")
    )]
    stream_id: String,
    #[serde(default)]
    #[validate(range(min = 0, message = "stream_start_time must be greater than 0"))]
    stream_start_time: u64,
    #[validate(length(min = 1, message = "number_of_senders must be greater than 0"))]
    senders_mac: Vec<MacAddress>,
    #[validate(length(min = 1, message = "number_of_receivers must be greater than 0"))]
    receiver_macs: Vec<MacAddress>,
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
    pub fn to_string(&self) -> String {
        let mut stream_entry_string = String::new();
        stream_entry_string.push_str(&format!("Stream ID: {}\n ", self.stream_id));

        stream_entry_string.push_str(&format!("Senders: {}\n ", self.senders_mac.len()));
        for mac in &self.senders_mac {
            stream_entry_string.push_str(&format!("Sender MAC: {}\n ", mac.to_string()));
        }

        stream_entry_string.push_str(&format!("Receivers: {}\n ", self.receiver_macs.len()));
        for mac in &self.receiver_macs {
            stream_entry_string.push_str(&format!("Receiver MAC: {}\n ", mac.to_string()));
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
    pub async fn send_stream(&self) -> Result<(), reqwest::Error> {
        let devices = DEVICE_LIST.lock().unwrap();

        for mac in &self.receiver_macs {
            let receiver = devices.get(mac).unwrap();
            reqwest::Client::new()
                .post(&format!("http://{}:8080/start", receiver))
                .body(self.to_string())
                .send()
                .await?;
        }

        for mac in &self.senders_mac {
            let sender = devices.get(mac).unwrap();
            reqwest::Client::new()
                .post(&format!("http://{}:8080/start", sender))
                .body(self.to_string())
                .send()
                .await?;
        }

        // run the stream in another thread
        let mut stream = self.clone();
        let mut running_streams = RUNNING_STREAMS.lock().unwrap();
        running_streams.insert(
            self.get_stream_id().clone(),
            thread::spawn(move || {
                stream.run_stream();
            }),
        );

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
    pub async fn stop_stream(&mut self) -> Result<(), reqwest::Error> {
        let devices = DEVICE_LIST.lock().unwrap();

        // stop the stream
        for mac in &self.receiver_macs {
            let receiver = devices.get(mac).unwrap();
            reqwest::Client::new()
                .post(&format!("http://{}:8080/stop", receiver))
                .body(self.get_stream_id().clone())
                .send()
                .await?;
        }

        for mac in &self.senders_mac {
            let sender = devices.get(mac).unwrap();
            reqwest::Client::new()
                .post(&format!("http://{}:8080/stop", sender))
                .body(self.get_stream_id().clone())
                .send()
                .await?;
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

#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone, Eq, Hash, PartialEq)]
struct MacAddress {
    #[validate(regex(
        path = "MAC_ADDRESS",
        message = "mac_address must be a valid mac address"
    ))]
    mac_address: String,
}

impl MacAddress {
    pub fn to_string(&self) -> String {
        self.mac_address.clone()
    }
}
