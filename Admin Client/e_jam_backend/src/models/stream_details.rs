use serde::{Deserialize, Serialize};

#[doc = r" # Stream Details
The StreamDetails struct is used to store the information about the stream that is sent to the device to start or queue the stream
## Values
* `stream_id` - A String that represents the id of the stream that is used to identify the stream in the device, must be alphanumeric, max is 3 bytes (36^3 = 46656)
* `delay` - A u64 that represents the time in ms that the stream will wait before starting
* `generators` - A Vec of String that has all the mac addresses of the devices that will generate the stream
* `verifiers` - A Vec of String that has all the mac addresses of the devices that will verify the stream
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
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct StreamDetails {
    pub stream_id: String,
    pub delay: u64,
    pub generators: Vec<String>,
    pub verifiers: Vec<String>,
    pub payload_type: u8,
    pub number_of_packets: u32,
    pub payload_length: u16,
    pub seed: u32,
    pub broadcast_frames: u32,
    pub inter_frame_gap: u32,
    pub time_to_live: u64,
    pub transport_layer_protocol: u8,
    pub flow_type: u8,
    pub check_content: bool,
}
