use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Generator {
    pub mac_address: String,
    pub stream_id: String,
    pub packets_sent: u64,
    pub packets_errors: u64,
}

impl Generator {
    #[cfg(feature = "fake_data")]
    pub fn generate_fake_generator_data(id: String, mac: String) -> Generator {
        use fake::{Fake, Faker};

        Generator {
            mac_address: mac,
            stream_id: id,
            packets_sent: Faker.fake::<u32>() as u64,
            packets_errors: Faker.fake::<u32>() as u64,
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
}

impl Verifier {
    #[cfg(feature = "fake_data")]
    pub fn generate_fake_verifier_data(id: String, mac: String) -> Verifier {
        use fake::{Fake, Faker};

        Verifier {
            mac_address: mac,
            stream_id: id,
            packets_correct: Faker.fake::<u32>() as u64,
            packets_errors: Faker.fake::<u32>() as u64,
            packets_dropped: Faker.fake::<u32>() as u64,
            packets_out_of_order: Faker.fake::<u32>() as u64,
        }
    }
}
