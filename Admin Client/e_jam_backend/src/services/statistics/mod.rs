use crate::models::statistics::{Generator, Verifier};
use apache_avro::from_value;
use kafka::consumer::{Consumer, FetchOffset};
use log::{error, info, warn};
use schema_registry_converter::blocking::{avro::AvroDecoder, schema_registry::SrSettings};
use std::{
    collections::LinkedList,
    thread::sleep,
    time::{Duration, Instant},
};
pub(crate) mod query;

pub const NAMESPACE: &str = "com.ejam.systemapi.stats.SchemaRegistry";
pub const SCHEMA_REGISTRY_PORT: &str = "8081";
pub const MAIN_BROKER_PORT: &str = "9092";
pub const HOST: &str = "localhost";
pub const SLEEP_TIME: u64 = 5;
pub const GENERATOR_TOPIC: &str = "Generator";
pub const VERIFIER_TOPIC: &str = "Verifier";
const RETRIES: usize = 6;
const TIMEOUT: u64 = 10;

pub fn run_generator_consumer(
    stream_id: &str,
    mac_address: &str,
    fetch_offset: FetchOffset,
) -> Result<LinkedList<Generator>, ()> {
    let schema_registry_url = format!("http://{}:{}", HOST, SCHEMA_REGISTRY_PORT);
    let sr_settings = SrSettings::new(schema_registry_url);
    let decoder = AvroDecoder::new(sr_settings);

    let mut counter = RETRIES;
    let mut consumer: Consumer = loop {
        match Consumer::from_hosts(vec![format!("{}:{}", HOST, MAIN_BROKER_PORT)])
            .with_topic(GENERATOR_TOPIC.to_string())
            .with_fallback_offset(fetch_offset)
            .create()
        {
            Ok(consumer) => break consumer,
            Err(e) => {
                error!("{:?}", e);
                if counter == 0 {
                    error!("{:?}", e);
                    return Err(());
                }
                counter -= 1;
                sleep(Duration::from_secs(SLEEP_TIME));
            }
        }
    };
    let mut time_counter = Instant::now();
    info!("Generator Consumer Connected to Kafka Broker");
    let mut generators: LinkedList<Generator> = LinkedList::new();
    loop {
        let message = consumer.poll();
        if message.is_err() {
            error!("{:?}", message.as_ref().err());
            return Err(());
        }
        for ms in message.unwrap().iter() {
            for m in ms.messages() {
                let result = decoder.decode(Some(m.value));
                if result.is_err() {
                    error!("{:?}", result.err().unwrap());
                    continue;
                }
                let result = result.unwrap();

                if result.name.is_none() {
                    warn!("No name");
                    continue;
                }

                let name = result.name.unwrap();
                info!("Name: {}", name.name);
                if name.namespace.is_none() {
                    warn!("No namespace");
                    continue;
                }
                let namespace = name.namespace.unwrap();
                if namespace != NAMESPACE {
                    warn!("Unknown namespace");
                    continue;
                }

                let value = from_value::<Generator>(&result.value);
                match value {
                    Ok(value) => {
                        info!("Stream ID: {}", value.stream_id);
                        if (stream_id.is_empty() || stream_id == value.stream_id)
                            && (mac_address.is_empty() || mac_address == value.mac_address)
                        {
                            info!("Value: {:?}", value);
                            generators.push_back(value);
                        }
                    }
                    Err(e) => {
                        error!("{:?}", e);
                    }
                }
            }

            let consumed = consumer.consume_messageset(ms);
            if consumed.is_err() {
                error!("{:?}", consumed.err());
            }
        }
        if time_counter.elapsed().as_secs() > TIMEOUT && !generators.is_empty() {
            break;
        }

        time_counter = Instant::now();
    }
    Ok(generators)
}

pub fn run_verifier_consumer(
    stream_id: &str,
    mac_address: &str,
    fetch_offset: FetchOffset,
) -> Result<LinkedList<Verifier>, ()> {
    let schema_registry_url = format!("http://{}:{}", HOST, SCHEMA_REGISTRY_PORT);
    let sr_settings = SrSettings::new(schema_registry_url);
    let decoder = AvroDecoder::new(sr_settings);

    let mut counter = RETRIES;
    let mut consumer: Consumer = loop {
        match Consumer::from_hosts(vec![format!("{}:{}", HOST, MAIN_BROKER_PORT)])
            .with_topic(VERIFIER_TOPIC.to_string())
            .with_fallback_offset(fetch_offset)
            .create()
        {
            Ok(consumer) => break consumer,
            Err(e) => {
                error!("{:?}", e);
                if counter == 0 {
                    error!("{:?}", e);
                    return Err(());
                }
                counter -= 1;
                sleep(Duration::from_secs(SLEEP_TIME));
            }
        }
    };
    let mut time_counter = Instant::now();
    info!("Verifier Consumer Connected to Kafka Broker");
    let mut verifiers: LinkedList<Verifier> = LinkedList::new();
    loop {
        let message = consumer.poll();

        if message.is_err() {
            error!("{:?}", message.as_ref().err());
            continue;
        }
        for ms in message.unwrap().iter() {
            for m in ms.messages() {
                let result = decoder.decode(Some(m.value));
                if result.is_err() {
                    error!("{:?}", result.err().unwrap());
                    continue;
                }
                let result = result.unwrap();

                if result.name.is_none() {
                    warn!("No name");
                    continue;
                }

                let name = result.name.unwrap();
                info!("Name: {}", name.name);
                if name.namespace.is_none() {
                    warn!("No namespace");
                    continue;
                }
                let namespace = name.namespace.unwrap();
                if namespace != NAMESPACE {
                    warn!("Unknown namespace");
                    continue;
                }

                let value = from_value::<Verifier>(&result.value);
                match value {
                    Ok(value) => {
                        if (stream_id.is_empty() || stream_id == value.stream_id)
                            && (mac_address.is_empty() || mac_address == value.mac_address)
                        {
                            info!("Value: {:?}", value);
                            verifiers.push_back(value);
                        }
                    }
                    Err(e) => {
                        error!("{:?}", e);
                    }
                }
            }

            let consumed = consumer.consume_messageset(ms);
            if consumed.is_err() {
                error!("{:?}", consumed.err());
            }
        }
        if time_counter.elapsed().as_secs() > TIMEOUT && !verifiers.is_empty() {
            break;
        }
        time_counter = Instant::now();
    }
    Ok(verifiers)
}
