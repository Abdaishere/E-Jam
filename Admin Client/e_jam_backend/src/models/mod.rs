pub(crate) mod device;
pub(crate) mod process;

use chrono::{serde::ts_seconds, DateTime, Utc};
use lazy_static::lazy_static;
use regex::Regex;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, sync::Mutex};
use validator::Validate;

use self::device::Device;
use self::process::{ProcessStatus, ProcessType};

lazy_static! {
    #[doc = r"Regex for the stream id that is used to identify the stream in the device must be alphanumeric max is 3 bytes (36^3 = 46656)"]
    static ref STREAM_ID : Regex = Regex::new(r"^[a-zA-Z0-9]+$").unwrap();

    #[doc = r"Regex for the mac address of the device's mac address"]
    static ref MAC_ADDRESS : Regex = Regex::new(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$").unwrap();

    #[doc = r"Regex for the ip address of the device's ip address"]
    static ref IP_ADDRESS : Regex = Regex::new(r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$").unwrap();
}

#[doc = r"The state of the Server that is shared between all the threads of the server
This is used to store the list of all the devices that are connected to the server and the list of all the streams and the list of all the streams that are currently Queued to be started on the devices
This is also used to store the counter for the stream id that is used to identify the stream in the device must be alphanumeric max is 3 bytes (36^3 = 46656)
## Values
* `streams_entries` - A Vec<StreamEntry> that represents the list of all the streams that are currently running on the devices
* `queued_streams` - A Vec<String> that represents the list of all the streams that are currently Queued to be started on the devices
* `device_list` - A Vec<Device> that represents the list of all the devices that are currently connected to the server (mac address, device name and ip address)
* `stream_id_counter` - A u32 that represents the counter for the stream id that is used to identify the stream in the device must be alphanumeric max is 3 bytes (36^3 = 46656)"]
pub struct AppState {
    pub streams_entries: Mutex<Vec<StreamEntry>>,

    #[doc = r"List of all the streams that are currently Queued to be started on the devices"]
    pub queued_streams: Mutex<Vec<String>>,

    #[doc = r"List of all the devices that are currently connected to the server (mac address, device name and ip address)"]
    pub device_list: Mutex<Vec<Device>>,

    #[doc = r"Counter for the stream id that is used to identify the stream in the device must be alphanumeric max is 3 bytes (36^3 = 46656)"]
    pub stream_id_counter: Mutex<u32>,
}

impl Default for AppState {
    fn default() -> Self {
        AppState {
            streams_entries: Mutex::new(Vec::new()),
            device_list: Mutex::new(Vec::new()),
            queued_streams: Mutex::new(Vec::new()),
            stream_id_counter: Mutex::new(0),
        }
    }
}

#[doc = r" # Stream Entry
The StreamEntry struct is used to store the information about the stream with its status and the status of the devices that are running the stream
## Values
* `name` - A String that represents the name of the stream (used for clarification)
* `description` - A String that represents the description of the stream (used for clarification)
* `last_updated` - A DateTime<Utc> that represents the last time that the stream was updated (used for clarification)
* `delay` - A u64 that represents the time in ms that the stream will wait before starting
* `stream_id` - A String that represents the id of the stream that is used to identify the stream in the device, must be alphanumeric, max is 3 bytes (36^3 = 46656)
* `generators_ids` - A Vec<String> that represents the ids of the devices that will generate the stream (priority of ID is in this order (LTR), mac, ip, name)
* `verifiers_ids` - A Vec<String> that represents the ids of the devices that will verify the stream (priority of ID is in this order (LTR), mac, ip, name)
* `payload_type` - A u8 that represents the type of the payload that will be used in the stream (0, 1, 2)
* `number_of_packets` - A u32 that represents the number of packets that will be sent in the stream
* `payload_length` - A u16 that represents the length of the payload that will be used in the stream
* `seed` - A u32 that represents the seed that will be used to generate the payload
* `broadcast_frames` - A u32 that represents the number of broadcast frames that will be sent in the stream
* `inter_frame_gap` - A u32 that represents the time in ms that will be waited between each frame
* `time_to_live` - A u64 that represents the time to live that will be used for the stream
* `transport_layer_protocol` - A TransportLayerProtocol that represents the transport layer protocol that will be used for the stream (TCP, UDP)
* `flow_type` - A FlowType that represents the flow type that will be used for the stream (BtB, Bursts)
* `check_content` - A bool that represents if the content of the packets will be checked
* `running_generators` - A HashMap<String, ProcessStatus> that represents the list of all the devices that are currently running the stream as a generator and their status (mac address of the card used in testing, Process Status) (used for clarification)
* `running_verifiers` - A HashMap<String, ProcessStatus> that represents the list of all the devices that are currently running the stream as a verifier and their status (mac address of the card used in testing, Process Status) (used for clarification)
* `stream_status` - A StreamStatus that represents the status of the stream.
"]
#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone)]
pub struct StreamEntry {
    #[validate(length(min = 1, message = "name must be given"))]
    #[serde(rename = "name")]
    name: String,

    #[validate(length(min = 1, message = "description must be given"))]
    #[serde(rename = "description")]
    description: String,

    // TODO: implement last_updated in all models and services
    #[serde(with = "ts_seconds")]
    #[serde(default, rename = "last_updated")]
    last_updated: DateTime<Utc>,

    #[serde(default, rename = "delay")]
    #[validate(range(min = 0, message = "delay must be greater than or equal to 0"))]
    delay: u64,

    #[validate(
        length(equal = 3, message = "stream_id must be 3 characters long"),
        regex(path = "STREAM_ID", message = "stream_id must be alphanumeric")
    )]
    #[serde(rename = "id")]
    stream_id: String,

    #[validate(length(min = 1, message = "number_of_senders must be greater than 0"))]
    #[serde(rename = "generators")]
    generators_ids: Vec<String>,

    #[validate(length(min = 1, message = "number_of_receivers must be greater than 0"))]
    #[serde(rename = "verifiers")]
    verifiers_ids: Vec<String>,

    #[validate(range(min = 0, max = 2, message = "payload_type must be 0, 1 or 2"))]
    payload_type: u8,

    #[validate(range(
        min = 0,
        message = "number_of_packets must be greater than or equal to 0"
    ))]
    number_of_packets: u32,

    #[validate(range(
        min = 0,
        max = 1500,
        message = "payload_length must be between 0 and 1500"
    ))]
    payload_length: u16,

    #[validate(range(min = 0, message = "seed must be greater than or equal to 0"))]
    #[serde(default)]
    seed: u32,

    #[validate(range(
        min = 0,
        message = "broadcast_frames must be greater than or equal to 0"
    ))]
    broadcast_frames: u32,

    #[validate(range(
        min = 0,
        message = "inter_frame_gap must be greater than or equal to 0"
    ))]
    inter_frame_gap: u32,

    #[validate(range(min = 0, message = "time_to_live must be greater than or equal to 0"))]
    time_to_live: u64,

    #[serde(default)]
    transport_layer_protocol: TransportLayerProtocol,

    #[serde(default)]
    flow_type: FlowType,

    #[serde(default)]
    check_content: bool,

    #[serde(default, rename = "running_generators")]
    running_generators: HashMap<String, ProcessStatus>,

    #[serde(default, rename = "running_verifiers")]
    running_verifiers: HashMap<String, ProcessStatus>,

    #[serde(default, rename = "status")]
    stream_status: StreamStatus,
}

#[doc = r"The StreamDetails struct is used to store the information about the stream that is sent to the device to start or queue the stream
## Values
* `stream_id` - A String that represents the id of the stream that is used to identify the stream in the device, must be alphanumeric, max is 3 bytes (36^3 = 46656)
* `delay` - A u64 that represents the time in ms that the stream will wait before starting
* `generators` - A Vec<String> that has all the mac addresses of the devices that will generate the stream
* `verifiers` - A Vec<String> that has all the mac addresses of the devices that will verify the stream
* `payload_type` - A u8 that represents the type of the payload that will be used in the stream (0, 1, 2)
* `number_of_packets` - A u32 that represents the number of packets that will be sent in the stream
* `payload_length` - A u16 that represents the length of the payload that will be used in the stream
* `seed` - A u32 that represents the seed that will be used to generate the payload
* `broadcast_frames` - A u32 that represents the number of broadcast frames that will be sent in the stream
* `inter_frame_gap` - A u32 that represents the time in ms that will be waited between each frame
* `time_to_live` - A u64 that represents the time to live that will be used for the stream
* `transport_layer_protocol` - A u8 that represents the transport layer protocol that will be used for the stream (0 = TCP, 1 = UDP)
* `flow_type` - A u8 that represents the flow type that will be used for the stream (0 = BtB, 1 = Bursts)
* `check_content` - A bool that represents if the content of the packets will be checked"]
#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone)]
struct StreamDetails {
    stream_id: String,
    delay: u64,
    generators: Vec<String>,
    verifiers: Vec<String>,
    payload_type: u8,
    number_of_packets: u32,
    payload_length: u16,
    seed: u32,
    broadcast_frames: u32,
    inter_frame_gap: u32,
    time_to_live: u64,
    transport_layer_protocol: u8,
    flow_type: u8,
    check_content: bool,
}

#[doc = r"Implementation of the StreamEntry struct that contains all the information about the stream and the functions that are used to manipulate the stream"]
impl StreamEntry {
    #[doc = r"The new function is used to create a new id for the stream
## Arguments
* `STREAM_ID_COUNTER` - A reference to a Mutex<u32> that is used to generate the id of the stream
## Returns
changes the stream_id of the stream to a new id"]
    pub fn generate_new_stream_id(&mut self, stream_id_counter: &Mutex<u32>) {
        let mut stream_id_counter = stream_id_counter.lock().unwrap();
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

    #[doc = r"# Notify Stream Running
The notify_stream_running function is used to update the stream status to Running and update the devices that are notifying the server that they have started the stream.
The Device notifies once if it was both a generator and verifier in the specified stream.
## Arguments
* `card_mac` - the mac address of the card used in testing and has Started
* `device_list` - A reference to a Mutex<Vec<Device>> that contains all the devices that are connected to the server
## Returns
changes the stream_status to Running and updates the device status to Running"]
    pub fn notify_stream_running(&mut self, card_mac: &String, device_list: &Mutex<Vec<Device>>) {
        // TODO: check the logic of this function
        self.stream_status = StreamStatus::Running;

        if self.running_generators.contains_key(card_mac) {
            self.running_generators
                .get_mut(card_mac)
                .unwrap()
                .clone_from(&ProcessStatus::Running);

            Device::update_device_status(
                card_mac,
                &ProcessStatus::Running,
                &ProcessType::Generation,
                device_list,
            );
        } else if self.running_verifiers.contains_key(card_mac) {
            self.running_verifiers
                .get_mut(card_mac)
                .unwrap()
                .clone_from(&ProcessStatus::Running);

            Device::update_device_status(
                card_mac,
                &ProcessStatus::Running,
                &ProcessType::Verification,
                device_list,
            );
        }
    }

    #[doc = r"# Notify Stream Finished
this will update the stream status according to the devices that are still running
if there are no devices left, the stream status will be set to stopped
if there are devices left, the stream status will be set to finished
## Arguments
* `card_mac` - the mac address of the card used in testing and has finished
* `device_list` - the list of devices
## Panics
* `Error: Failed to lock the device list` - if the device list is locked"]
    pub fn notify_stream_finished(&mut self, card_mac: &String, device_list: &Mutex<Vec<Device>>) {
        /*
        TODO: check the logic of this function
        check if there are any devices left in the running streams list for this stream id
        if there are no devices left, remove the stream from the running streams list and set the stream status to stopped
        if there are devices left, set the stream status to finished and remove the device from the running streams list

        check if the device is a generator
        if it is, mark the generator as completed
        */
        let process = self.running_generators.get(card_mac);
        if process.is_some() {
            self.running_generators
                .get_mut(card_mac)
                .unwrap()
                .clone_from(&ProcessStatus::Completed);

            // then check if there are any other process running in the device
            // if there are no other generators running, set the DeviceStatus to Idle
            Device::update_device_status(
                card_mac,
                &ProcessStatus::Completed,
                &ProcessType::Generation,
                device_list,
            );

            // check if there are any other generators running in the stream
            // if there are no other generators running, set the stream status to Stopped
            let working_generators = self
                .running_generators
                .values()
                .filter(|x| **x == ProcessStatus::Running)
                .count();

            if working_generators == 0 {
                self.stream_status = StreamStatus::Stopped;
            }
        }

        // check if the device is a verifier
        // if it is, mark the verifier as completed
        let process = self.running_verifiers.get(card_mac);
        if process.is_some() {
            self.running_generators
                .get_mut(card_mac)
                .unwrap()
                .clone_from(&ProcessStatus::Completed);

            // then check if there are any other process running in the device
            // if there are no other generators running, set the DeviceStatus to Idle
            Device::update_device_status(
                card_mac,
                &ProcessStatus::Completed,
                &ProcessType::Verification,
                device_list,
            );

            // check if there are any other generators running in the stream
            // if there are no other generators running, set the stream status to Stopped
            let working_verifiers = self
                .running_verifiers
                .values()
                .filter(|x| **x == ProcessStatus::Running)
                .count();

            if working_verifiers == 0 {
                self.stream_status = StreamStatus::Stopped;
            }
        }
    }

    #[doc = r"# Send Stream
The send_stream function is used to send the stream to the devices that will generate and verify the stream
## Arguments
* `delayed` - A bool that represents if the stream will be delayed or not
* `DEVICE_LIST` - A reference to a Mutex<Vec<Device>> that contains all the devices that are connected to the server
## Returns
* `Result<(), reqwest::Error>` - A Result that contains the response from the devices or an error if the request failed
## Errors
* `reqwest::Error` - An error that is returned if the request failed"]
    pub async fn send_stream(&mut self, delayed: bool, device_list: &Mutex<Vec<Device>>) {
        /*
            TODO: check the logic of this function
            send the start request to all the senders and receivers
            if the request is successful, add the device to the running devices list
            if the request fails, set the device status to offline
            NOTE: if the device has multiple cards, the request will be sent to all the cards in the device and the device will be added to the running devices list
        */
        let mut devices_recived: HashMap<(String, u16, String), ProcessType> = HashMap::new(); // Ip address, port, mac address of the device that will receive the stream and the type of process that will be run on the device

        let mut verifiers_macs: Vec<String> = Vec::new();
        for name in &self.verifiers_ids {
            let receiver = Device::find_device(name, device_list);
            if receiver.is_none() {
                println!("Device not found: {}, skipping", name);
                continue;
            }
            let receiver = receiver.unwrap();
            verifiers_macs.push(receiver.get_device_mac());

            devices_recived.insert(receiver.get_device_info_tuple(), ProcessType::Verification);
        }

        let mut genorators_macs: Vec<String> = Vec::new();
        for name in &self.generators_ids {
            let receiver = Device::find_device(name, device_list);
            if receiver.is_none() {
                println!("Device not found: {}, skipping", name);
                continue;
            }

            let receiver = receiver.unwrap();
            genorators_macs.push(receiver.get_device_mac());

            // add the device to the list of devices that need to recive the request if it already exists, it will be overwritten
            if devices_recived.contains_key(&receiver.get_device_info_tuple()) {
                devices_recived.insert(
                    receiver.get_device_info_tuple(),
                    ProcessType::GenerationaAndVerification,
                );
            } else {
                devices_recived.insert(receiver.get_device_info_tuple(), ProcessType::Generation);
            }
        }

        let stream_details = StreamDetails {
            stream_id: self.stream_id.clone(),
            delay: self.delay * (delayed as u64),
            generators: genorators_macs,
            verifiers: verifiers_macs,
            payload_type: self.payload_type,
            number_of_packets: self.number_of_packets,
            payload_length: self.payload_length,
            seed: self.seed,
            broadcast_frames: self.broadcast_frames,
            inter_frame_gap: self.inter_frame_gap,
            time_to_live: self.time_to_live,
            transport_layer_protocol: self.transport_layer_protocol.clone() as u8,
            flow_type: self.flow_type.clone() as u8,
            check_content: self.check_content,
        };

        for receiver in &mut devices_recived {
            let response = reqwest::Client::new()
                .post(&format!("http://{}:{}/start", receiver.0 .0, receiver.0 .1))
                // send the stream details as a json
                .body(
                    serde_json::to_string(&stream_details)
                        .expect("Failed to serialize stream details"),
                )
                .send()
                .await;

            // check if the request was successful
            match response {
                Ok(_response) => {
                    match _response.status() {
                        StatusCode::OK => {
                            // set the receiver status to running
                            Device::update_device_status(
                                &receiver.0 .0,
                                &ProcessStatus::Queued,
                                receiver.1,
                                device_list,
                            );

                            // add the device to the running devices list with a Queued status (the device will change it to running when it starts)
                            if (receiver.1 == &ProcessType::GenerationaAndVerification)
                                || (receiver.1 == &ProcessType::Generation)
                            {
                                self.running_generators
                                    .insert(receiver.0 .2.clone(), ProcessStatus::Queued);
                            }

                            if (receiver.1 == &ProcessType::GenerationaAndVerification)
                                || (receiver.1 == &ProcessType::Verification)
                            {
                                self.running_verifiers
                                    .insert(receiver.0 .2.clone(), ProcessStatus::Queued);
                            }
                        }
                        _ => {
                            println!("Error: {}", _response.text().await.unwrap());

                            // set the receiver status to offline (generic error)
                            Device::update_device_status(
                                &receiver.0 .0,
                                &ProcessStatus::Failed,
                                receiver.1,
                                device_list,
                            );

                            // add the device to the running devices list with a failed status
                            if (receiver.1 == &ProcessType::GenerationaAndVerification)
                                || (receiver.1 == &ProcessType::Generation)
                            {
                                self.running_generators
                                    .insert(receiver.0 .2.clone(), ProcessStatus::Failed);
                            }
                            if (receiver.1 == &ProcessType::GenerationaAndVerification)
                                || (receiver.1 == &ProcessType::Verification)
                            {
                                self.running_verifiers
                                    .insert(receiver.0 .2.clone(), ProcessStatus::Failed);
                            }
                        }
                    }
                }
                Err(_error) => println!("Error: {}", _error),
            }
        }

        // check if the devices are running the stream and set the stream status accordingly (error if only one type of devices is running the stream)
        let mut devices_recived = 0;
        for device in &self.running_generators {
            if device.1 == &ProcessStatus::Queued {
                devices_recived += 1;
                break;
            }
        }
        for device in &self.running_verifiers {
            if device.1 == &ProcessStatus::Queued {
                devices_recived += 1;
                break;
            }
        }

        if devices_recived == 0 {
            self.stream_status = StreamStatus::Error;
            println!("Error: No devices are running the stream")
        } else if devices_recived == 1 {
            self.stream_status = StreamStatus::Error;
            println!("Error: Only one device type is running the stream")
        } else {
            self.stream_status = StreamStatus::Queued;
        }
    }

    #[doc = r"# Stop the stream
stops the stream on all the devices that are running it and Marks the process as Idle
if the request fails, the device status will be set to Offline
## Arguments
* `DEVICE_LIST` - the list of devices
## Returns
* `Result<(), reqwest::Error>` - the result of the request
## Logs
* `Could not Stop Generator: {}, skipping` - if the generator is not found in the device list
* `Could not Stop Verifier: {}, skipping` - if the verifier is not found in the device list
* `Stopping stream {}...` - the stream id
* `generators error: {}` - if the request to the generator fails
* `verifiers error: {}` - if the request to the verifier fails
* `stream {} stopped` - the stream id"]
    pub async fn stop_stream(&mut self, device_list: &Mutex<Vec<Device>>) {
        // send the stop request to all the devices that are running the stream
        // if the request is successful, set the device status to idle
        // if the request fails, set the device status to offline
        print!("Stopping stream {}...", self.get_stream_id());

        // stop the generators
        for mut name in &self.running_generators {
            // find the device in the device list
            let receiver = Device::find_device(name.0, device_list);
            if receiver.is_none() {
                println!("Could not Stop Generator: {}, skipping", name.0);
                continue;
            }

            // send the stop request
            let receiver = receiver.unwrap();
            let response = reqwest::Client::new()
                .post(&format!(
                    "http://{}:{}/stop",
                    receiver.get_ip_address(),
                    receiver.get_port()
                ))
                .body(self.get_stream_id().clone())
                .send()
                .await;

            // set the device status according to the response status
            match response {
                Ok(_response) => {
                    match _response.status() {
                        StatusCode::OK => {
                            Device::update_device_status(
                                &receiver.get_device_mac(),
                                &ProcessStatus::Queued,
                                &ProcessType::Generation,
                                device_list,
                            );
                            name.1 = &ProcessStatus::Stopped;
                        }
                        _ => {
                            println!("generators error: {}", _response.text().await.unwrap());
                            // set the receiver status to offline (generic error)
                            Device::update_device_status(
                                &receiver.get_device_mac(),
                                &ProcessStatus::Failed,
                                &ProcessType::Generation,
                                device_list,
                            );
                            name.1 = &ProcessStatus::Failed;
                        }
                    }
                }
                Err(_error) => println!("generators error: {}", _error),
            }
        }

        // stop the verifiers
        for mut name in &self.running_verifiers {
            // find the device in the device list
            let receiver = Device::find_device(name.0, device_list);
            if receiver.is_none() {
                println!("Could not Stop Verifier: {}, skipping", name.0);
                continue;
            }

            // send the stop request
            let receiver = receiver.unwrap();
            let response = reqwest::Client::new()
                .post(&format!(
                    "http://{}:{}/stop",
                    receiver.get_ip_address(),
                    receiver.get_port()
                ))
                .body(self.get_stream_id().clone())
                .send()
                .await;

            // set the device status according to the response status
            match response {
                Ok(_response) => {
                    match _response.status() {
                        StatusCode::OK => {
                            Device::update_device_status(
                                &receiver.get_device_mac(),
                                &ProcessStatus::Queued,
                                &ProcessType::Verification,
                                device_list,
                            );

                            name.1 = &ProcessStatus::Stopped;
                        }
                        _ => {
                            println!("verifiers error: {}", _response.text().await.unwrap());
                            // set the receiver status to offline (generic error)
                            Device::update_device_status(
                                &receiver.get_device_mac(),
                                &ProcessStatus::Failed,
                                &ProcessType::Verification,
                                device_list,
                            );

                            name.1 = &ProcessStatus::Failed;
                        }
                    }
                }
                Err(_error) => println!("generators error: {}", _error),
            }
        }

        // set the stream status to stopped
        self.stream_status = StreamStatus::Stopped;
        print!("Stream {} stopped", self.get_stream_id());
    }

    #[doc = r"get the stream status
this is used to check if the stream is running or not
this is also used to check if the stream is queued or not"]
    pub fn get_stream_status(&self) -> &StreamStatus {
        &self.stream_status
    }

    #[doc = r"get the stream id
this is used to identify the stream"]
    pub fn get_stream_id(&self) -> &String {
        &self.stream_id
    }

    #[doc = r"# Queue the stream
this will add the stream to the queue
## Arguments
* `QUEUED_STREAMS` - the list of queued streams
* `DEVICE_LIST` - the list of devices
## Panics
* `Error: Failed to lock the queued streams list for adding stream {} to the queue` - if the queued streams list is locked
## Logs
* `Stream queued to start in {} seconds` - the delay in seconds before the stream starts (the delay is set by the user)"]
    pub async fn queue_stream(
        &mut self,
        queued_streams: &Mutex<Vec<String>>,
        device_list: &Mutex<Vec<Device>>,
    ) {
        // set the stream status to queued
        self.stream_status = StreamStatus::Queued;

        // log the start time
        print!("Stream queued to start in {} seconds", self.delay / 1000);

        // send the stream to the client to update the stream status to queued
        self.send_stream(true, device_list).await;

        // add the thread to the queued streams list
        queued_streams
            .lock()
            .expect(format!("Error: Failed to lock the queued streams list for adding stream {} to the queue", self.get_stream_id()).as_str())
            .push(self.get_stream_id().clone());
    }

    #[doc = r"# Remove the stream from the queue
this will remove the stream from the queue
## Arguments
* `QUEUED_STREAMS` - the list of queued streams
* `DEVICE_LIST` - the list of devices
## Panics
* `Error: Failed to lock the queued streams list for removing the stream from the queue {}` - if the queued streams list is locked
## Logs
* `Error: {}` - if the stream fails to stop
* `Error: Could not find the stream {} in the queued streams list` - if the stream is not found in the queued streams list"]
    pub async fn remove_stream_from_queue(
        &mut self,
        queued_streams: &Mutex<Vec<String>>,
        device_list: &Mutex<Vec<Device>>,
    ) {
        self.stream_status = StreamStatus::Stopped; // set the stream status to stopped

        // stop the stream
        self.stop_stream(device_list).await;

        // remove the stream from the queued streams list
        let mut queue = queued_streams
            .lock()
            .expect(format!("Error: Failed to lock the queued streams list for removing the stream from the queue {}", self.get_stream_id()).as_str());

        // remove the stream from the queued streams vector
        let index = queue.iter().position(|x| x == self.get_stream_id());
        if index.is_some() {
            queue.remove(index.unwrap());
        } else {
            print!(
                "Error: Could not find the stream {} in the queued streams list",
                self.get_stream_id()
            );
        }
    }
}

#[doc = r"# Stream Status
this enum represents the status of the stream
## Variants
* `Created` - the stream has been created
* `Stopped` - the stream has been stopped
* `Running` - the stream is running
* `Finished` - the stream has finished
* `Queued` - the stream is queued
* `Error` - the stream has encountered an error
## Notes
* the default variant is `Created`"]
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(tag = "status")]
pub enum StreamStatus {
    #[default]
    #[serde(rename = "Created")]
    Created,
    #[serde(rename = "Queued")]
    Queued,
    #[serde(rename = "Running")]
    Running,
    #[serde(rename = "Finished")]
    Finished,
    #[serde(rename = "Error")]
    Error,
    #[serde(rename = "Stopped")]
    Stopped,
}

#[doc = r"# Transport Layer Protocol Type
this enum represents the transport layer protocol type
## Variants
* `TCP` - the transport layer protocol is TCP
* `UDP` - the transport layer protocol is UDP
## Notes
* the default variant is `TCP`"]
#[derive(Serialize, Deserialize, Default, Debug, Clone)]
#[serde(tag = "protocol")]
enum TransportLayerProtocol {
    #[default]
    #[serde(rename = "TCP")]
    TCP,
    #[serde(rename = "UDP")]
    UDP,
}

#[doc = r"# Flow Type
this enum represents the flow type
## Variants
* `BtB` - the flow type is BtB
* `Bursts` - the flow type is Bursts
## Notes
* the default variant is `BtB`"]
#[derive(Serialize, Deserialize, Default, Debug, Clone)]
#[serde(tag = "flowtype")]
enum FlowType {
    #[default]
    #[serde(rename = "BtB")]
    BtB,
    #[serde(rename = "Bursts")]
    Bursts,
}
