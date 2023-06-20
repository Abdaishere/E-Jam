use crate::models::statistics::{Generator, Verifier};
use apache_avro::from_value;
use kafka::consumer::{Consumer, FetchOffset};
use log::{debug, error};
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
pub const RETRY_SLEEP_TIME: u64 = 1;
const RETRIES: usize = 7;
pub const GENERATOR_TOPIC: &str = "Generator";
pub const VERIFIER_TOPIC: &str = "Verifier";
const TIMEOUT: u128 = 600;

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
                debug!("Kafka Error {:?}", e);
                if counter == 0 {
                    error!("Kafka Error {:?}", e);
                    return Err(());
                }
                counter -= 1;
                sleep(Duration::from_secs(RETRY_SLEEP_TIME));
            }
        }
    };
    let mut time_counter = Instant::now();
    debug!("Generator Consumer Connected to Kafka Broker");
    let mut generators: LinkedList<Generator> = LinkedList::new();
    loop {
        let message = consumer.poll();
        if message.is_err() {
            debug!("Kafka Error  {:?}", message.as_ref().err());
            return Err(());
        }

        if message.is_ok() && message.as_ref().unwrap().is_empty() {
            if time_counter.elapsed().as_millis() > TIMEOUT {
                return Ok(generators);
            }
            continue;
        }

        for ms in message.unwrap().iter() {
            for m in ms.messages() {
                let result = decoder.decode(Some(m.value));
                if result.is_err() {
                    debug!("Kafka Error  {:?}", result.err().unwrap());
                    continue;
                }
                let result = result.unwrap();

                if result.name.is_none() {
                    debug!("No name");
                    continue;
                }

                let name = result.name.unwrap();
                debug!("Name: {}", name.name);
                if name.namespace.is_none() {
                    debug!("No namespace");
                    continue;
                }
                let namespace = name.namespace.unwrap();
                if namespace != NAMESPACE {
                    debug!("Unknown namespace");
                    continue;
                }

                let value = from_value::<Generator>(&result.value);
                match value {
                    Ok(value) => {
                        debug!("Stream ID: {}", value.stream_id);
                        if (stream_id.is_empty() || stream_id == value.stream_id)
                            && (mac_address.is_empty() || mac_address == value.mac_address)
                        {
                            debug!("Value: {:?}", value);
                            generators.push_back(value);
                        }
                    }
                    Err(e) => {
                        debug!("Kafka Error {:?}", e);
                    }
                }
            }

            let consumed = consumer.consume_messageset(ms);
            if consumed.is_err() {
                debug!("Kafka Error {:?}", consumed.err());
            }
        }

        if time_counter.elapsed().as_millis() > TIMEOUT {
            return Ok(generators);
        }

        time_counter = Instant::now();
    }
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
                debug!("Kafka Error {:?}", e);
                if counter == 0 {
                    error!("Kafka Error {:?}", e);
                    return Err(());
                }
                counter -= 1;
                sleep(Duration::from_secs(RETRY_SLEEP_TIME));
            }
        }
    };
    let mut time_counter = Instant::now();
    debug!("Verifier Consumer Connected to Kafka Broker");
    let mut verifiers: LinkedList<Verifier> = LinkedList::new();
    loop {
        let message = consumer.poll();

        if message.is_err() {
            debug!("Kafka Error {:?}", message.as_ref().err());
            continue;
        }

        if message.is_ok() && message.as_ref().unwrap().is_empty() {
            if time_counter.elapsed().as_millis() > TIMEOUT {
                return Ok(verifiers);
            }
            continue;
        }

        for ms in message.unwrap().iter() {
            for m in ms.messages() {
                let result = decoder.decode(Some(m.value));
                if result.is_err() {
                    debug!("Kafka Error {:?}", result.err().unwrap());
                    continue;
                }
                let result = result.unwrap();

                if result.name.is_none() {
                    debug!("No name");
                    continue;
                }

                let name = result.name.unwrap();
                debug!("Name: {}", name.name);
                if name.namespace.is_none() {
                    debug!("No namespace");
                    continue;
                }
                let namespace = name.namespace.unwrap();
                if namespace != NAMESPACE {
                    debug!("Unknown namespace");
                    continue;
                }

                let value = from_value::<Verifier>(&result.value);
                match value {
                    Ok(value) => {
                        if (stream_id.is_empty() || stream_id == value.stream_id)
                            && (mac_address.is_empty() || mac_address == value.mac_address)
                        {
                            debug!("Value: {:?}", value);
                            verifiers.push_back(value);
                        }
                    }
                    Err(e) => {
                        debug!("Kafka Error {:?}", e);
                    }
                }
            }

            let consumed = consumer.consume_messageset(ms);
            if consumed.is_err() {
                debug!("Kafka Error {:?}", consumed.err());
            }
        }

        if time_counter.elapsed().as_millis() > TIMEOUT {
            return Ok(verifiers);
        }

        time_counter = Instant::now();
    }
}
