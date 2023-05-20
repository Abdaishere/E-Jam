use chrono::{serde::ts_seconds, DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Generator {
    pub mac_address: String,
    pub stream_id: String,
    pub packets_sent: u64,
    pub packets_errors: u64,
    #[serde(with = "ts_seconds")]
    pub timestamp: DateTime<Utc>,
}

impl Generator {
    #[cfg(feature = "fake_data")]
    pub fn generate_fake_generator_data(id: String, mac: String) -> Generator {
        use chrono::{prelude::*, Duration};
        use fake::{Fake, Faker};
        use std::thread::sleep;
        let start_time = Utc::now();
        sleep(std::time::Duration::from_secs(5));
        let updates = start_time
            + Duration::seconds(
                Faker
                    .fake::<i64>()
                    .rem_euclid((Utc::now() - start_time).num_seconds()),
            );
        Generator {
            mac_address: mac,
            stream_id: id,
            packets_sent: (0..204800).fake::<u32>() as u64,
            packets_errors:(0..204800).fake::<u32>() as u64,
            timestamp: updates,
        }
    }
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
    #[serde(with = "ts_seconds")]
    pub timestamp: DateTime<Utc>,
}

impl Verifier {
    #[cfg(feature = "fake_data")]
    pub fn generate_fake_verifier_data(id: String, mac: String) -> Verifier {
        use chrono::{prelude::*, Duration};
        use fake::{Fake, Faker};
        use std::thread::sleep;
        let start_time = Utc::now();
        sleep(std::time::Duration::from_secs(5));
        let updates = start_time
            + Duration::seconds(
                Faker
                    .fake::<i64>()
                    .rem_euclid((Utc::now() - start_time).num_seconds()),
            );
        Verifier {
            mac_address: mac,
            stream_id: id,
            packets_correct: (0..204800).fake::<u32>() as u64,
            packets_errors: (0..204800).fake::<u32>() as u64,
            packets_dropped: (0..204800).fake::<u32>() as u64,
            packets_out_of_order: (0..204800).fake::<u32>() as u64,
            timestamp: updates,
        }
    }
}
