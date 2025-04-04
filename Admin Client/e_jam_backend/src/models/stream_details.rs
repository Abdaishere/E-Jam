use super::StreamStatus;
use chrono::{
    serde::{ts_seconds, ts_seconds_option},
    DateTime, Utc,
};
use serde::{Deserialize, Serialize};
use validator::Validate;

#[doc = r" # Stream Details
The StreamDetails struct is used to store the information about the stream that is sent to the device to start or queue the stream
## Values
- `Stream Id` - A String that represents the id of the stream that is used to identify the stream in the device
- `Delay` - A Number that represents the delay that will be used for the stream in ms
- `Time to Live` - A Number that represents the duration of the stream in ms
- `Inter Frame Gap` - A Number that represents the inter frame gap that will be used for the stream in ms
- `Generators` - A Vec of String that has all the mac addresses of the devices that will generate the stream
- `Verifiers` - A Vec of String that has all the mac addresses of the devices that will verify the stream
- `Number of Packets` - A Number that represents the number of packets that will be sent in the stream
- `Broadcast Frames` - A Number that represents the number of broadcast frames that will be sent in the stream
- `Payload Length` - A Number that represents the length of the payload that will be used in the stream
- `Payload Type` - A Number that represents the type of the payload that will be used in the stream (0, 1, 2)
- `Burst Length` - A Number that represents the number of packets that will be sent in a burst
- `Burst Delay` - A Number that represents the time in ms that will be waited between each burst
- `Seed` - A Number that represents the seed that will be used to generate the payload
- `Flow Type` - A Number that represents the flow type that will be used for the stream (0 = BtB, 1 = Bursts)
- `Transport Layer Protocol` - A Number that represents the transport layer protocol that will be used for the stream (0 = TCP, 1 = UDP)
- `Check Content` - A bool that represents if the content of the packets will be checked or not"]
#[derive(Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StreamDetails {
    pub stream_id: String,
    pub delay: u64,
    pub generators: Vec<String>,
    pub verifiers: Vec<String>,
    pub payload_type: u8,
    pub number_of_packets: u64,
    pub payload_length: u64,
    pub burst_length: u64,
    pub burst_delay: u64,
    pub seed: u64,
    pub broadcast_frames: u64,
    pub inter_frame_gap: u64,
    pub time_to_live: u64,
    pub transport_layer_protocol: u8,
    pub flow_type: u8,
    pub check_content: bool,
}

#[doc = r" # Stream Status Details
This is used to represent the status of the stream in the system only for the user to see the status of the stream
It is small and only has the information that is needed to represent the status of the stream
## Values
- `Name` - A String that represents the name of the stream
- `Stream Id` - A String that represents the id of the stream that is used to identify the stream in the device
- `Stream Status` - A StreamStatus that represents the state that the stream is in at any given time in the system
- `Last Updated` - A DateTime that represents the last time that the stream was updated
- `Start Time` - A DateTime that represents the time that the stream was started
- `End Time` - A DateTime that represents the time that the stream finishes/finished"]
#[derive(Validate, Serialize, Deserialize, Default, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StreamStatusDetails {
    #[doc = r" ## Name
    Name of the stream (used for clarification)."]
    #[serde(skip_deserializing)]
    pub name: String,

    #[doc = r" ## Stream ID
    This is the id of the stream that is used to identify the stream in the device.
    The stream id is generated by the server and is unique or can be given by the user (if the user gives the id it must be unique)."]
    #[serde(default, skip_deserializing)]
    pub stream_id: String,

    #[doc = r" ## Stream Status
    This is the state that the stream is in at any given time in the system (see the state machine below)
    ## see also
    The stream state machine: ./docs/stream_state_machine.png"]
    #[serde(default, skip_deserializing)]
    pub stream_status: StreamStatus,

    #[doc = r" ## Last Updated
    Last time that the stream was updated
    this is updated when the stream Status is updated by the server"]
    #[serde(with = "ts_seconds")]
    #[serde(default, skip_deserializing)]
    pub last_updated: DateTime<Utc>,

    #[doc = r" ## Start Time
    This is updated when the stream is started with the time the first device starts the stream
    This is an optional field and can be left empty and will be updated automatically when the stream is first started"]
    #[serde(default, skip_deserializing)]
    #[serde(with = "ts_seconds_option")]
    pub start_time: Option<DateTime<Utc>>,

    #[doc = r" ## End Time
    This is updated when the stream is finished with the time the last device finishes the stream
    This is an optional field and can be left empty and will be updated automatically when the stream is last finished or predicted to finish"]
    #[serde(default, skip_deserializing)]
    #[serde(with = "ts_seconds_option")]
    pub end_time: Option<DateTime<Utc>>,
}
