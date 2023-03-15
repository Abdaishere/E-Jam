pub(crate) mod device;
pub(crate) mod process;
pub(crate) mod stream_details;

use chrono::{serde::ts_seconds, serde::ts_seconds_option, DateTime, Utc};
use lazy_static::lazy_static;
use regex::Regex;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, sync::Mutex};
use validator::Validate;

use self::device::Device;
use self::process::{ProcessStatus, ProcessType};
use self::stream_details::StreamDetails;

lazy_static! {
    #[doc = r"Regex for the stream id that is used to identify the stream in the device must be alphanumeric max is 3 characters
    example of a valid stream id: 123, abc, 1a2, 1A2, 1aB, 1Ab, 1AB"]
    static ref STREAM_ID : Regex = Regex::new(r"^([a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9])$").unwrap();


    #[doc = r"Regex for the mac address of the device's mac address
    example of a valid mac address: 00:00:00:00:00:00, 00-00-00-00-00-00"]
    static ref MAC_ADDRESS : Regex = Regex::new(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$").unwrap();

    #[doc = r"Regex for the ip address of the device's ip address
    example of a valid ip address: 192.168.01.1, 192.168.1.00"]
    static ref IP_ADDRESS : Regex = Regex::new(r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$").unwrap();
}

#[doc = r" # App State
The state of the Server that is shared between all the threads of the server
This is used to store the list of all the devices that are connected to the server and the list of all the streams and the list of all the streams that are currently Queued to be started on the devices
This is also used to store the counter for the stream id that is used to identify the stream in the device must be alphanumeric max is 3 characters
All the values are wrapped in a Mutex to allow for thread safe access to the values from all the threads of the server.
## Values
* `streams_entries` - A Vec of StreamEntry sturct that represents the list of all the streams that are currently running on the devices
* `queued_streams` - A Vec of Strings that represents the list of all the streams that are currently Queued to be started on the devices
* `device_list` - A Vec of Device struct that represents the list of all the devices that are currently connected to the server (mac address, device name and ip address)
* `stream_id_counter` - A u32 that represents the counter for the stream id that is used to identify the stream in the device must be 3 alphanumeric characters"]
pub struct AppState {
    pub streams_entries: Mutex<Vec<StreamEntry>>,

    #[doc = r"List of all the streams that are currently Queued to be started on the devices"]
    pub queued_streams: Mutex<Vec<String>>,

    #[doc = r"List of all the devices that are currently connected to the server (mac address, device name and ip address)"]
    pub device_list: Mutex<Vec<Device>>,

    #[doc = r"Counter for the stream id that is used to identify the stream in the device must be alphanumeric max is 3 characters"]
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
* `last_updated` - A DateTime in Utc that represents the last time that the stream was updated (used for clarification)
* `start_time` - A DateTime in Utc that represents the time that the stream will start
* `end_time` - A DateTime in Utc that represents the time that the stream will end
* `delay` - A u64 that represents the time in ms that the stream will wait before starting
* `stream_id` - A String that represents the id of the stream that is used to identify the stream in the device, must be alphanumeric, max is 3 bytes (36^3 = 46656)
* `generators_ids` - A Vec of Strings that represents the ids of the devices that will generate the stream (priority of ID is in this order (LTR), mac, ip, name)
* `verifiers_ids` - A Vec of Strings that represents the ids of the devices that will verify the stream (priority of ID is in this order (LTR), mac, ip, name)
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
* `running_generators` - A HashMap (String, ProcessStatus) that represents the list of all the devices that are currently running the stream as a generator and their status (mac address of the card used in testing, Process Status) (used for clarification)
* `running_verifiers` - A HashMap (String, ProcessStatus) that represents the list of all the devices that are currently running the stream as a verifier and their status (mac address of the card used in testing, Process Status) (used for clarification)
* `stream_status` - A StreamStatus that represents the status of the stream.
"]
#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StreamEntry {
    #[doc = r" ## Name
    Name of the stream (used for clarification)
    ## Constraints
    * The name must be greater than 0 characters long
    * The name must be less than 50 characters long
    "]
    #[validate(length(
        min = 1,
        max = 50,
        message = "Name must be between 1 and 50 characters long"
    ))]
    name: String,

    #[doc = r" ## Description
    Description of the stream (used for clarification)
    ## Constraints
    * The description must be greater than 1 characters long
    * The description must be less than 255 characters long
    "]
    #[validate(length(
        min = 1,
        max = 255,
        message = "Description must be between 1 and 255 characters long"
    ))]
    description: String,

    #[doc = r" ## Last Updated
    Last time that the stream was updated
    this is updated when the stream Status is updated by the server
    "]
    #[serde(with = "ts_seconds")]
    #[serde(default, skip_deserializing)]
    last_updated: DateTime<Utc>,

    #[doc = r" ## Start Time
    This is updated when the stream is started with the time the first device starts the stream
    This is an optional field and can be left empty and will be updated automatically when the stream is first started
    "]
    #[serde(default, skip_deserializing)]
    #[serde(with = "ts_seconds_option")]
    start_time: Option<DateTime<Utc>>,

    #[doc = r" ## End Time
    This is updated when the stream is finished with the time the last device finishes the stream
    This is an optional field and can be left empty and will be updated automatically when the stream is last finished
    "]
    #[serde(default, skip_deserializing)]
    #[serde(with = "ts_seconds_option")]
    end_time: Option<DateTime<Utc>>,

    #[doc = r" ## Delay
    This the delay in ms that the stream will wait before starting it
    (can be 0 for no delay or force start the stream)
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[serde(default)]
    #[validate(range(min = 0, message = "Delay must be greater than or equal to 0"))]
    delay: u64,

    #[doc = r" ## Stream ID
    This is the id of the stream that is used to identify the stream in the device, must be alphanumeric, max is 3 charecters
    The stream id is generated by the server and is unique or can be given by the user (if the user gives the id it must be unique)
    ## Constraints
    * Must be given (length is 3)
    * Must be alphanumeric (a-z (only by user), A-Z, 0-9)
    * check the regex `STREAM_ID` for more details
    "]
    #[validate(regex(
        path = "STREAM_ID",
        message = "Stream ID must be alphanumeric and 3 characters long"
    ))]
    #[serde(default)]
    stream_id: String,

    #[doc = r" ## Generators IDs
    This is the list of all the devices that will generate the stream insurted by the user
    (priority of ID is in this order (LTR), mac, ip, name)
    ## Constraints
    * Must be given (min length is 1)
    "]
    #[validate(length(min = 1, message = "number of Generators must be greater than 0"))]
    generators_ids: Vec<String>,

    #[doc = r" ## Verifiers IDs
    This is the list of all the devices that will verify the stream insurted by the user
    (priority of ID is in this order (LTR), mac, ip, name)
    ## Constraints
    * Must be given (min length is 1)
    "]
    #[validate(length(min = 1, message = "number of Verifiers must be greater than 0"))]
    verifiers_ids: Vec<String>,

    #[doc = r" ## Payload Type
    This is the type of payload that will be used during the stream
    0 - alphabitic from a to z four times
    1 - ....  
    2 - random bytes with seed and length
    ## Constraints
    * Must be 0, 1 or 2
    "]
    #[validate(range(min = 0, max = 2, message = "Payload Type must be 0, 1 or 2"))]
    #[serde(default)]
    payload_type: u8,

    #[doc = r" ## Number of Packets
    This is the number of packets that will be sent in the stream
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(
        min = 0,
        message = "Number of Packets must be greater than or equal to 0"
    ))]
    #[serde(default)]
    number_of_packets: u32,

    #[doc = r" ## Payload Length
    This is the length of the payload that will be used in the stream
    ## Constraints
    * Must be between 0 and 1500
    "]
    #[validate(range(
        min = 0,
        max = 1500,
        message = "Payload Length must be between 0 and 1500"
    ))]
    #[serde(default)]
    payload_length: u16,

    #[doc = r" ## Seed
    This is the seed that will be used to generate the packets during the stream
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(min = 0, message = "Seed must be greater than or equal to 0"))]
    #[serde(default)]
    seed: u32,

    #[doc = r" ## Broadcast Frames
    This is the number of broadcast frames that will be sent during the stream
    send broadcast frames every broadcast_frames packets
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(
        min = 0,
        message = "Broadcast Frames must be greater than or equal to 0"
    ))]
    #[serde(default)]
    broadcast_frames: u32,

    #[doc = r" ## Inter Frame Gap
    This is the inter frame gap between packets in the stream
    Inter frame gap in milliseconds
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(
        min = 0,
        message = "Inter Frame Gap must be greater than or equal to 0"
    ))]
    #[serde(default)]
    inter_frame_gap: u32,

    #[doc = r" ## Time to Live
    This is the time the stream will live for in the device
    time to live in milliseconds
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(min = 0, message = "Time to Live must be greater than or equal to 0"))]
    time_to_live: u64,

    #[doc = r" ## Transport Layer Protocol
    This is the transport layer protocol that will be used in the stream
    ## Constraints
    * Must be TCP, UDP
    "]
    #[serde(default)]
    transport_layer_protocol: TransportLayerProtocol,

    #[doc = r" ## Flow Type
    This is the Flow Type that will be used in the stream
    ## Constraints
    * Must be BtB, Burst
    "]
    #[serde(default)]
    flow_type: FlowType,

    #[doc = r" ## Check Content
    This is the check content that will be used in the stream
    check the content of the payload or not
    ## Constraints
    * Must be boolean
    "]
    #[serde(default)]
    check_content: bool,

    #[doc = r" ## Running Generators
    This is the list of all the Process that are generating the stream (mac_address of the device, process status)
    "]
    #[serde(default)]
    running_generators: HashMap<String, ProcessStatus>,

    #[doc = r" ## Running Verifiers
    This is the list of all the Process that are verifying the stream (mac_address of the device, process status)
    "]
    #[serde(default)]
    running_verifiers: HashMap<String, ProcessStatus>,

    #[doc = r" ## Stream Status
    This is the state that the stream is in at any given time in the system (see the state machine below)
    ## see also
    The stream state machine: ./docs/stream_state_machine.png"]
    #[serde(default, skip_deserializing)]
    stream_status: StreamStatus,
}

#[doc = r" # Implementation of the StreamEntry struct that contains all the information about the stream and the functions that are used to manipulate the stream"]
impl StreamEntry {
    #[doc = r" ## Generate New Stream ID
This function is used to generate a new id for the stream and check if the id is unique
## Arguments
* `stream_id_counter` - A reference to a Mutex for u32 that is used to generate the id of the stream
* `streams_entries` - A reference to a Mutex for Vec of StreamEntry that is used to check if the id of the stream is unique
## Returns
changes the stream_id of the stream to a new id"]
    pub fn generate_new_stream_id(
        &mut self,
        stream_id_counter: &Mutex<u32>,
        streams_entries: &Mutex<Vec<StreamEntry>>,
    ) {
        let mut stream_id_counter = stream_id_counter.lock().unwrap();
        if (*stream_id_counter) > 46655 {
            *stream_id_counter = 0;
        }
        let val = loop {
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

            let streams_entries = streams_entries.lock().unwrap();
            if streams_entries
                .iter()
                .find(|x| x.stream_id == stream_id)
                .is_none()
            {
                break Ok(stream_id);
            } else if *stream_id_counter > 46655 {
                break Err("No more stream ids available".to_string());
            }
        };
        match val {
            Ok(val) => self.stream_id = val,
            Err(e) => {
                println!("Error generating new stream id: {}", e);
            }
        }
    }

    #[doc = r" ## Notify Process Running
The notify_process_running function is used to update the stream status to Running and update the devices that are notifying the server that they have started the stream.
The Device notifies once if it was both a generator and verifier in the specified stream.
## Arguments
* `card_mac` - the mac address of the card used in testing and has Started
* `device_list` - A reference to a Mutex for Vec of Device struct that contains all the devices that are connected to the server
## Returns
changes the stream_status to Running and updates the device status to Running"]
    pub fn notify_process_running(&mut self, card_mac: &str, device_list: &Mutex<Vec<Device>>) {
        /*
        check if the device is a generator
        if it is, mark the generator as Running
        */
        let device = Device::find_device(card_mac, device_list);
        match device {
            Some(device) => {
                let process = self.running_generators.get(card_mac);
                if process.is_some() {
                    self.running_generators
                        .get_mut(card_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Running);

                    // then update the device status to Running
                    device_list
                        .lock()
                        .unwrap()
                        .get_mut(device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Running, &ProcessType::Generation);
                } else {
                    println!("Generator not found")
                }

                // check if the device is a verifier
                // if it is, mark the verifier as Running
                let process = self.running_verifiers.get(card_mac);
                if process.is_some() {
                    self.running_verifiers
                        .get_mut(card_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Running);

                    // then update the device status to Running
                    device_list
                        .lock()
                        .unwrap()
                        .get_mut(device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Running, &ProcessType::Verification);
                } else {
                    println!("Verifier not found")
                }

                // update the stream status to Running
                self.update_stream_status(StreamStatus::Running);
            }
            None => {
                println!("Device not found");
            }
        }
    }

    #[doc = r" ## Notify Process Completed
this will update the stream status according to the devices that are still running
if there are no devices left, the stream status will be set to stopped
if there are devices left, the stream status will be set to finished
## Arguments
* `card_mac` - the mac address of the card used in testing and has finished
* `device_list` - A reference to a Mutex for Vec of Device struct that contains all the devices that are connected to the server
## Panics
* `Error: Failed to lock the device list` - if the device list is locked"]
    pub fn notify_process_completed(&mut self, card_mac: &str, device_list: &Mutex<Vec<Device>>) {
        /*
        check if there are any devices left in the running streams list for this stream id
        if there are no devices left, remove the stream from the running streams list and set the stream status to stopped
        if there are devices left, set the stream status to finished and remove the device from the running streams list

        check if the device is a generator
        if it is, mark the generator as completed
        */

        let device = Device::find_device(card_mac, device_list);

        match device {
            Some(device) => {
                let process = self.running_generators.get(card_mac);
                if process.is_some() {
                    self.running_generators
                        .get_mut(card_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Completed);

                    // then check if there are any other process running in the device
                    // if there are no other generators running, set the DeviceStatus to Idle
                    device_list
                        .lock()
                        .unwrap()
                        .get_mut(device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Completed, &ProcessType::Generation);
                } else {
                    println!("Generator not found");
                }

                // check if the device is a verifier
                // if it is, mark the verifier as completed
                let process = self.running_verifiers.get(card_mac);
                if process.is_some() {
                    self.running_verifiers
                        .get_mut(card_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Completed);

                    // then check if there are any other process running in the device
                    // if there are no other generators running, set the DeviceStatus to Idle
                    device_list
                        .lock()
                        .unwrap()
                        .get_mut(device)
                        .unwrap()
                        .update_device_status(
                            &ProcessStatus::Completed,
                            &ProcessType::Verification,
                        );
                } else {
                    println!("Verifier not found");
                }

                self.sync_stream_status();
            }
            None => {
                println!("Device not found");
            }
        }
    }

    #[doc = r" ## Sync Stream Status
The sync_stream_status function is used to update the stream status according to the devices that are still running
if there are no devices left, the stream status will be set to stopped"]
    fn sync_stream_status(&mut self) {
        // check if there are any other generators running in the stream
        // if there are no other generators running, set the stream status to Stopped
        let working_generators = self
            .running_generators
            .values()
            .filter(|x| **x == ProcessStatus::Running)
            .count();

        let working_verifiers = self
            .running_verifiers
            .values()
            .filter(|x| **x == ProcessStatus::Running)
            .count();

        let finished_generators = self
            .running_generators
            .values()
            .filter(|x| **x == ProcessStatus::Completed)
            .count();

        let finished_verifiers = self
            .running_verifiers
            .values()
            .filter(|x| **x == ProcessStatus::Completed)
            .count();

        if finished_generators + finished_verifiers > 0 {
            self.update_stream_status(StreamStatus::Finished);
        } else if working_generators + working_verifiers == 0 {
            self.update_stream_status(StreamStatus::Stopped);
        }
    }

    #[doc = r" ## Send Stream
The send_stream function is used to send the stream to the devices that will generate and verify the stream
## Arguments
* `delayed` - A bool that represents if the stream will be delayed or not
* `device_list` - A reference to a Mutex for Vec of Device that contains all the devices that are connected to the server
## Errors
* `reqwest::Error` - An error that is returned if the request failed"]
    pub async fn send_stream(&mut self, delayed: bool, device_list: &Mutex<Vec<Device>>) {
        /*
            send the start request to all the senders and receivers
            if the request is successful, add the device to the running devices list
            if the request fails, set the device status to offline
            NOTE: if the device has multiple cards, the request will be sent to all the cards in the device and the device will be added to the running devices list
        */
        let mut devices_recived: HashMap<String, (usize, ProcessType)> = HashMap::new();

        let mut verifiers_macs: Vec<String> = Vec::new();
        for name in &self.verifiers_ids {
            let receiver = Device::find_device(name, device_list);
            if receiver.is_none() {
                println!("Device not found: {}, skipping", name);
                continue;
            }
            let receiver = receiver.unwrap();

            let ip_address = device_list
                .lock()
                .unwrap()
                .get(receiver)
                .unwrap()
                .clone_ip_address();

            verifiers_macs.push(ip_address.to_string());

            if devices_recived.contains_key(&ip_address) {
                devices_recived.insert(ip_address, (receiver, ProcessType::Verification));
            }
        }

        let mut genorators_macs: Vec<String> = Vec::new();
        for name in &self.generators_ids {
            let receiver = Device::find_device(name, device_list);
            if receiver.is_none() {
                println!("Device not found: {}, skipping", name);
                continue;
            }

            let receiver = receiver.unwrap();

            let ip_address = device_list
                .lock()
                .unwrap()
                .get(receiver)
                .unwrap()
                .clone_ip_address();

            genorators_macs.push(ip_address.to_string());

            // add the device to the list of devices that need to recive the request if it already exists, it will be overwritten
            if !devices_recived.contains_key(&ip_address) {
                devices_recived.insert(ip_address, (receiver, ProcessType::Generation));
            } else {
                devices_recived.get_mut(&ip_address).unwrap().1 =
                    ProcessType::GenerationaAndVerification;
            }
        }

        let stream_details = StreamDetails {
            stream_id: self.get_stream_id().clone(),
            delay: if delayed { self.delay } else { 0 },
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

        for receiver in devices_recived {
            let process_type = receiver.1 .1;
            let device_index = receiver.1 .0;

            let response = device_list
                .lock()
                .unwrap()
                .get_mut(device_index)
                .unwrap()
                .send_stream(&stream_details, self.get_stream_id(), &process_type)
                .await;
            // check if the request was successful
            match response {
                Ok(_response) => {
                    let mut list = device_list.lock().unwrap();
                    let device = list.get_mut(device_index).unwrap();

                    match _response.status() {
                        StatusCode::OK => {
                            // set the receiver status to running
                            device.update_device_status(&ProcessStatus::Queued, &process_type);

                            match process_type {
                                ProcessType::Generation => {
                                    self.running_generators
                                        .insert(device.clone_device_mac(), ProcessStatus::Queued);
                                }
                                ProcessType::Verification => {
                                    self.running_generators
                                        .insert(device.clone_device_mac(), ProcessStatus::Queued);
                                }
                                ProcessType::GenerationaAndVerification => {
                                    self.running_generators
                                        .insert(device.clone_device_mac(), ProcessStatus::Queued);

                                    self.running_generators
                                        .insert(device.clone_device_mac(), ProcessStatus::Queued);
                                }
                            }

                            println!(
                                "Stream sent to device: {}, process type: {:?}",
                                device.clone_device_mac(),
                                process_type
                            );
                        }
                        _ => {
                            // set the receiver status to offline (generic error)
                            device.update_device_status(&ProcessStatus::Failed, &process_type);

                            // add the device to the running devices list with a failed status
                            match process_type {
                                ProcessType::Generation => {
                                    self.running_generators
                                        .insert(device.clone_device_mac(), ProcessStatus::Failed);
                                }
                                ProcessType::Verification => {
                                    self.running_verifiers
                                        .insert(device.clone_device_mac(), ProcessStatus::Failed);
                                }
                                ProcessType::GenerationaAndVerification => {
                                    self.running_generators
                                        .insert(device.clone_device_mac(), ProcessStatus::Failed);

                                    self.running_generators
                                        .insert(device.clone_device_mac(), ProcessStatus::Failed);
                                }
                            }
                            println!(
                                "Error: Stream not sent to device: {} process type: {:?}",
                                device.clone_device_mac(),
                                process_type
                            );
                            println!("Error: {}", _response.text().await.unwrap());
                        }
                    }
                }
                Err(_error) => println!("Internal error: {}", _error),
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
            self.update_stream_status(StreamStatus::Error);
            println!("Error: No devices are running the stream")
        } else if devices_recived == 1 {
            self.update_stream_status(StreamStatus::Error);
            println!("Error: Only one Process type is running the stream")
        } else {
            self.update_stream_status(StreamStatus::Queued);
        }
    }

    #[doc = r" ## Stop Stream
stops the stream on all the devices that are running it and Marks the process as Idle
if the request fails, the device status will be set to Offline
## Arguments
* `device_list` - the list of devices that are running the stream
## Logs
* `Could not Stop Generator: {}, skipping` - if the generator is not found in the device list
* `Could not Stop Verifier: {}, skipping` - if the verifier is not found in the device list
* `Stopping stream {}...` - the stream id
* `generators error: {}` - if the request to the generator fails
* `verifiers error: {}` - if the request to the verifier fails
* `stream {} stopped` - the stream id"]
    pub async fn stop_stream(&mut self, device_list: &Mutex<Vec<Device>>) {
        /*
        send the stop request to all the devices that are running the stream
        if the request is successful, set the device status to idle
        if the request fails, set the device status to offline
        */
        print!("Stopping stream {}...", self.get_stream_id());
        let mut target_devices: HashMap<String, (usize, ProcessType)> = HashMap::new();

        // stop the generators
        for target_process in &self.running_generators {
            let index = Device::find_device(target_process.0, device_list);
            if index.is_none() {
                println!(
                    "Could not Stop Generator: {} (Not found), skipping",
                    target_process.0
                );
                continue;
            }
            target_devices.insert(
                target_process.0.to_string(),
                (index.unwrap(), ProcessType::Generation),
            );
        }

        for target_process in &self.running_verifiers {
            let index = Device::find_device(target_process.0, device_list);
            if index.is_none() {
                println!(
                    "Could not Stop Verifier: {} (Not found), skipping",
                    target_process.0
                );
                continue;
            }

            if target_devices.contains_key(target_process.0) {
                target_devices.insert(
                    target_process.0.to_string(),
                    (index.unwrap(), ProcessType::GenerationaAndVerification),
                );
            } else {
                target_devices.insert(
                    target_process.0.to_string(),
                    (index.unwrap(), ProcessType::Verification),
                );
            }
        }

        for device in target_devices {
            let mut list = device_list.lock().unwrap();
            // send the stop request
            let receiver = list.get_mut(device.1 .0).unwrap();
            let response = receiver
                .stop_stream(self.get_stream_id(), &device.1 .1)
                .await;

            // set the device status according to the response status
            match response {
                Ok(_response) => {
                    match _response.status() {
                        StatusCode::OK => {
                            receiver.update_device_status(&ProcessStatus::Stopped, &device.1 .1);

                            match device.1 .1 {
                                ProcessType::Generation => {
                                    self.running_generators.insert(
                                        receiver.clone_device_mac(),
                                        ProcessStatus::Stopped,
                                    );
                                }
                                ProcessType::Verification => {
                                    self.running_verifiers.insert(
                                        receiver.clone_device_mac(),
                                        ProcessStatus::Stopped,
                                    );
                                }
                                ProcessType::GenerationaAndVerification => {
                                    self.running_generators.insert(
                                        receiver.clone_device_mac(),
                                        ProcessStatus::Stopped,
                                    );

                                    self.running_generators.insert(
                                        receiver.clone_device_mac(),
                                        ProcessStatus::Stopped,
                                    );
                                }
                            }

                            println!(
                                "device {} stopped stream {} successfully",
                                receiver.clone_device_mac(),
                                self.get_stream_id()
                            );
                        }
                        _ => {
                            println!("generators error: {}", _response.text().await.unwrap());
                            // set the receiver status to offline (generic error)
                            receiver.update_device_status(
                                &ProcessStatus::Failed,
                                &ProcessType::Generation,
                            );

                            match device.1 .1 {
                                ProcessType::Generation => {
                                    self.running_generators
                                        .insert(receiver.clone_device_mac(), ProcessStatus::Failed);
                                }
                                ProcessType::Verification => {
                                    self.running_verifiers
                                        .insert(receiver.clone_device_mac(), ProcessStatus::Failed);
                                }
                                ProcessType::GenerationaAndVerification => {
                                    self.running_generators
                                        .insert(receiver.clone_device_mac(), ProcessStatus::Failed);

                                    self.running_generators
                                        .insert(receiver.clone_device_mac(), ProcessStatus::Failed);
                                }
                            }
                        }
                    }
                }
                Err(_error) => println!("generators error: {}", _error),
            }
        }

        // set the stream status to stopped
        self.update_stream_status(StreamStatus::Stopped);
        print!("Stream {} stopped", self.get_stream_id());
    }

    #[doc = r" ## Get the Stream ID
this is used to identify the stream"]
    pub fn get_stream_id(&self) -> &String {
        &self.stream_id
    }

    #[doc = r" ## Queue Stream
this will add the stream to the queue
## Arguments
* `queued_streams` - the list of queued streams by stream id
* `device_list` - the list of devices that are in the system
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
        self.update_stream_status(StreamStatus::Queued);

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

    #[doc = r" ## Remove Stream From Queue
this will remove the stream from the queue
## Arguments
* `queued_streams` - the list of queued streams by stream id
* `device_list` - the list of devices that are in the system
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
        }
    }

    #[doc = r" ## Update Stream Status
this is used to update the stream status (running, stopped, finished) and the start and end times of the stream if the stream is running or finished respectively
if the stream is stopped, the start and end times are set to None
and the last updated time is set to the current time all the time
## Arguments
* `status` - the new stream status"]
    fn update_stream_status(&mut self, status: StreamStatus) {
        self.stream_status = status;
        if self.stream_status == StreamStatus::Running {
            if self.start_time.is_none() {
                self.start_time = Some(Utc::now());
            }
        } else if self.stream_status == StreamStatus::Finished {
            if self.end_time.is_none() {
                self.end_time = Some(Utc::now());
            }
        } else {
            self.start_time = None;
            self.end_time = None;
        }
        self.last_updated = Utc::now();
    }

    #[doc = r" ## Get Stream Status
this is used to check if the stream is running or not
this is also used to check if the stream is queued or not"]
    pub fn get_stream_status(&self) -> &StreamStatus {
        &self.stream_status
    }

    #[doc = r" ## Check Stream Status
this is used to check if the stream status is the same as the status passed
## Arguments
* `status` - the status to check against"]
    pub fn check_stream_status(&self, status: StreamStatus) -> bool {
        self.stream_status == status
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
#[serde(rename_all = "PascalCase")]
pub enum StreamStatus {
    #[default]
    Created,
    Queued,
    Running,
    Finished,
    Error,
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
#[serde(rename_all = "PascalCase")]
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
* `BtB` - the flow type is BtB (back to back)
* `Bursts` - the flow type is Bursts
## Notes
* the default variant is `BtB`"]
#[derive(Serialize, Deserialize, Default, Debug, Clone)]
#[serde(rename_all = "PascalCase")]
enum FlowType {
    #[default]
    BackToBack,
    Bursts,
}
