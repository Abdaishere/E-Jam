use apache_avro::{ from_value};
use kafka::consumer::{Consumer, FetchOffset};
use schema_registry_converter::blocking::{avro::AvroDecoder, schema_registry::SrSettings};
use crate::models::statistics::{Generator, Verifier};



pub fn run_generator_consumer() {
    let schema_registry_url = "localhost:8081";
    let sr_settings = SrSettings::new(format!("http://{}", schema_registry_url));
    let decoder = AvroDecoder::new(sr_settings);

    let hosts = vec!["localhost:9092".to_owned()];
    let mut consumer: Consumer = loop  {
        match Consumer::from_hosts(hosts.clone())
        .with_topic("Generator".to_owned())
        .with_fallback_offset(FetchOffset::Earliest)
        .create() {
            Ok(v) => break v,
            Err(e) => {
                println!("Error: {:?}", e);
                continue;
            }
        }
    };
    

    println!("Generator Consumer Connected to Kafka Broker");

    loop {
        for ms in consumer.poll().unwrap().iter() {
            for m in ms.messages() {
                // If the consumer receives an event, this block is executed
                //  println!("{:?}", str::from_utf8(m.value).unwrap());
                match decoder.decode(Some(m.value)) {
                    Ok(result) => match result.name {
                        Some(name) => {
                            println!("Name: {}", name.name);

                            match name.namespace {
                                Some(namespace) => match namespace.as_str() {
                                    "org.kafka.avro" => {
                                        let value = from_value::<Generator>(&result.value).unwrap();
                                        println!("Value: {:?}", value);
                                    }
                                    _ => {
                                        println!("Unknown namespace");
                                    }
                                },

                                None => {
                                    println!("No namespace");
                                }
                            }
                        }
                        None => {
                            println!("No name");
                        }
                    },
                    Err(e) => {
                        println!("Error: {:?}", e);
                    }
                }
            }

            consumer.consume_messageset(ms).unwrap();
        }
    }
}


pub fn run_verifier_consumer(){
    let schema_registry_url = "localhost:8081";
    let sr_settings = SrSettings::new(format!("http://{}", schema_registry_url));
    let decoder = AvroDecoder::new(sr_settings);

    let hosts = vec!["localhost:9092".to_owned()];
    let mut consumer: Consumer = loop  {
        match Consumer::from_hosts(hosts.clone())
        .with_topic("Verifier".to_owned())
        .with_fallback_offset(FetchOffset::Earliest)
        .create() {
            Ok(v) => break v,
            Err(e) => {
                println!("Error: {:?}", e);
                continue;
            }
        }
    };
    

    println!("Verifier Consumer Connected to Kafka Broker");

    loop {
        for ms in consumer.poll().unwrap().iter() {
            for m in ms.messages() {
                // If the consumer receives an event, this block is executed
                //  println!("{:?}", str::from_utf8(m.value).unwrap());
                match decoder.decode(Some(m.value)) {
                    Ok(result) => match result.name {
                        Some(name) => {
                            println!("Name: {}", name.name);

                            match name.namespace {
                                Some(namespace) => match namespace.as_str() {
                                    "org.kafka.avro" => {
                                        let value = from_value::<Verifier>(&result.value).unwrap();
                                        println!("Value: {:?}", value);
                                    }
                                    _ => {
                                        println!("Unknown namespace");
                                    }
                                },

                                None => {
                                    println!("No namespace");
                                    }
                            }
                        }
                        None => {
                            println!("No name");
                        }
                    },
                    Err(e) => {
                        println!("Error: {:?}", e);
                    }
                }
            }

            consumer.consume_messageset(ms).unwrap();
        }
    }
}
