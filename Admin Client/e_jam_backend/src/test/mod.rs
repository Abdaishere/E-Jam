use std::collections::HashMap;

use crate::models::{device::Device, AppState, StreamEntry};
use actix_web::web::Data;
use fake::{Fake, Faker};
use log::info;
use tokio::sync::Mutex;

const FAKE_DEVICES_COUNT: usize = 2e2 as usize;
const FAKE_STREAM_ENTRIES_COUNT: usize = 2e2 as usize;

pub async fn generate_fake_metrics(app_state: &Data<AppState>) {
    println!("Fake data feature enabled");

    // generate testing data
    generate_fake_devices(&app_state.device_list, FAKE_DEVICES_COUNT).await;

    generate_fake_stream_entries(
        &app_state.stream_entries,
        &app_state.device_list,
        FAKE_STREAM_ENTRIES_COUNT,
        &app_state.stream_id_counter,
        &app_state.stream_entries,
    )
    .await;
}

pub async fn generate_fake_stream_entries(
    stream_entries: &Mutex<HashMap<String, StreamEntry>>,
    devices_list: &Mutex<HashMap<String, Device>>,
    count: usize,
    stream_id_counter: &Mutex<usize>,
    streams_entries: &Mutex<HashMap<String, StreamEntry>>,
) {
    for _i in 0..count {
        let mut ver_mac: Vec<String> = vec![];
        let mut gen_mac: Vec<String> = vec![];
        let mut devices_list = devices_list.lock().await;
        loop {
            for (mac, device) in devices_list.iter_mut() {
                if Faker.fake() {
                    gen_mac.push(mac.to_owned());
                    device.add_gen_process();
                }
            }
            if !gen_mac.is_empty() {
                break;
            }
        }

        loop {
            for (mac, device) in devices_list.iter_mut() {
                if Faker.fake() {
                    ver_mac.push(mac.to_owned());
                    device.add_ver_processes();
                }
            }
            if !ver_mac.is_empty() {
                break;
            }
        }
        let stream: StreamEntry = StreamEntry::generate_fake_stream_entry(
            gen_mac,
            ver_mac,
            stream_id_counter,
            streams_entries,
        )
        .await;

        info!("Generated stream entry: {}", &stream.get_stream_id());
        stream_entries
            .lock()
            .await
            .insert(stream.get_stream_id().to_owned(), stream);
    }
}

pub async fn generate_fake_devices(devices_list: &Mutex<HashMap<String, Device>>, count: usize) {
    for _i in 0..count {
        let device: Device = Device::generate_fake_device().await;
        info!("Generated device: {}", &device.get_device_mac());
        devices_list
            .lock()
            .await
            .insert(device.get_device_mac().to_owned(), device);
    }
}
