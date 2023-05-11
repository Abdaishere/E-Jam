use log::{debug, error, info, warn};
use tokio::task::JoinHandle;
pub(crate) mod device;
pub(crate) mod process;
pub(crate) mod statistics;
pub(crate) mod stream_details;

use self::device::Device;
use self::process::{ProcessStatus, ProcessType};
use self::stream_details::{StreamDetails, StreamStatusDetails};
use chrono::{serde::ts_seconds, serde::ts_seconds_option, DateTime, Utc};
use lazy_static::lazy_static;
use nanoid::nanoid;
use regex::Regex;
use reqwest::{Response, StatusCode};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::sync::Mutex;
use tokio::sync::MutexGuard;
use validator::Validate;

lazy_static! {
    #[doc = r"Regex for the stream id that is used to identify the stream in the device must be URL-friendly max is 3 characters
    example of a valid stream id: 123, abc, 1a2, 1A2, 1aB, 1Ab, 1AB, _1A, _1a, _1_, _1a2, _1A2, _1aB, _1Ab, _1AB"]
    static ref STREAM_ID : Regex = Regex::new(r"^[A-Za-z0-9_~]{3}$").unwrap();

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
This is also used to store the counter for the stream id that is used to identify the stream in the device must be URL-friendly max is 3 characters
All the values are wrapped in a Mutex to allow for thread safe access to the values from all the threads of the server.
## Values
* `streams_entries` - A Vec of StreamEntry struct that represents the list of all the streams that are currently running on the devices
* `queued_streams` - A Vec of Strings that represents the list of all the streams that are currently Queued to be started on the devices
* `device_list` - A Vec of Device struct that represents the list of all the devices that are currently connected to the server (mac address, device name and ip address)
* `stream_id_counter` - A u32 that represents the counter for the stream id that is used to identify the stream in the device must be 3 URL-friendly characters"]
pub struct AppState {
    pub stream_entries: Mutex<Vec<StreamEntry>>,

    #[doc = r"List of all the streams that are currently Queued to be started on the devices"]
    pub queued_streams: Mutex<Vec<String>>,

    #[doc = r"List of all the devices that are currently connected to the server (mac address, device name and ip address)"]
    pub device_list: Mutex<Vec<Device>>,

    #[doc = r"Counter for the stream id that is used to identify the stream in the device must be URL-friendly max is 3 characters"]
    pub stream_id_counter: Mutex<usize>,
}

impl Default for AppState {
    fn default() -> Self {
        AppState {
            stream_entries: Mutex::new(Vec::new()),
            device_list: Mutex::new(Vec::new()),
            queued_streams: Mutex::new(Vec::new()),
            stream_id_counter: Mutex::new(0),
        }
    }
}

#[doc = r" # Stream Entry
The StreamEntry struct is used to store the information about the stream with its status and the status of the devices that are running the stream
Notice: The stream Data is sent in camelCase naming style

## Values

- `stream_id` - A String that represents the id of the stream that is used to identify the stream in the device, must be URL-friendly, max is 3 bytes (36^3 = 46656)
- `name` - A String that represents the name of the stream (used for clarification)
- `description` - A String that represents the description of the stream (used for clarification)
- `last_updated` - A DateTime in Utc that represents the last time that the stream was updated (used for clarification)
- `start_time` - A DateTime in Utc that represents the time that the stream will start (notified by the systemAPI)
- `end_time` - A DateTime in Utc that represents the time that the stream will end (is predicted by the server)
- `delay` - A u64 that represents the time in ms that the stream will wait before starting
- `time_to_live` - A u64 that represents the time to live that will be used for the stream
- `broadcast_frames` - A u64 that represents the number of broadcast frames that will be sent in the stream
- `generators_ids` - A Vec of Strings that represents the ids of the devices that will generate the stream (priority of ID is in this order (LTR), mac, ip, name)
- `verifiers_ids` - A Vec of Strings that represents the ids of the devices that will verify the stream (priority of ID is in this order (LTR), mac, ip, name)
- `number_of_packets` - A u64 that represents the number of packets that will be sent in the stream
- `flow_type` - A FlowType that represents the flow type that will be used for the stream (BtB, Bursts) **changes through the stream**
- `payload_length` - A u16 that represents the length of the payload that will be used in the stream **changes through the stream**
- `payload_type` - A u8 that represents the type of the payload that will be used in the stream (0, 1, 2)
- `burst_length` - A u64 that represents the length of the burst that will be used in the stream
- `burst_delay` - A u64 that represents the delay between each burst that will be used in the stream
- `seed` - A u64 that represents the seed that will be used to generate the payload
- `inter_frame_gap` - A u64 that represents the time in ms that will be waited between each frame **changes through the stream**
- `transport_layer_protocol` - A TransportLayerProtocol that represents the transport layer protocol that will be used for the stream (TCP, UDP)
- `check_content` - A bool that represents if the content of the packets will be checked
- `running_generators` - A HashMap (String, ProcessStatus) that represents the list of all the devices that are currently running the stream as a generator and their status (mac address of the card used in testing, Process Status) (used for clarification)
- `running_verifiers` - A HashMap (String, ProcessStatus) that represents the list of all the devices that are currently running the stream as a verifier and their status (mac address of the card used in testing, Process Status) (used for clarification)
- `stream_status` - A StreamStatus that represents the status of the stream.
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
        min = 0,
        max = 50,
        message = "Name must be between 0 and 50 characters long"
    ))]
    #[serde(default)]
    name: String,

    #[doc = r" ## Description
    Description of the stream (used for clarification)
    ## Constraints
    * The description must be greater than 1 characters long
    * The description must be less than 255 characters long
    "]
    #[validate(length(
        min = 0,
        max = 255,
        message = "Description must be between 0 and 255 characters long"
    ))]
    #[serde(default)]
    description: String,

    #[doc = r" ## Last Updated
    Last time that the stream was updated
    this is updated when the stream Status is updated by the server
    "]
    #[serde(with = "ts_seconds", default = "Utc::now", skip_deserializing)]
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
    This is the id of the stream that is used to identify the stream in the device, must be URL-friendly, max is 3 characters
    The stream id is generated by the server and is unique or can be given by the user (if the user gives the id it must be unique)
    ## Constraints
    * Must be given (length is 3)
    * Must be URL-friendly ((\w) by user, (A-Za-z0-9_~) by the server)
    * check the regex `STREAM_ID` for more details
    "]
    #[validate(regex(
        path = "STREAM_ID",
        message = "Stream ID must be URL-friendly and 3 characters long"
    ))]
    #[serde(default)]
    stream_id: String,

    #[doc = r" ## Generators IDs
    This is the list of all the devices that will generate the stream insured by the user
    (priority of ID is in this order (LTR), mac, ip, name)
    ## Constraints
    * Must be given (min length is 1)
    "]
    #[validate(length(min = 1, message = "number of Generators must be greater than 0"))]
    generators_ids: Vec<String>,

    #[doc = r" ## Verifiers IDs
    This is the list of all the devices that will verify the stream insured by the user
    (priority of ID is in this order (LTR), mac, ip, name)
    ## Constraints
    * Must be given (min length is 1)
    "]
    #[validate(length(min = 1, message = "number of Verifiers must be greater than 0"))]
    verifiers_ids: Vec<String>,

    #[doc = r" ## Payload Type
    This is the type of payload that will be used during the stream
    0 - alphabetic from a to z four times
    1 - ....  
    2 - random bytes with seed and length
    ## Constraints
    * Must be 0, 1 or 2
    "]
    #[validate(range(min = 0, max = 2, message = "Payload Type must be 0, 1 or 2"))]
    #[serde(default)]
    payload_type: u8,

    #[doc = r" ## Burst Length
    This is the length of the burst that will be generated in the stream (in ms)
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(min = 0, message = "Burst Length must be greater than or equal to 0"))]
    #[serde(default)]
    burst_length: u64,

    #[doc = r" ## Burst Delay
    This is the delay between bursts that will be generated in the stream (in ms)
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(min = 0, message = "Burst Delay must be greater than or equal to 0"))]
    #[serde(default)]
    burst_delay: u64,

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
    number_of_packets: u64,

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
    payload_length: u64,

    #[doc = r" ## Seed
    This is the seed that will be used to generate the packets during the stream
    ## Constraints
    * Must be greater than or equal to 0
    "]
    #[validate(range(min = 0, message = "Seed must be greater than or equal to 0"))]
    #[serde(default)]
    seed: u64,

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
    broadcast_frames: u64,

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
    inter_frame_gap: u64,

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
    #[serde(default, skip_deserializing)]
    running_generators: HashMap<String, ProcessStatus>,

    #[doc = r" ## Running Verifiers
    This is the list of all the Process that are verifying the stream (mac_address of the device, process status)
    "]
    #[serde(default, skip_deserializing)]
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
    pub async fn generate_stream_id(
        &mut self,
        stream_id_counter: &Mutex<usize>,
        streams_entries: &MutexGuard<'_, Vec<StreamEntry>>,
    ) {
        info!("Generating stream id");
        loop {
            let id = nanoid!(3);
            info!("Checking if stream id {} is unique", id);
            let checker = streams_entries.iter().find(|stream| stream.stream_id == id);
            match checker {
                Some(stream) => {
                    info!(
                        "Stream ID {} already used by stream {}, generating new id",
                        id, stream.name
                    );
                    continue;
                }
                None => {
                    info!("Stream ID {} is unique", id);
                    let mut generated_stream_ids_counter = stream_id_counter.lock().await;

                    *generated_stream_ids_counter += 1;
                    debug!(
                        "generated id {}, total ids generated {}",
                        id, *generated_stream_ids_counter
                    );
                    self.stream_id = id;
                    break;
                }
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
    pub async fn notify_process_running(
        &mut self,
        card_mac: &str,
        device_list: &mut MutexGuard<'_, Vec<Device>>,
    ) {
        let device = Device::find_device(card_mac, device_list);
        match device {
            Some(device) => {
                /*
                check if the device is a generator
                if it is, mark the generator as Running
                */
                let process = self.running_generators.get(card_mac);
                if process.is_some() {
                    self.running_generators
                        .get_mut(card_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Running);

                    // then update the device status to Running
                    device_list
                        .get_mut(device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Running, &ProcessType::Generation);
                } else {
                    warn!("Generator not found")
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
                        .get_mut(device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Running, &ProcessType::Verification);
                } else {
                    warn!("Verifier not found")
                }

                // update the stream status to Running
                self.update_stream_status(StreamStatus::Running);
            }
            None => {
                warn!("Device not found");
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
    pub async fn notify_process_completed(
        &mut self,
        card_mac: &str,
        device_list: &mut MutexGuard<'_, Vec<Device>>,
    ) {
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
                        .get_mut(device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Completed, &ProcessType::Generation);
                } else {
                    warn!("Generator not found");
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
                    device_list.get_mut(device).unwrap().update_device_status(
                        &ProcessStatus::Completed,
                        &ProcessType::Verification,
                    );
                } else {
                    warn!("Verifier not found");
                }

                self.sync_stream_status();
            }
            None => {
                warn!("Device not found");
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
    pub async fn send_stream(
        &mut self,
        delayed: bool,
        device_list: &mut MutexGuard<'_, Vec<Device>>,
    ) -> i32 {
        /*
            send the start request to all the senders and receivers
            if the request is successful, add the device to the running devices list
            if the request fails, set the device status to offline
            NOTE: if the device has multiple MACs, the request will be sent to all the MACs in the device and the device will be added to the running devices list
        */
        let mut target_devices_pool: HashMap<String, Vec<(usize, ProcessType)>> = HashMap::new();

        let mut verifiers_macs: Vec<String> = Vec::new();
        for name in &self.verifiers_ids {
            let receiver = Device::find_device(name, device_list);
            if receiver.is_none() {
                warn!("Device not found: {}, skipping", name);
                continue;
            }
            let receiver = receiver.unwrap();

            let (ip_address, _, mac) = device_list.get(receiver).unwrap().get_device_info_tuple();

            verifiers_macs.push(mac);

            if let std::collections::hash_map::Entry::Vacant(e) =
                target_devices_pool.entry(ip_address.clone())
            {
                e.insert(vec![(receiver, ProcessType::Verification)]);
            } else {
                target_devices_pool
                    .get_mut(&ip_address)
                    .unwrap()
                    .push((receiver, ProcessType::Verification));
            }
        }

        let mut generators_macs: Vec<String> = Vec::new();
        for name in &self.generators_ids {
            let receiver = Device::find_device(name, device_list);
            if receiver.is_none() {
                warn!("Device not found: {}, skipping", name);
                continue;
            }

            let receiver = receiver.unwrap();

            let (ip_address, _, mac) = device_list.get(receiver).unwrap().get_device_info_tuple();

            generators_macs.push(mac);

            // add the device to the list of devices that need to receive the request if it already exists, it will be overwritten
            if let std::collections::hash_map::Entry::Vacant(e) =
                target_devices_pool.entry(ip_address.clone())
            {
                e.insert(vec![(receiver, ProcessType::Generation)]);
            } else {
                target_devices_pool
                    .get_mut(&ip_address)
                    .unwrap()
                    .push((receiver, ProcessType::Generation));
            }
        }

        let stream_details = self.get_stream_details(delayed, generators_macs, verifiers_macs);
        let handles =
            self.send_stream_to_devices(&target_devices_pool, device_list, &stream_details);

        for (i, (ip, handle)) in handles.into_iter().enumerate() {
            match handle.await {
                Ok(response) => {
                    info!("Stream sent to device {}", i);
                    let processes = target_devices_pool.get(&ip).unwrap();

                    for (device_index, process_type) in processes {
                        self.analyze_response(
                            &response,
                            process_type,
                            device_list.get_mut(device_index.to_owned()).unwrap(),
                            true,
                        )
                        .await
                    }
                }
                Err(e) => {
                    error!("Error sending stream to device {}: {}", i, e);
                }
            }
        }

        // check if the devices are running the stream and set the stream status accordingly (error if only one type of devices is running the stream)
        let mut devices_received = 0;
        for device in &self.running_generators {
            if device.1 == &ProcessStatus::Queued {
                devices_received += 1;
                break;
            }
        }
        for device in &self.running_verifiers {
            if device.1 == &ProcessStatus::Queued {
                devices_received += 1;
                break;
            }
        }

        if devices_received == 0 {
            self.update_stream_status(StreamStatus::Error);
            error!("No devices are running the stream")
        } else if devices_received == 1 {
            self.update_stream_status(StreamStatus::Error);
            error!("Only one Process type is running the stream")
        } else {
            self.update_stream_status(StreamStatus::Sent);
        }
        devices_received
    }

    #[doc = r" ## Send Stream To Devices
The send_stream_to_devices function is used to send the stream to the devices that will generate and verify the stream and return a list of JoinHandles
## Arguments
* `target_devices_pool` - A HashMap that contains the IP address of the devices as keys and a Vec of tuples that contain the index of the device in the device list and the ProcessType as values
* `device_list` - A reference to a Mutex for Vec of Device that contains all the devices that are connected to the server
* `stream_details` - A StreamDetails struct that contains the details of the stream
## Returns
* `Vec<JoinHandle<()>>` - A list of JoinHandles that can be used to wait for the threads to finish"]
    pub fn send_stream_to_devices(
        &self,
        target_devices_pool: &HashMap<String, Vec<(usize, ProcessType)>>,
        device_list: &MutexGuard<'_, Vec<Device>>,
        stream_details: &StreamDetails,
    ) -> Vec<(
        String,
        JoinHandle<Result<reqwest::Response, reqwest::Error>>,
    )> {
        let mut handles: Vec<(
            String,
            JoinHandle<Result<reqwest::Response, reqwest::Error>>,
        )> = Vec::new();

        for receivers in target_devices_pool {
            let receiver = receivers.1.first().unwrap();
            let device = device_list.get(receiver.0).unwrap().clone();
            let stream_details = stream_details.clone();

            let handle = tokio::spawn(async move { device.send_stream(&stream_details).await });

            handles.push((receivers.0.clone(), handle));
        }
        handles
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
    pub async fn stop_stream(
        &mut self,
        device_list: &mut MutexGuard<'_, Vec<Device>>,
    ) -> StreamStatus {
        /*
        send the stop request to all the devices that are running the stream
        if the request is successful, set the device status to idle
        if the request fails, set the device status to offline
        */
        info!("Stopping stream {}...", self.get_stream_id());
        let mut target_devices_pool: HashMap<String, (usize, ProcessType)> = HashMap::new();

        // stop the generators
        for target_process in &self.running_generators {
            let index = Device::find_device(target_process.0, device_list);
            if index.is_none() {
                warn!(
                    "Could not Stop Generator: {} (Not found), skipping",
                    target_process.0
                );
                continue;
            }
            target_devices_pool.insert(
                target_process.0.to_string(),
                (index.unwrap(), ProcessType::Generation),
            );
        }

        for target_process in &self.running_verifiers {
            let index = Device::find_device(target_process.0, device_list);
            if index.is_none() {
                warn!(
                    "Could not Stop Verifier: {} (Not found), skipping",
                    target_process.0
                );
                continue;
            }

            if target_devices_pool.contains_key(target_process.0) {
                target_devices_pool.insert(
                    target_process.0.to_string(),
                    (index.unwrap(), ProcessType::GeneratingAndVerification),
                );
            } else {
                target_devices_pool.insert(
                    target_process.0.to_string(),
                    (index.unwrap(), ProcessType::Verification),
                );
            }
        }

        let handles = self.stop_stream_on_devices(&target_devices_pool, device_list);

        for (i, handle) in handles {
            match handle.await {
                Ok(response) => {
                    let device_info = target_devices_pool.get(&i).unwrap();
                    let device = device_list.get_mut(device_info.0).unwrap();

                    // set the device status according to the response status
                    self.analyze_response(&response, &device_info.1, device, false)
                        .await;
                }
                Err(e) => {
                    error!("{} error: {}", i, e);
                }
            }
        }

        // set the stream status to stopped
        self.update_stream_status(StreamStatus::Stopped);
        info!("Stream {} stopped", self.get_stream_id());
        self.sync_stream_status();
        self.stream_status.clone()
    }

    #[doc = r" ## Stop Stream On Devices
The stop_stream_on_devices function is used to send the stop request to the devices that are running the stream and return a list of JoinHandles
## Arguments
* `target_devices_pool` - A HashMap that contains the IP address of the devices as keys and a tuple that contain the index of the device in the device list and the ProcessType as values
* `device_list` - A reference to a Mutex for Vec of Device that contains all the devices that are connected to the server
## Returns
* `Vec<JoinHandle<()>>` - A list of JoinHandles that can be used to wait for the threads to finish"]
    pub fn stop_stream_on_devices(
        &self,
        target_devices_pool: &HashMap<String, (usize, ProcessType)>,
        device_list: &MutexGuard<'_, Vec<Device>>,
    ) -> Vec<(
        String,
        JoinHandle<Result<reqwest::Response, reqwest::Error>>,
    )> {
        let mut handles: Vec<(
            String,
            JoinHandle<Result<reqwest::Response, reqwest::Error>>,
        )> = Vec::new();

        for receivers in target_devices_pool {
            let receiver = receivers.1;
            let device = device_list.get(receiver.0).unwrap().clone();
            let stream_id = self.get_stream_id().clone();

            let handle = tokio::spawn(async move { device.stop_stream(&stream_id).await });

            handles.push((receivers.0.clone(), handle));
        }
        handles
    }

    #[doc = r" ## Get the Stream ID
this is used to identify the stream"]
    pub fn get_stream_id(&self) -> &String {
        &self.stream_id
    }

    #[doc = r" ## Analyze Response
    The analyze_response function is used to analyze the response of the request sent to the device weather it is a start or stop request and update the device status accordingly
    if the request failed, the device status will be set to offline (generically)
    ## Arguments
    * `response` - A Result of Response and reqwest::Error that contains the response of the request
    * `process_type` - A ProcessType that represents the type of process that the request was sent to
    * `device` - A reference to a Device that contains the device that the request was sent to
    * `sending` - A bool that represents if the request was a start or stop request
    ## Errors
    * `reqwest::Error` - An error that is returned if the request failed (will set the device status to offline)"]
    async fn analyze_response(
        &mut self,
        response: &Result<Response, reqwest::Error>,
        process_type: &ProcessType,
        device: &mut Device,
        sending: bool,
    ) {
        match response {
            Ok(_response) => {
                let process_status = if sending {
                    ProcessStatus::Queued
                } else {
                    ProcessStatus::Stopped
                };

                match _response.status() {
                    StatusCode::OK => {
                        // set the receiver status to running
                        device.update_device_status(&process_status, process_type);

                        match process_type {
                            ProcessType::Generation => {
                                self.running_generators
                                    .insert(device.get_device_mac().to_string(), process_status);
                            }
                            ProcessType::Verification => {
                                self.running_generators
                                    .insert(device.get_device_mac().to_string(), process_status);
                            }
                            ProcessType::GeneratingAndVerification => {
                                self.running_generators.insert(
                                    device.get_device_mac().to_string(),
                                    process_status.clone(),
                                );

                                self.running_generators
                                    .insert(device.get_device_mac().to_string(), process_status);
                            }
                        }
                        if sending {
                            info!(
                                "Stream sent to device: {}, process type: {:?}",
                                device.get_device_mac(),
                                process_type
                            );
                        } else {
                            info!(
                                "device {} stopped stream {} successfully",
                                device.get_device_mac(),
                                self.get_stream_id()
                            );
                        }
                    }
                    _ => {
                        // set the receiver status to offline (generic error)
                        device.update_device_status(&ProcessStatus::Failed, process_type);

                        // add the device to the running devices list with a failed status
                        match process_type {
                            ProcessType::Generation => {
                                self.running_generators.insert(
                                    device.get_device_mac().to_owned(),
                                    ProcessStatus::Failed,
                                );
                            }
                            ProcessType::Verification => {
                                self.running_verifiers.insert(
                                    device.get_device_mac().to_owned(),
                                    ProcessStatus::Failed,
                                );
                            }
                            ProcessType::GeneratingAndVerification => {
                                self.running_generators.insert(
                                    device.get_device_mac().to_owned(),
                                    ProcessStatus::Failed,
                                );

                                self.running_generators.insert(
                                    device.get_device_mac().to_owned(),
                                    ProcessStatus::Failed,
                                );
                            }
                        }

                        if sending {
                            error!(
                                "Stream not sent to device: {} process type: {:?}",
                                device.get_device_mac(),
                                process_type
                            );
                        } else {
                            error!(
                                "device {} failed to stop stream {}",
                                device.get_device_mac(),
                                self.get_stream_id()
                            );
                        }
                    }
                }
            }

            Err(_error) => {
                error!("Connection {}", _error);

                // set the receiver status to offline (generic error)
                device.update_device_status(&ProcessStatus::Failed, process_type);

                // add the device to the running devices list with a failed status
                match process_type {
                    ProcessType::Generation => {
                        self.running_generators
                            .insert(device.get_device_mac().to_owned(), ProcessStatus::Failed);
                    }
                    ProcessType::Verification => {
                        self.running_verifiers
                            .insert(device.get_device_mac().to_owned(), ProcessStatus::Failed);
                    }
                    ProcessType::GeneratingAndVerification => {
                        self.running_generators
                            .insert(device.get_device_mac().to_owned(), ProcessStatus::Failed);

                        self.running_generators
                            .insert(device.get_device_mac().to_owned(), ProcessStatus::Failed);
                    }
                }
            }
        }
    }

    #[doc = r" ## Queue Stream
this will add the stream to the queue
## Arguments
* `queued_streams` - the list of queued streams by stream id
* `device_list` - the list of devices that are in the system
## Logs
* `Stream queued to start in {} seconds` - the delay in seconds before the stream starts (the delay is set by the user)"]
    pub async fn queue_stream(
        &mut self,
        queued_streams: &Mutex<Vec<String>>,
        device_list: &mut MutexGuard<'_,Vec<Device>>,
    ) -> i32 {
        if self.stream_status == StreamStatus::Running || self.stream_status == StreamStatus::Queued
        {
            return 0;
        }
        // log the start time
        info!("Stream queued to start in {} seconds", self.delay / 1000);

        // send the stream to the client to update the stream status to queued
        let connections = self.send_stream(true, device_list).await;

        // add the thread to the queued streams list
        if self.stream_status == StreamStatus::Sent {
            self.update_stream_status(StreamStatus::Queued);
            queued_streams
                .lock()
                .await
                .push(self.get_stream_id().clone());
        }
        connections
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
        device_list: &mut MutexGuard<'_,Vec<Device>>,
    ) -> StreamStatus {
        // stop the stream
        self.stop_stream(device_list).await;

        // remove the stream from the queued streams list
        let mut queue = queued_streams.lock().await;

        // remove the stream from the queued streams vector
        let index = queue.iter().position(|x| x == self.get_stream_id());
        if index.is_some() {
            queue.remove(index.unwrap());
            //return previous status
            return StreamStatus::Queued;
        }
        self.stream_status.clone()
    }

    #[doc = r" ## Update Stream Status
this is used to update the stream status (running, stopped, finished) and the start and end times of the stream if the stream is running or finished respectively
if the stream is stopped, the start and end times are set to None
and the last updated time is set to the current time all the time
## Arguments
* `status` - the new stream status"]
    fn update_stream_status(&mut self, status: StreamStatus) {
        if status == self.stream_status {
            return;
        }
        self.stream_status = status;
        self.last_updated = Utc::now();

        // update the start and end times (you can add a message about the stream and append it to the description field but this not needed for now)
        match self.stream_status {
            StreamStatus::Running => {
                self.start_time = Some(Utc::now());
            }
            StreamStatus::Finished => {
                self.end_time = Some(Utc::now());
            }
            _ => {
                self.start_time = None;
                self.end_time = None;
            }
        }
    }

    #[doc = r" ## Check Stream Status
this is used to check if the stream status is the same as the status passed
## Arguments
* `status` - the status to check against"]
    pub fn check_stream_status(&self, status: StreamStatus) -> bool {
        self.stream_status == status
    }

    pub fn get_stream_status(&self) -> &StreamStatus {
        &self.stream_status
    }

    #[doc = r" ## Get Stream Status Card
    this is used to get the stream status card for the stream which contains simple details about the stream (stream id, stream status, start time, end time, last updated, name)"]
    pub fn get_stream_status_card(&self) -> StreamStatusDetails {
        StreamStatusDetails {
            stream_id: self.stream_id.clone(),
            stream_status: self.stream_status.clone(),
            start_time: self.start_time,
            end_time: self.end_time,
            last_updated: self.last_updated,
            name: self.name.clone(),
        }
    }

    #[doc = r" ## Get Stream Details
this is used to get the stream details for the stream which contains all the details about the stream (stream id, delay, generators, verifiers, payload type, number of packets, payload length, burst delay, burst length, seed, broadcast frames, inter frame gap, time to live, transport layer protocol, name).
The Details are required and used by the systemAPI to be executed on the targeted devices"]
    pub fn get_stream_details(
        &self,
        delayed: bool,
        generators_macs: Vec<String>,
        verifiers_macs: Vec<String>,
    ) -> StreamDetails {
        StreamDetails {
            stream_id: self.get_stream_id().clone(),
            delay: if delayed { self.delay } else { 0 },
            generators: generators_macs,
            verifiers: verifiers_macs,
            payload_type: self.payload_type,
            number_of_packets: self.number_of_packets,
            payload_length: self.payload_length,
            burst_delay: self.burst_delay,
            burst_length: self.burst_length,
            seed: self.seed,
            broadcast_frames: self.broadcast_frames,
            inter_frame_gap: self.inter_frame_gap,
            time_to_live: self.time_to_live,
            transport_layer_protocol: self.transport_layer_protocol.clone() as u8,
            flow_type: self.flow_type.clone() as u8,
            check_content: self.check_content,
        }
    }

    pub fn get_stream_delay_seconds(&self) -> f64 {
        self.delay as f64 / 1000.0
    }

    #[doc = r" ## Update Stream
this is used to update the stream with the new details passed in the stream entry, ignoring the stream id and the stream status as they are not allowed to be changed by the user"]
    pub fn update(&mut self, stream: &StreamEntry) {
        self.name = stream.name.clone();
        self.description = stream.description.clone();
        self.delay = stream.delay;
        self.generators_ids = stream.generators_ids.clone();
        self.verifiers_ids = stream.verifiers_ids.clone();
        self.payload_type = stream.payload_type;
        self.number_of_packets = stream.number_of_packets;
        self.payload_length = stream.payload_length;
        self.burst_delay = stream.burst_delay;
        self.burst_length = stream.burst_length;
        self.seed = stream.seed;
        self.broadcast_frames = stream.broadcast_frames;
        self.inter_frame_gap = stream.inter_frame_gap;
        self.time_to_live = stream.time_to_live;
        self.transport_layer_protocol = stream.transport_layer_protocol.clone();
        self.flow_type = stream.flow_type.clone();
        self.check_content = stream.check_content;
        self.last_updated = Utc::now();
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
    Sent,
    Queued,
    Running,
    Finished,
    Error,
    Stopped,
}

impl ToString for StreamStatus {
    fn to_string(&self) -> String {
        match self {
            StreamStatus::Created => "Created".to_string(),
            StreamStatus::Sent => "Sent".to_string(),
            StreamStatus::Queued => "Queued".to_string(),
            StreamStatus::Running => "Running".to_string(),
            StreamStatus::Finished => "Finished".to_string(),
            StreamStatus::Error => "Error".to_string(),
            StreamStatus::Stopped => "Stopped".to_string(),
        }
    }
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
    Tcp,
    #[serde(rename = "UDP")]
    Udp,
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
