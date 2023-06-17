use crate::models::statistics::{Generator, Verifier};
use crate::{
    models::{device::Device, AppState, StreamEntry},
    services::statistics::{
        GENERATOR_TOPIC, HOST, MAIN_BROKER_PORT, NAMESPACE, SCHEMA_REGISTRY_PORT, VERIFIER_TOPIC,
    },
};
use actix_web::web::Data;
use fake::{Fake, Faker};
use kafka::producer::{AsBytes, Producer, Record, RequiredAcks};
use log::error;
use log::info;
use schema_registry_converter::blocking::avro::AvroEncoder;
use schema_registry_converter::blocking::schema_registry::SrSettings;
use schema_registry_converter::schema_registry_common::SubjectNameStrategy;
use std::thread::sleep;
use std::{collections::HashMap, time::Duration};
use tokio::sync::Mutex;

const FAKE_DEVICES_COUNT: usize = 50;
const FAKE_STREAM_ENTRIES_COUNT: usize = 100;
pub const SLEEP_TIME: u64 = 30;
pub async fn generate_fake_metrics(app_state: &Data<AppState>) {
    info!("Fake data feature enabled");

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
    let mut devices_list = devices_list.lock().await;
    for _i in 0..count {
        let mut ver_mac: Vec<String> = vec![];
        let mut gen_mac: Vec<String> = vec![];
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
    let mut devices_list = devices_list.lock().await;
    for _i in 0..count {
        let device: Device = Device::generate_fake_device().await;
        info!("Generated device: {}", &device.get_device_mac());
        devices_list.insert(device.get_device_mac().to_owned(), device);
    }
}

// schemas should exist in the registry first
pub fn run_generator_faker(devices_list: Vec<Device>, streams_entries: Vec<StreamEntry>) {
    let schema_registry_url = format!("http://{}:{}", HOST, SCHEMA_REGISTRY_PORT);
    let sr_settings = SrSettings::new(schema_registry_url);
    let encoder = AvroEncoder::new(sr_settings);
    let subject = format!("{}.{}", NAMESPACE, GENERATOR_TOPIC);
    let strategy =
        SubjectNameStrategy::TopicRecordNameStrategy(GENERATOR_TOPIC.to_string(), subject);

    let mut producer: Producer = loop {
        match Producer::from_hosts(vec![format!("{}:{}", HOST, MAIN_BROKER_PORT)])
            .with_ack_timeout(Duration::from_secs(1))
            .with_required_acks(RequiredAcks::One)
            .create()
        {
            Ok(consumer) => break consumer,
            Err(_e) => {
                error!("Kafka Connection for Generator faker{:?}", _e);
                sleep(Duration::from_secs(SLEEP_TIME));
            }
        }
    };

    info!("fake data Generator for Generator type statistics connected to Kafka Broker");
    loop {
        // encode a new generator struct with fake data then send it to the kafka broker
        for device in devices_list.iter() {
            let pick: bool = Faker.fake();
            if pick {
                let mac = device.get_device_mac().to_owned();
                let id = loop {
                    let stream: Option<&StreamEntry> =
                        streams_entries.iter().find(|_| Faker.fake::<bool>());
                    match stream {
                        Some(stream) => {
                            break stream.get_stream_id().clone();
                        }
                        None => continue,
                    }
                };
                let fake_statics = Generator::generate_fake_generator_data(id.to_owned(), mac);
                info!("fake date for Generator: {:?}", &fake_statics);

                // convert the fake_statics to a Value type data for avro encoding
                let encoded_data = encoder.encode_struct(fake_statics, &strategy);
                match encoded_data {
                    Ok(data) => {
                        let record = Record {
                            key: id.as_bytes(),
                            value: data.as_bytes(),
                            topic: GENERATOR_TOPIC,
                            partition: 0,
                        };
                        let result = producer.send(&record);
                        match result {
                            Ok(_) => {
                                info!("Sent fake Generator data to Kafka Broker");
                            }
                            Err(e) => {
                                error!(
                                    "Failed to send fake Generator data to Kafka Broker: {:?}",
                                    e
                                );
                            }
                        }
                    }
                    Err(e) => {
                        error!("Failed to encode fake data: {:?}", e);
                    }
                }
            }
        }
        sleep(Duration::from_secs(SLEEP_TIME));
    }
}

pub fn run_verifier_faker(devices_list: Vec<Device>, streams_entries: Vec<StreamEntry>) {
    let schema_registry_url = format!("http://{}:{}", HOST, SCHEMA_REGISTRY_PORT);
    let sr_settings = SrSettings::new(schema_registry_url);
    let encoder = AvroEncoder::new(sr_settings);
    let subject = format!("{}.{}", NAMESPACE, VERIFIER_TOPIC);
    let strategy =
        SubjectNameStrategy::TopicRecordNameStrategy(VERIFIER_TOPIC.to_string(), subject);

    let mut producer: Producer = loop {
        match Producer::from_hosts(vec![format!("{}:{}", HOST, MAIN_BROKER_PORT)])
            .with_ack_timeout(Duration::from_secs(1))
            .with_required_acks(RequiredAcks::One)
            .create()
        {
            Ok(consumer) => break consumer,
            Err(_e) => {
                error!("Kafka Connection for Verifier faker{:?}", _e);
                sleep(Duration::from_secs(SLEEP_TIME));
            }
        }
    };

    info!("fake data Generator for Verifier type statistics connected to Kafka Broker");
    loop {
        // encode a new verifier struct with fake data then send it to the kafka broker
        for device in devices_list.iter() {
            let pick: bool = Faker.fake();
            if pick {
                let mac = device.get_device_mac().to_owned();
                let id = loop {
                    let stream: Option<&StreamEntry> =
                        streams_entries.iter().find(|_| Faker.fake::<bool>());
                    match stream {
                        Some(stream) => {
                            break stream.get_stream_id().clone();
                        }
                        None => continue,
                    }
                };
                let fake_statics = Verifier::generate_fake_verifier_data(id.to_owned(), mac);

                info!("fake date for verifier: {:?}", &fake_statics);

                // convert the fake_statics to a Value type data for avro encoding
                let encoded_data = encoder.encode_struct(fake_statics, &strategy);
                match encoded_data {
                    Ok(data) => {
                        let record = Record {
                            key: id.as_bytes(),
                            value: data.as_bytes(),
                            topic: VERIFIER_TOPIC,
                            partition: 0,
                        };
                        let result = producer.send(&record);
                        match result {
                            Ok(_) => {
                                info!("Sent fake Verifier stats to Kafka Broker");
                            }
                            Err(e) => {
                                error!(
                                    "Failed to send fake Verifier data to Kafka Broker: {:?}",
                                    e
                                );
                            }
                        }
                    }
                    Err(e) => {
                        error!("Failed to encode fake data: {:?}", e);
                    }
                }
            }
        }
        sleep(Duration::from_secs(SLEEP_TIME));
    }
}
