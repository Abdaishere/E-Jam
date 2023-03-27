use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Generator {
    mac_address: String,
    stream_id: String,
    packets_sent: u64,
    packets_errors: u64,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Verifier {
    mac_address: String,
    stream_id: String,
    packets_correct: u64,
    packets_errors: u64,
    packets_dropped: u64,
    packets_out_of_order: u64,
}