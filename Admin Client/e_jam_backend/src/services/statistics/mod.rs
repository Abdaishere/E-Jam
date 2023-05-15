use crate::models::statistics::{Generator, Verifier};
use apache_avro::from_value;
use kafka::consumer::{Consumer, FetchOffset};
use log::{error, info, warn};
use schema_registry_converter::blocking::{avro::AvroDecoder, schema_registry::SrSettings};
use std::{thread::sleep, time::Duration};

pub const NAMESPACE: &str = "com.ejam.systemapi.stats.SchemaRegistry";
pub const SCHEMA_REGISTRY_PORT: &str = "8081";
pub const MAIN_BROKER_PORT: &str = "9092";
pub const HOST: &str = "localhost";
pub const SLEEP_TIME: u64 = 5;
pub const FETCH_OFFSET: FetchOffset = FetchOffset::Earliest;
pub const GENERATOR_TOPIC: &str = "Generator";
pub const VERIFIER_TOPIC: &str = "Verifier";

pub fn run_generator_consumer() {
    let schema_registry_url = format!("http://{}:{}", HOST, SCHEMA_REGISTRY_PORT);
    let sr_settings = SrSettings::new(schema_registry_url);
    let decoder = AvroDecoder::new(sr_settings);

    let mut consumer: Consumer = loop {
        match Consumer::from_hosts(vec![format!("{}:{}", HOST, MAIN_BROKER_PORT)])
            .with_topic(GENERATOR_TOPIC.to_string())
            .with_fallback_offset(FETCH_OFFSET)
            .create()
        {
            Ok(consumer) => break consumer,
            Err(e) => {
                error!("{:?}", e);
                sleep(Duration::from_secs(SLEEP_TIME));
            }
        }
    };

    info!("Generator Consumer Connected to Kafka Broker");

    loop {
        for ms in consumer.poll().unwrap().iter() {
            for m in ms.messages() {
                // If the consumer receives an event, this block is executed
                //  println!("{:?}", str::from_utf8(m.value).unwrap());
                match decoder.decode(Some(m.value)) {
                    Ok(result) => match result.name {
                        Some(name) => {
                            info!("Name: {}", name.name);

                            match name.namespace {
                                Some(namespace) => match namespace.as_str() {
                                    NAMESPACE => {
                                        let value = from_value::<Generator>(&result.value).unwrap();
                                        info!("Value: {:?}", value);
                                    }
                                    _ => {
                                        warn!("Unknown namespace");
                                    }
                                },

                                None => {
                                    warn!("No namespace");
                                }
                            }
                        }
                        None => {
                            warn!("No name");
                        }
                    },
                    Err(e) => {
                        error!("{:?}", e);
                    }
                }
            }

            consumer.consume_messageset(ms).unwrap();
        }
    }
}

pub fn run_verifier_consumer() {
    let schema_registry_url = format!("http://{}:{}", HOST, SCHEMA_REGISTRY_PORT);
    let sr_settings = SrSettings::new(schema_registry_url);
    let decoder = AvroDecoder::new(sr_settings);

    let mut consumer: Consumer = loop {
        match Consumer::from_hosts(vec![format!("{}:{}", HOST, MAIN_BROKER_PORT)])
            .with_topic(VERIFIER_TOPIC.to_string())
            .with_fallback_offset(FETCH_OFFSET)
            .create()
        {
            Ok(consumer) => break consumer,
            Err(e) => {
                error!("{:?}", e);
                sleep(Duration::from_secs(SLEEP_TIME));
            }
        }
    };

    info!("Verifier Consumer Connected to Kafka Broker");

    loop {
        for ms in consumer.poll().unwrap().iter() {
            for m in ms.messages() {
                // If the consumer receives an event, this block is executed
                //  println!("{:?}", str::from_utf8(m.value).unwrap());
                match decoder.decode(Some(m.value)) {
                    Ok(result) => match result.name {
                        Some(name) => {
                            info!("Name: {}", name.name);

                            match name.namespace {
                                Some(namespace) => match namespace.as_str() {
                                    NAMESPACE => {
                                        let value = from_value::<Verifier>(&result.value).unwrap();
                                        info!("Value: {:?}", value);
                                    }
                                    _ => {
                                        warn!("Unknown namespace");
                                    }
                                },

                                None => {
                                    warn!("No namespace");
                                }
                            }
                        }
                        None => {
                            warn!("No name");
                        }
                    },
                    Err(e) => {
                        error!("{:?}", e);
                    }
                }
            }

            consumer.consume_messageset(ms).unwrap();
        }
    }
}
