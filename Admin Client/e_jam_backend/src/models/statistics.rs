use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Generator {
    pub mac_address: String,
    pub stream_id: String,
    pub packets_sent: u64,
    pub packets_errors: u64,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Verifier {
    pub mac_address: String,
    pub stream_id: String,
    pub packets_correct: u64,
    pub packets_errors: u64,
    pub packets_dropped: u64,
    pub packets_out_of_order: u64,
}
