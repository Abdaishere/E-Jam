use chrono::Duration;
use log::{debug, error, info, warn};

use tokio::task::JoinHandle;
pub(crate) mod device;
pub(crate) mod process;
pub(crate) mod statistics;
pub(crate) mod stream_details;

pub use self::device::Device;
use self::process::{ProcessStatus, ProcessType};
use self::stream_details::{StreamDetails, StreamStatusDetails};
use chrono::{serde::ts_seconds, serde::ts_seconds_option, DateTime, Utc};
use lazy_static::lazy_static;
use nanoid::nanoid;
use regex::Regex;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::runtime::Runtime;
use tokio::sync::Mutex;
use validator::Validate;

lazy_static! {
    #[doc = r"Regex for the stream id that is used to identify the stream to user. URL-friendly max is 3 characters. Example of a valid stream id: 123, abc, 1a2, 1A2, 1aB, 1Ab, 1AB, _1A, _1a, _1_, _1a2, _1A2, _1aB, _1Ab, _1AB"]
    static ref STREAM_ID : Regex = Regex::new(r"^[A-Za-z0-9_~-]{3}$").unwrap();

    #[doc = r"Regex for the mac address of the device's mac address. Example of a valid mac address: 00:00:00:00:00:00, AA:AA:AA:AA:AA:AA"]
    static ref MAC_ADDRESS : Regex = Regex::new(r"^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$").unwrap();

    #[doc = r"Regex for the ip address of the device's ip address. Example of a valid ip address: 192.168.01.1, 192.168.1.00"]
    static ref IP_ADDRESS : Regex = Regex::new(r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$").unwrap();

    #[doc="Runtime that is used to spawn the threads that are used to send the requests to the systemAPI"]
    pub static ref RUNTIME: Runtime = Runtime::new().unwrap();
}

#[doc = " # handler
this is a holder for a tuple that contains the device details and the JoinHandle for the thread that is used to send the request to that device
## Values
* `connections` - A tuple that contains the device details `(ip,  mac, process_type)`
*  `handle` - the JoinHandle for the thread that is used to send the request to the device
"]
pub struct Handler {
    pub connections: (String, String, ProcessType),
    pub handle: JoinHandle<Result<reqwest::Response, reqwest::Error>>,
}

#[doc = r" # App State
The state of the Server that is shared between all the threads of the server
This is used to store the list of all the devices that are connected to the server, and the list of all the stream entries, and the list of all the streams that are currently Queued to be started on the devices
This is also used to store the counter for the stream id, that is used to identify the stream in the device
All the values are wrapped in a Mutex to allow for thread safe access to the values from all the threads of the server.
## Values
* `Streams Entries` - A HashMap of StreamEntry struct that represents the list of all the streams that are currently running on the devices (stream id, stream entry)
* `Queued Streams` - A HashMap of Strings that represents the list of all the streams that are currently Queued to be started on the devices
* `Device List` - A HashMap of Device struct that represents the list of all the devices that are currently connected to the server (mac address, device name and ip address)
* `Stream Id Counter` - A Number that represents the counter for the stream id that is used to identify the stream"]
pub struct AppState {
    pub stream_entries: Mutex<HashMap<String, StreamEntry>>,

    #[doc = r"List of all the streams that are currently Queued to be started on the devices (stream id, stream entry)"]
    pub queued_streams: Mutex<HashMap<String, DateTime<Utc>>>,

    #[doc = r"List of all the devices that are currently connected to the server (mac address, device name and ip address)"]
    pub device_list: Mutex<HashMap<String, Device>>,

    #[doc = r"Counter for the stream id that is used to identify the stream in the device"]
    pub stream_id_counter: Mutex<u32>,
}

impl Default for AppState {
    fn default() -> Self {
        AppState {
            stream_entries: Mutex::new(HashMap::new()),
            device_list: Mutex::new(HashMap::new()),
            queued_streams: Mutex::new(HashMap::new()),
            stream_id_counter: Mutex::new(0),
        }
    }
}

#[doc = r" ## Stream Entry
The Stream Entry struct is used to store the information about the stream with its status, and the status of the processes that are running the stream
## Values
- `Stream Id` - A String that represents the id of the stream that is used to identify the stream in the system
- `Name` - A String that represents the name of the stream (used for clarification)
- `Description` - A String that represents the description of the stream (used for clarification)
- `Last Updated` - A DateTime in Utc that represents the last time that the stream was updated (used for clarification)
- `Start Time` - A DateTime in Utc that represents the time that the stream will start (notified by the systemAPI)
- `End Time` - A DateTime in Utc that represents the time that the stream will end (is predicted by the server)
- `Delay` - A Number that represents the time in ms that the stream will wait before starting
- `Time To Live` - A Number that represents the time to live that will be used for the stream also known as the duration of the stream
- `Broadcast Frames` - A Number that represents the number of broadcast frames that will be sent in the stream
- `Generators Ids` - A Vec of Strings that represents the ids of the devices that will generate the stream (priority of ID when searching is in this order (LTR), mac, ip, name)
- `Verifiers Ids` - A Vec of Strings that represents the ids of the devices that will verify the stream (priority of ID when searching is in this order (LTR), mac, ip, name)
- `Number Of Packets` - A Number that represents the number of packets that will be sent in the stream
- `Flow Type` - A Flow Type Enumerator that represents the flow type that will be used for the stream (BtB, Bursts)
- `Payload Length` - A Number that represents the length of the payload that will be used in the stream
- `Payload Type` - A Number that represents the type of the payload that will be used in the stream (0, 1, 2)
- `Burst Length` - A Number that represents the length of the burst that will be used in the stream
- `Burst_Delay` - A Number that represents the delay between each burst that will be used in the stream
- `Seed` - A Number that represents the seed that will be used to generate the payload
- `Inter Frame Gap` - A Number that represents the time in ms that will be waited between each frame
- `Transport Layer Protocol` - A Transport Layer Protocol Enumerator that represents the transport layer protocol that will be used for the stream (TCP, UDP)
- `Check Content` - A boolean that represents if the content of the packets will be checked
- `Running Generators` - A HashMap (String, ProcessStatus) that represents the list of all the devices that are currently running the stream as a generator and their status (mac address of the card used in testing, Process Status) (used for clarification)
- `Running Verifiers` - A HashMap (String, ProcessStatus) that represents the list of all the devices that are currently running the stream as a verifier and their status (mac address of the card used in testing, Process Status) (used for clarification)
- `Stream Status` - A Stream Status Enumerator that represents the status of the stream (Check the Stream Status Enumerator for more information)
"]
#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StreamEntry {
    #[doc = r" ## Name
    Name of the stream (used for clarification).
    ## Constraints
    * The name must be less than 50 characters long"]
    #[validate(length(max = 50, message = "Name must be less than 50 characters long"))]
    #[serde(default)]
    name: String,

    #[doc = r" ## Description
    Description of the stream (used for clarification).
    ## Constraints
    * The description must be less than 255 characters long"]
    #[validate(length(
        max = 255,
        message = "Description must be less than 255 characters long"
    ))]
    #[serde(default)]
    description: String,

    #[doc = r" ## Last Updated
    Last time that the stream was updated.
    this is updated when the stream Status is updated by the server."]
    #[serde(with = "ts_seconds", default = "Utc::now", skip_deserializing)]
    last_updated: DateTime<Utc>,

    #[doc = r" ## Start Time
    This is updated when the stream is started with the time the first device starts the stream.
    This is an optional field and can be left empty and will be updated automatically when the stream is first started."]
    #[serde(default, skip_deserializing)]
    #[serde(with = "ts_seconds_option")]
    start_time: Option<DateTime<Utc>>,

    #[doc = r" ## End Time
    This is updated when the stream is finished with the time the last device finishes the stream.
    This is an optional field and can be left empty and will be updated automatically by the server as a prediction when the stream will end."]
    #[serde(default, skip_deserializing)]
    #[serde(with = "ts_seconds_option")]
    end_time: Option<DateTime<Utc>>,

    #[doc = r" ## Delay
    This the delay in ms that the stream will wait before starting it
    (can be 0 for no delay, or to force start the stream).
    ## Constraints
    * Must be greater than or equal to 0"]
    #[serde(default)]
    #[validate(range(min = 0, message = "Delay must be greater than or equal to 0"))]
    delay: u64,

    #[doc = r" ## Stream ID
    This is the id of the stream that is used to identify the stream in the device. Must be URL-friendly. Length is 3 characters.
    The stream id is generated by the server, and is unique or can be given by the user (if the user gives the id, it must be unique).
    ## Constraints
    * Must be given (length is 3)
    * Must be URL-friendly ([\w] by user, [A-Za-z0-9_~] by the server)
    * check the regex `STREAM_ID` for more details on the constraints"]
    #[validate(regex(
        path = "STREAM_ID",
        message = "Stream ID must be URL-friendly and 3 characters long"
    ))]
    #[serde(default)]
    stream_id: String,

    #[doc = r" ## Generators IDs
    This is the list of all the devices that will generate the stream insured by the user
    (priority of ID when searching a device is in this order (LTR), mac, ip, name).
    ## Constraints
    * Must be given (min length is 1)"]
    #[validate(length(min = 1, message = "Number of Generators must be greater than 0"))]
    generators_ids: Vec<String>,

    #[doc = r" ## Verifiers IDs
    This is the list of all the devices that will verify the stream insured by the user
    (priority of ID when searching a device is in this order (LTR), mac, ip, name).
    ## Constraints
    * Must be given (min length is 1)"]
    #[validate(length(min = 1, message = "Number of Verifiers must be greater than 0"))]
    verifiers_ids: Vec<String>,

    #[doc = r" ## Payload Type
    This is the type of payload that will be used during the stream (IPV4, IPV6, Random Bytes),
    0 for IPV4, 1 for IPV6 or 2 for Random Bytes.
    ## Constraints
    * Must be 0, 1 or 2"]
    #[validate(range(
        min = 0,
        max = 2,
        message = "Payload Type must be 0 for IPV4, 1 for IPV6 or 2 for Random Bytes"
    ))]
    #[serde(default)]
    payload_type: u8,

    #[doc = r" ## Burst Length
    This is the length of the burst that will be generated in the stream (in ms)
    ## Constraints
    * Must be greater than or equal to 0"]
    #[validate(range(min = 0, message = "Burst Length must be greater than or equal to 0"))]
    #[serde(default)]
    burst_length: u64,

    #[doc = r" ## Burst Delay
    This is the delay between bursts that will be generated in the stream (in ms)
    ## Constraints
    * Must be greater than or equal to 0"]
    #[validate(range(min = 0, message = "Burst Delay must be greater than or equal to 0"))]
    #[serde(default)]
    burst_delay: u64,

    #[doc = r" ## Number of Packets
    This is the number of packets that will be sent during the stream execution (0 for infinite)
    ## Constraints
    * Must be greater than or equal to 0"]
    #[validate(range(
        min = 0,
        message = "Number of Packets must be greater than or equal to 0"
    ))]
    #[serde(default)]
    number_of_packets: u64,

    #[doc = r" ## Payload Length
    This is the length of the payload that will be used in the stream
    ## Constraints
    * Must be between 0 and 1500"]
    #[validate(range(
        min = 0,
        max = 1500,
        message = "Payload Length must be between 0 and 1500"
    ))]
    #[serde(default)]
    payload_length: u64,

    #[doc = r" ## Seed
    This is the seed that will be used to generate the packets during the stream execution
    ## Constraints
    * Must be greater than or equal to 0"]
    #[validate(range(min = 0, message = "Seed must be greater than or equal to 0"))]
    #[serde(default)]
    seed: u64,

    #[doc = r" ## Broadcast Frames
    This is the number of broadcast frames that will be sent during the stream execution (also known as Broadcast Frames Frequency).
    Send broadcast frames every broadcast_frames.
    ## Constraints
    * Must be greater than or equal to 0"]
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
    * Must be greater than or equal to 0"]
    #[validate(range(
        min = 0,
        message = "Inter Frame Gap must be greater than or equal to 0"
    ))]
    #[serde(default)]
    inter_frame_gap: u64,

    #[doc = r" ## Time to Live
    This is the time the stream will live for in the device (also called Duration).
    time to live in milliseconds (0 for infinite)
    ## Constraints
    * Must be greater than or equal to 0"]
    #[validate(range(min = 0, message = "Time to Live must be greater than or equal to 0"))]
    time_to_live: u64,

    #[doc = r" ## Transport Layer Protocol
    This is the transport layer protocol that will be used to send the packets in the stream (TCP, UDP).
    ## Constraints
    * Must be TCP, UDP"]
    #[serde(default)]
    transport_layer_protocol: TransportLayerProtocol,

    #[doc = r" ## Flow Type
    This is the Type of flow that will be used to send the packets in the stream (BtB, Burst).
    ## Constraints
    * Must be BtB, Burst"]
    #[serde(default)]
    flow_type: FlowType,

    #[doc = r" ## Check Content
    This is the boolean that will be used to determine if the verifier should
    check the content of the payload or not.
    ## Constraints
    * Must be boolean"]
    #[serde(default)]
    check_content: bool,

    #[doc = r" ## Running Generators
    This is the HashMap of all the Processes that are generating the stream (mac_address of the device, process status)"]
    #[serde(default, skip_deserializing)]
    running_generators: HashMap<String, ProcessStatus>,

    #[doc = r" ## Running Verifiers
    This is the HashMap of all the Processes that are verifying the stream (mac_address of the device, process status)"]
    #[serde(default, skip_deserializing)]
    running_verifiers: HashMap<String, ProcessStatus>,

    #[doc = r" ## Stream Status
    This is the state that the stream is in at any given time in the system, which is used to determine what to do with the stream.
    ## see also
    The stream state machine: ./docs/stream_state_machine.png"]
    #[serde(default, skip_deserializing)]
    stream_status: StreamStatus,
}

#[doc = r" # Implementation of the StreamEntry struct that contains all the information about the stream and the functions that are used to manipulate the stream"]
impl StreamEntry {
    #[doc = r" ## Generate New Stream ID
    This function is used to generate a new id for the stream and check if the id is unique.
    The function uses the nanoid crate to generate a random id of length 3.
    The Id is random to lower the chances of having the same id for two different streams (reducing hits).
    In other words being random is less predictable than being sequential and the user adds random Ids (act like the user).
    ## Arguments
    * `stream_id_counter` - How many stream ids have been generated so far
    * `streams_entries` - A reference to a Mutex for Vec of StreamEntry that is used to check if the id of the stream is unique"]
    pub async fn generate_stream_id(
        &mut self,
        stream_id_counter: &Mutex<u32>,
        streams_entries: &Mutex<HashMap<String, StreamEntry>>,
    ) {
        debug!("Generating stream id for stream");
        loop {
            let id = nanoid!(3);
            debug!("Checking if stream id {} is unique", id);
            let streams_entries_lock = streams_entries.lock().await;
            let checker = streams_entries_lock.get(&id);

            match checker {
                Some(stream) => {
                    debug!(
                        "Stream ID {} already used by stream {}, generating new id",
                        id, stream.name
                    );
                    continue;
                }
                None => {
                    debug!("Stream ID {} is unique", id);
                    let mut generated_stream_ids_counter = stream_id_counter.lock().await;

                    *generated_stream_ids_counter += 1;
                    info!(
                        "Generated stream id {}, total ids generated {}",
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
    * `device_mac` - The mac address of the device used in the stream that has Started
    * `device_list` - A reference to a Mutex for Vec of Device struct that contains all the devices that are connected to the server"]
    pub async fn notify_process_running(
        &mut self,
        device_mac: &str,
        device_list: &Mutex<HashMap<String, Device>>,
    ) {
        let device = Device::find_device(device_mac, device_list).await;

        match device {
            Some(device) => {
                /*
                check if the device is a generator
                if it is, mark the generator as Running
                special case if the device is notifying after the stream has been sent and before analyzing the stream status (too early notification)
                */
                if self.stream_status == StreamStatus::Sent {
                    self.running_generators
                        .insert(device_mac.to_string(), ProcessStatus::Queued);
                }

                let process = self.running_generators.get(device_mac);

                if process.is_some() {
                    self.running_generators
                        .get_mut(device_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Running);

                    // then update the device status to Running
                    device_list
                        .lock()
                        .await
                        .get_mut(&device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Running, &ProcessType::Generation);
                } else {
                    warn!("Generator not found");
                }

                /*
                check if the device is a verifier
                if it is, mark the verifier as Running
                special case if the device is notifying after the stream has been sent and before analyzing the stream status (too early notification)
                */
                if self.stream_status == StreamStatus::Sent {
                    self.running_verifiers
                        .insert(device_mac.to_string(), ProcessStatus::Queued);
                }

                let process = self.running_verifiers.get(device_mac);
                if process.is_some() {
                    self.running_verifiers
                        .get_mut(device_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Running);

                    // then update the device status to Running
                    device_list
                        .lock()
                        .await
                        .get_mut(&device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Running, &ProcessType::Verification);
                } else {
                    warn!("Verifier not found");
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
    This will update the stream status according to the devices that are still running
    if there are no devices left, the stream status will be set to stopped
    if there are devices left, the stream status will be set to finished
    ## Arguments
    * `device_mac` - The mac address of the device used in the stream that has finished
    * `device_list` - A reference to a Mutex for Vec of Device struct that contains all the devices that are connected to the server"]
    pub async fn notify_process_completed(
        &mut self,
        device_mac: &str,
        device_list: &Mutex<HashMap<String, Device>>,
    ) {
        /*
        check if there are any devices left in the running streams list for this stream id
        if there are no devices left, remove the stream from the running streams list and set the stream status to stopped
        if there are devices left, set the stream status to finished and remove the device from the running streams list

        check if the device is a generator
        if it is, mark the generator as completed
        */

        let device = Device::find_device(device_mac, device_list).await;

        match device {
            Some(device) => {
                /*
                check if the device is a generator
                if it is, mark the generator as completed
                special case if the device is notifying after the stream has been sent and before analyzing the stream status (too early notification)
                */
                if self.stream_status == StreamStatus::Sent {
                    self.running_generators
                        .insert(device_mac.to_string(), ProcessStatus::Running);
                }

                let process = self.running_generators.get(device_mac);

                if process.is_some() {
                    self.running_generators
                        .get_mut(device_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Completed);

                    // then check if there are any other process running in the device
                    // if there are no other generators running, set the DeviceStatus to Idle
                    device_list
                        .lock()
                        .await
                        .get_mut(&device)
                        .unwrap()
                        .update_device_status(&ProcessStatus::Completed, &ProcessType::Generation);
                } else {
                    warn!("Generator not found");
                }

                /*
                check if the device is a verifier
                if it is, mark the verifier as completed
                special case if the device is notifying after the stream has been sent and before analyzing the stream status (too early notification)
                */
                if self.stream_status == StreamStatus::Sent {
                    self.running_verifiers
                        .insert(device_mac.to_string(), ProcessStatus::Running);
                }

                let process = self.running_verifiers.get(device_mac);
                if process.is_some() {
                    self.running_verifiers
                        .get_mut(device_mac)
                        .unwrap()
                        .clone_from(&ProcessStatus::Completed);

                    // then check if there are any other process running in the device
                    // if there are no other generators running, set the DeviceStatus to Idle
                    device_list
                        .lock()
                        .await
                        .get_mut(&device)
                        .unwrap()
                        .update_device_status(
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

        let working_generators = self
            .running_generators
            .values()
            .filter(|x| **x == ProcessStatus::Running || **x == ProcessStatus::Queued)
            .count();

        let working_verifiers = self
            .running_verifiers
            .values()
            .filter(|x| **x == ProcessStatus::Running || **x == ProcessStatus::Queued)
            .count();

        if finished_generators + finished_verifiers > 0
            && working_generators + working_verifiers == 0
        {
            self.update_stream_status(StreamStatus::Finished);
        } else if working_generators + working_verifiers == 0 {
            self.update_stream_status(StreamStatus::Stopped);
        }
    }

    #[doc = r" ## Send Stream
    The send_stream function is used to send the stream to the devices that will generate or verify the stream
    ## Arguments
    * `delayed` - A bool that represents if the stream will be delayed or not
    * `device_list` - A reference to a Mutex for Vec of Device that contains all the devices that are connected to the server
    ## Returns
    * `Vec<Handler>` - A vector of Handler struct that contains the result of the requests sent to the devices with device info and join handle for the request"]
    pub async fn send_stream(
        &mut self,
        delayed: bool,
        device_list: &Mutex<HashMap<String, Device>>,
    ) -> Vec<Handler> {
        /*
            send the start request to all the senders and receivers
            if the request is successful, add the device to the running devices list
            if the request fails, set the device status to offline
            NOTE: if the device has multiple MACs, the request will be sent to all the MACs in the device and the device will be added to the running devices list
        */
        let mut target_devices_pool: HashMap<String, Vec<(String, ProcessType)>> = HashMap::new();

        let mut verifiers_macs: Vec<String> = Vec::new();
        for name in &self.verifiers_ids {
            let receiver = Device::find_device(name, device_list).await;
            if receiver.is_none() {
                warn!("Device not found: {}, skipping", name);
                continue;
            }
            let receiver = receiver.unwrap();

            let (ip_address, _, mac) = device_list
                .lock()
                .await
                .get(&receiver)
                .unwrap()
                .get_device_info_tuple();

            verifiers_macs.push(mac);

            // add the device to the list of devices that need to receive the request if it already exists, it will be overwritten
            if target_devices_pool.contains_key(&ip_address) {
                target_devices_pool
                    .get_mut(&ip_address)
                    .unwrap()
                    .push((receiver, ProcessType::Verification));
            } else {
                target_devices_pool.insert(
                    ip_address.to_owned(),
                    vec![(receiver, ProcessType::Verification)],
                );
            }
        }

        let mut generators_macs: Vec<String> = Vec::new();
        for name in &self.generators_ids {
            let receiver = Device::find_device(name, device_list).await;
            if receiver.is_none() {
                warn!("Device not found: {}, skipping", name);
                continue;
            }

            let receiver = receiver.unwrap();

            let (ip_address, _, mac) = device_list
                .lock()
                .await
                .get(&receiver)
                .unwrap()
                .get_device_info_tuple();

            generators_macs.push(mac);

            // add the device to the list of devices that need to receive the request if it already exists, it will be overwritten
            if target_devices_pool.contains_key(&ip_address) {
                target_devices_pool
                    .get_mut(&ip_address)
                    .unwrap()
                    .push((receiver, ProcessType::Generation));
            } else {
                target_devices_pool.insert(
                    ip_address.to_owned(),
                    vec![(receiver, ProcessType::Generation)],
                );
            }
        }

        self.update_stream_status(StreamStatus::Sent);

        let stream_details = self.get_stream_details(delayed, generators_macs, verifiers_macs);
        self.send_stream_to_devices(target_devices_pool, device_list, stream_details)
            .await
    }

    #[doc = r" ## Send Stream To Devices
    The send_stream_to_devices function is used to send the stream to the devices that will generate and verify the stream and return a list of JoinHandles
    ## Arguments
    * `target_devices_pool` - A HashMap that contains the IP address of the devices as keys and a Vec of tuples that contain the index of the device in the device list and the ProcessType as values
    * `device_list` - A reference to a Mutex for Vec of Device that contains all the devices that are connected to the server
    * `stream_details` - A StreamDetails struct that contains the details of the stream
    ## Returns
    * `Vec<Handler>` - A list of JoinHandles that can be used to wait for the threads to finish"]
    pub async fn send_stream_to_devices(
        &self,
        target_devices_pool: HashMap<String, Vec<(String, ProcessType)>>,
        device_list: &Mutex<HashMap<String, Device>>,
        stream_details: StreamDetails,
    ) -> Vec<Handler> {
        let mut handles: Vec<Handler> = Vec::with_capacity(target_devices_pool.len());
        let stream_id = stream_details.stream_id.clone();
        let stream_details_json =
            serde_json::to_string(&stream_details).expect("Failed to serialize stream details");

        for (_, processes) in target_devices_pool.into_iter() {
            // the processes to the list of handles for each process type
            for (receiver, process) in processes.into_iter() {
                // get the device from the device list
                let device_list = device_list.lock().await;
                let device = device_list.get(&receiver).unwrap();

                // send the stream to the device and get the handle for the request
                let handle = device.send_stream(&stream_id, &stream_details_json);
                let (ip, _, mac) = device.get_device_info_tuple().to_owned();

                // get the info of device (ip,  mac, process_type)
                let connections = (ip, mac, process);

                // add the handle to the list of handles
                handles.push(Handler {
                    connections: connections.clone(),
                    handle,
                });
            }
        }
        handles
    }

    #[doc = r" ## Stop Stream
    Get the list of devices that are running the stream and send a stop request to all of them and return a list of JoinHandles
    ## Arguments
    * `device_list` - the list of devices that are running the stream
    ## Returns
    * `Vec<Handler>` - A list of JoinHandles that can be used to wait for the threads to finish"]
    pub async fn stop_stream(
        &mut self,
        device_list: &Mutex<HashMap<String, Device>>,
    ) -> Vec<Handler> {
        /*
        send the stop request to all the devices that are running the stream
        if the request is successful, set the device status to idle
        if the request fails, set the device status to offline
        */
        info!("Stopping stream {}...", self.get_stream_id());
        let mut target_devices_pool: HashMap<String, (String, ProcessType)> = HashMap::new();

        // stop the generators
        for target_process in &self.running_generators {
            // find the device in the device list
            let key = Device::find_device(target_process.0, device_list).await;
            if key.is_none() {
                warn!(
                    "Could not Stop Generator: {} (Not found), skipping",
                    target_process.0
                );
                continue;
            }

            target_devices_pool.insert(
                target_process.0.to_string(),
                (key.unwrap(), ProcessType::Generation),
            );
        }

        for target_process in &self.running_verifiers {
            // find the device in the device list
            let index = Device::find_device(target_process.0, device_list).await;
            if index.is_none() {
                warn!(
                    "Could not Stop Verifier: {} (Not found), skipping",
                    target_process.0
                );
                continue;
            }

            // if the device is also running the generation process, set the process type to GeneratingAndVerification
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

        self.stop_stream_on_devices(target_devices_pool, device_list)
            .await
    }

    #[doc = r" ## Stop Stream On Devices
    The stop_stream_on_devices function is used to send the stop request to the devices that are running the stream and return a list of JoinHandles
    ## Arguments
    * `target_devices_pool` - A HashMap that contains the IP address of the devices as keys and a tuple that contain the index of the device in the device list and the ProcessType as values
    * `device_list` - A reference to a Mutex for Vec of Device that contains all the devices that are connected to the server
    ## Returns
    * `Vec<Handler>` - A list of JoinHandles that can be used to wait for the threads to finish"]
    pub async fn stop_stream_on_devices(
        &self,
        target_devices_pool: HashMap<String, (String, ProcessType)>,
        device_list: &Mutex<HashMap<String, Device>>,
    ) -> Vec<Handler> {
        let mut handles: Vec<Handler> = Vec::with_capacity(target_devices_pool.len());

        for (_, (mac, process_type)) in target_devices_pool.into_iter() {
            // get the device from the device list
            let device_list = device_list.lock().await;
            let device = device_list.get(&mac).unwrap();

            // send the stop request to the device and get the handle for the request
            let handle = device.stop_stream(self.get_stream_id());
            let (ip, _, mac) = device.get_device_info_tuple().to_owned();

            // the info is (ip, mac, process_type)
            let connections = (ip, mac, process_type);

            // add the handle to the list of handles
            handles.push(Handler {
                connections,
                handle,
            });
        }

        handles
    }

    #[doc = r" ## Analyze Response
    The analyze_response function is used to analyze the response of the request sent to the device weather it is a start or stop request and update the device status accordingly
    If the request failed, the device status will be set to offline (generically)
    ## Arguments
    * `info` - A tuple that contains the IP address of the device, the MAC address of the device and the ProcessType.
    * `response` - The response of the request sent to the device
    * `device_list` - A reference to a Mutex for Vec of Device that contains all the devices that are connected to the server
    * `sending` - A boolean that indicates if the request is a start request or a stop request
    ## Returns
    * `Result<(), ()>` - Returns Ok if the request was successful and Err if the request failed"]
    pub async fn analyze_device_response(
        &mut self,
        (_, mac, process_type): (String, String, ProcessType),
        response: Result<reqwest::Response, reqwest::Error>,
        device_list: &Mutex<HashMap<String, Device>>,
        sending: bool,
    ) -> Result<(), ()> {
        let mut device = device_list.lock().await;
        let device = device.get_mut(&mac).unwrap();

        match response {
            Ok(_response) => {
                match _response.status() {
                    StatusCode::OK => {
                        let process_status = if sending {
                            ProcessStatus::Queued
                        } else {
                            ProcessStatus::Stopped
                        };

                        info!(
                            "request sent to device {}, {:?}",
                            device.get_device_mac(),
                            process_status
                        );

                        // set the receiver status to process_status
                        device.update_device_status(&process_status, &process_type);

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
                                    process_status.to_owned(),
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

                        return Ok(());
                    }
                    _ => {
                        info!(
                            "Stream failed to send to device: {}, process type: {:?}",
                            device.get_device_mac(),
                            process_type
                        );
                        // set the receiver status to offline (generic error)
                        device.update_device_status(&ProcessStatus::Failed, &process_type);

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
                error!("Connection Error: {}", _error);

                // set the receiver status to offline (generic error)
                device.update_device_status(&ProcessStatus::Failed, &process_type);

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

        Err(())
    }

    pub fn get_stream_id(&self) -> &String {
        &self.stream_id
    }
    #[doc = " ## Update Received Devices Result
    This function updates the status of the devices that received the stream and returns the number of devices that received the stream successfully
    ## Arguments
    * `results` - A vector of Result<(), ()> that contains the result of the requests sent to all the devices
    * `sending` - A boolean that indicates if the request is a start request or a stop request
    ## Returns
    * `i32` - Returns the number of devices that received the stream successfully"]
    pub async fn update_received_devices_result(
        &mut self,
        results: Vec<Result<(), ()>>,
        sending: bool,
    ) -> i32 {
        let mut devices_received = 0;
        for result in results.into_iter() {
            match result {
                Ok(_) => devices_received += 1,
                Err(_) => continue,
            }
        }

        if sending {
            /*
            If the number of devices that received the stream successfully is 0, then the stream status is set to Error (no devices are running the stream)
            If the number of devices that received the stream successfully is 1, then the stream status is set to Error (only one Process type is running the stream)
            If the number of devices that received the stream successfully is greater than 1, then the stream status is set to Queued (the stream is ready to run)
            */
            let mut devices_running = 0;
            for device in self.running_generators.iter() {
                if device.1 == &ProcessStatus::Queued {
                    devices_running += 1;
                    break;
                }
            }

            for device in self.running_verifiers.iter() {
                if device.1 == &ProcessStatus::Queued {
                    devices_running += 1;
                    break;
                }
            }

            if devices_running == 0 {
                self.update_stream_status(StreamStatus::Error);
                error!("No devices are running the stream");
            } else if devices_running == 1 {
                self.update_stream_status(StreamStatus::Error);
                error!("Only one Process type is running the stream");
            } else {
                info!("Stream sent to {} devices", devices_running);
                self.update_stream_status(StreamStatus::Queued);
            }
        } else {
            info!(
                "Stream {} stopped, {} devices received the stop request",
                self.get_stream_id(),
                devices_received
            );
            self.update_stream_status(StreamStatus::Stopped);
        }
        devices_received
    }

    #[doc = r" ## Queue Stream
    this will try to add the stream to the queue if the stream is not already queued or running
    ## Arguments
    * `device_list` - the list of devices that are in the system
    ## Returns
    * `Vec<Handler>` - Returns a vector of handlers that are used to send the stream to the devices"]
    pub async fn try_queue_stream(
        &mut self,
        device_list: &Mutex<HashMap<String, Device>>,
    ) -> Vec<Handler> {
        if self.stream_status == StreamStatus::Running || self.stream_status == StreamStatus::Queued
        {
            return vec![];
        }

        info!(
            "queueing stream {} to start in {} seconds",
            self.get_stream_id(),
            self.delay as f32 / 1000.0
        );

        // send the stream to the client to update the stream status to queued
        self.send_stream(true, device_list).await
    }

    #[doc = r" ## Remove Stream From Queue
    this will remove the stream from the queue if the stream is queued and not running
    ## Arguments
    * `device_list` - the list of devices that are in the system
    ## Returns
    * `Vec<Handler>` - Returns a vector of handlers that are used to send the stream to the devices"]
    pub async fn try_remove_stream_from_queue(
        &mut self,
        device_list: &Mutex<HashMap<String, Device>>,
    ) -> Vec<Handler> {
        if self.stream_status != StreamStatus::Queued {
            return vec![];
        }

        info!("removing stream {} from the queue", self.get_stream_id());

        // stop the stream
        self.stop_stream(device_list).await
    }

    #[doc = r" ## Update Stream Status
    this is used to update the stream status, and the start and end times of the stream if the stream is running or finished respectively.
    If the stream is stopped, the start and end times are set to None.
    and the last updated time is set to the current time all the time
    ## Arguments
    * `status` - the new stream status"]
    pub fn update_stream_status(&mut self, new_status: StreamStatus) {
        if new_status == self.stream_status && new_status != StreamStatus::Error {
            return;
        }

        self.stream_status = new_status;
        self.last_updated = Utc::now();

        // update the start and end time. (you can add a message about the stream and append it to the description field but this not needed for now)
        match self.stream_status {
            StreamStatus::Queued => {
                let duration = Duration::milliseconds(self.delay.try_into().unwrap_or_default());
                self.start_time = Some(Utc::now() + duration);
            }
            StreamStatus::Running => {
                self.start_time = Some(Utc::now());

                // If the time to live is not 0, then set the end time to the current time + the time to live
                // If the time to live is 0, then set the end time to the current time + the average time to deliver number_of_packets
                if self.time_to_live != 0 {
                    let duration =
                        Duration::milliseconds(self.time_to_live.try_into().unwrap_or_default());

                    self.end_time = Some(Utc::now() + duration);
                } else {
                    let duration =
                        Duration::milliseconds(self.number_of_packets as i64 / 1e7 as i64);

                    self.end_time = Some(Utc::now() + duration);
                }
            }
            StreamStatus::Finished => {
                self.end_time = Some(Utc::now());
            }
            StreamStatus::Sent => {
                self.start_time = None;
                self.end_time = None;
            }
            _ => {}
        }
    }

    pub fn check_stream_status(&self, status: StreamStatus) -> bool {
        self.stream_status == status
    }

    pub fn get_stream_status(&self) -> &StreamStatus {
        &self.stream_status
    }

    #[doc = r" ## Get Stream Status Card
    this is used to get the stream status card for the stream, which contains simple details about the stream.
    (stream id, stream status, start time, end time, last updated, name)"]
    pub fn get_stream_status_card(&self) -> StreamStatusDetails {
        StreamStatusDetails {
            stream_id: self.stream_id.to_owned(),
            stream_status: self.stream_status.to_owned(),
            start_time: self.start_time,
            end_time: self.end_time,
            last_updated: self.last_updated,
            name: self.name.to_owned(),
        }
    }

    #[doc = r" ## Get Stream Details
    this is used to get the stream details for the stream, which contains all the details about the stream required to execute it on the devices.
    The Details are used by the systemAPI to execute on the targeted devices"]
    pub fn get_stream_details(
        &self,
        delayed: bool,
        generators_macs: Vec<String>,
        verifiers_macs: Vec<String>,
    ) -> StreamDetails {
        StreamDetails {
            stream_id: self.stream_id.to_owned(),
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
            transport_layer_protocol: self.transport_layer_protocol.to_owned() as u8,
            flow_type: self.flow_type.to_owned() as u8,
            check_content: self.check_content,
        }
    }

    pub fn get_stream_delay_seconds(&self) -> f64 {
        self.delay as f64 / 1000.0
    }

    #[doc = r" ## Update Stream
    This is used to update the stream with the new details passed in the stream entry, 
    ignoring the stream id and the stream status as they are not allowed to be changed by the user."]
    pub fn update(&mut self, stream: &StreamEntry) {
        self.name = stream.name.to_owned();
        self.description = stream.description.to_owned();
        self.delay = stream.delay;
        self.generators_ids = stream.generators_ids.to_owned();
        self.verifiers_ids = stream.verifiers_ids.to_owned();
        self.payload_type = stream.payload_type;
        self.number_of_packets = stream.number_of_packets;
        self.payload_length = stream.payload_length;
        self.burst_delay = stream.burst_delay;
        self.burst_length = stream.burst_length;
        self.seed = stream.seed;
        self.broadcast_frames = stream.broadcast_frames;
        self.inter_frame_gap = stream.inter_frame_gap;
        self.time_to_live = stream.time_to_live;
        self.transport_layer_protocol = stream.transport_layer_protocol.to_owned();
        self.flow_type = stream.flow_type.to_owned();
        self.check_content = stream.check_content;
        self.last_updated = Utc::now();
    }

    #[cfg(feature = "fake_data")]
    pub async fn generate_fake_stream_entry(
        generators_macs: Vec<String>,
        verifiers_macs: Vec<String>,
        stream_id_counter: &Mutex<usize>,
        streams_entries: &Mutex<HashMap<String, StreamEntry>>,
    ) -> StreamEntry {
        use chrono::{prelude::*, Duration};
        use fake::{
            faker::internet::en::{UserAgent, Username},
            Fake, Faker,
        };

        let start_time = Utc::now() - Duration::minutes(40);
        let end_time = Utc::now() + Duration::minutes(40);

        let starts_at = start_time
            + Duration::seconds(
                Faker
                    .fake::<i64>()
                    .rem_euclid((Utc::now() - start_time).num_seconds()),
            );

        let updates = starts_at
            + Duration::seconds(
                Faker
                    .fake::<i64>()
                    .rem_euclid((Utc::now() - start_time).num_seconds()),
            );

        let ends_at = starts_at
            + Duration::seconds(
                Faker
                    .fake::<i64>()
                    .rem_euclid((end_time - Utc::now()).num_seconds()),
            );

        const DEV_STATUS: [ProcessStatus; 5] = [
            ProcessStatus::Queued,
            ProcessStatus::Running,
            ProcessStatus::Stopped,
            ProcessStatus::Completed,
            ProcessStatus::Failed,
        ];
        const STREAM_STATUSES: [StreamStatus; 6] = [
            StreamStatus::Created,
            StreamStatus::Queued,
            StreamStatus::Running,
            StreamStatus::Finished,
            StreamStatus::Error,
            StreamStatus::Stopped,
        ];
        const TRANSPORT_LAYER_PROTOCOL_ARR: [TransportLayerProtocol; 2] =
            [TransportLayerProtocol::Tcp, TransportLayerProtocol::Udp];
        const FLOW_TYPE_ARR: [FlowType; 2] = [FlowType::Bursts, FlowType::BackToBack];

        loop {
            let mut running_generators_map: HashMap<String, ProcessStatus> = HashMap::new();
            let mut running_verifiers_map: HashMap<String, ProcessStatus> = HashMap::new();

            for device in generators_macs.iter() {
                running_generators_map.insert(
                    device.to_owned(),
                    DEV_STATUS[(0..DEV_STATUS.len()).fake::<usize>()].to_owned(),
                );
            }

            for device in verifiers_macs.iter() {
                running_verifiers_map.insert(
                    device.to_owned(),
                    DEV_STATUS[(0..DEV_STATUS.len()).fake::<usize>()].to_owned(),
                );
            }

            let stream_stat =
                STREAM_STATUSES[(0..STREAM_STATUSES.len()).fake::<usize>()].to_owned();

            let flow_t = FLOW_TYPE_ARR[(0..FLOW_TYPE_ARR.len()).fake::<usize>()].to_owned();

            let transport_layer_prot = TRANSPORT_LAYER_PROTOCOL_ARR
                [(0..TRANSPORT_LAYER_PROTOCOL_ARR.len()).fake::<usize>()]
            .to_owned();

            let mut stream = StreamEntry {
                stream_id: "".to_string(),
                name: Username().fake::<String>(),
                description: UserAgent().fake::<String>(),
                delay: Faker.fake(),
                generators_ids: generators_macs.to_owned(),
                verifiers_ids: verifiers_macs.to_owned(),
                payload_type: (0..2).fake(),
                number_of_packets: Faker.fake(),
                payload_length: (64..1500).fake(),
                burst_delay: Faker.fake(),
                burst_length: Faker.fake(),
                seed: Faker.fake(),
                broadcast_frames: Faker.fake(),
                inter_frame_gap: Faker.fake(),
                time_to_live: Faker.fake(),
                transport_layer_protocol: transport_layer_prot,
                flow_type: flow_t,
                check_content: Faker.fake(),
                last_updated: updates,
                start_time: Some(starts_at),
                end_time: Some(ends_at),
                running_generators: running_generators_map,
                running_verifiers: running_verifiers_map,
                stream_status: stream_stat,
            };

            stream
                .generate_stream_id(stream_id_counter, streams_entries)
                .await;

            match stream.validate() {
                Ok(_) => return stream,
                Err(e) => println!("Invalid stream generated, trying again {}", e),
            }
        }
    }
}

#[doc = r"## Stream Status
This enum represents the status of the stream.
## Variants
* `Created` - the stream has been created
* `Sent` - the stream has been sent
* `Queued` - the stream is queued
* `Running` - the stream is running
* `Finished` - the stream has finished
* `Error` - the stream has encountered an error
* `Stopped` - the stream has been stopped
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

#[doc = r"## Transport Layer Protocol
This enum represents the transport layer protocol type.
## Variants
* `TCP` - the transport layer protocol is Transmission Control Protocol
* `UDP` - the transport layer protocol is User Data gram Protocol
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
This enum represents the flow type.
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
