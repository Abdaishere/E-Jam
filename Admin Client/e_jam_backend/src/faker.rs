use crate::models::{device::Device, StreamEntry};
use fake::{Fake, Faker};
use log::info;
use tokio::sync::Mutex;

pub async fn generate_fake_stream_entries(
    stream_entries: &Mutex<Vec<StreamEntry>>,
    devices_list: &Mutex<Vec<Device>>,
    count: usize,
    stream_id_counter: &Mutex<usize>,
    streams_entries: &Mutex<Vec<StreamEntry>>,
) {
    for _i in 0..count {
        let mut ver_mac: Vec<String> = vec![];
        for device in devices_list.lock().await.iter() {
            let pick: bool = Faker.fake();
            if pick {
                ver_mac.push(device.get_device_mac().clone());
            }
        }

        let mut gen_mac: Vec<String> = vec![];
        for device in devices_list.lock().await.iter() {
            let pick: bool = Faker.fake();
            if pick {
                gen_mac.push(device.get_device_mac().clone());
            }
        }
        let stream = StreamEntry::generate_fake_stream_entry(
            gen_mac,
            ver_mac,
            stream_id_counter,
            streams_entries,
        )
        .await;

        info!("Generated stream entry: {}", &stream.get_stream_id());
        stream_entries.lock().await.push(stream);
    }
}

pub async fn generate_fake_devices(devices_list: &Mutex<Vec<Device>>, count: usize) {
    for _i in 0..count {
        let device = Device::generate_fake_device().await;
        info!("Generated device: {}", &device.get_device_mac());
        devices_list.lock().await.push(device);
    }
}
