// use std::{collections::HashMap, string, sync::Mutex};

// use apache_avro::from_value;
// use kafka::consumer::{Consumer, FetchOffset};
// use schema_registry_converter::blocking::{avro::AvroDecoder, schema_registry::SrSettings};
// use validator::HasLen;

// use crate::models::{
//     device::Device,
//     statistics::{Generator, Verifier},
//     stream_details::{self, StreamDetails},
//     StreamEntry,
// };

// let l = 1 mbps
// let r = 1M mbps
// while r - l > 1:
//     let mid = l + r / 2
//   construct the stream with the overall throughput mid mbps for one minute
//    riceve stats from stream
//    if outOfOrderRacio == 0
//        l = mid
//     else
//        r = mid
//     endWhile
// return l
//    
//
// finales kafka broker
// conditionals
//
// preset hard coded conditionals => dynamic
// Kafka ==
//
// Admin client executes throughput, latency, frame loss rate, packet integrity tests
// TODO: make the test function better and more generic
// pub async fn devices_stress(
//     streams_entry: &StreamEntry,
//     device_list: &Mutex<Vec<Device>>,
// ) -> HashMap<String, u64> {
//     let mut devices_power: HashMap<String, u64> = HashMap::new();

//     // test all generators in stream entry
//     for device in streams_entry.generators_ids.iter() {
//         let receiver = Device::find_device(device, device_list);
//         match receiver {
//             Some(device_index) => {
//                 let list = device_list.lock().unwrap();
//                 let device = list.get(device_index).unwrap().clone();

//                 let stream_details: StreamDetails = StreamDetails {
//                     stream_id: ("tst".to_string()),
//                     delay: (0),
//                     generators: (vec![device.get_device_mac().to_string()]),
//                     verifiers: (vec![]),
//                     payload_type: (0),
//                     number_of_packets: (0),
//                     payload_length: (streams_entry.payload_length),
//                     burst_length: (0),
//                     burst_delay: (0),
//                     seed: (0),
//                     broadcast_frames: (0),
//                     inter_frame_gap: (0),
//                     time_to_live: (30 * 1000),
//                     transport_layer_protocol: (0),
//                     flow_type: (0),
//                     check_content: (false),
//                 };

//                 let response = device
//                     .send_stream(
//                         &stream_details,
//                         &stream_details.stream_id,
//                         &crate::models::process::ProcessType::Generation,
//                     )
//                     .await;

//                 match response {
//                     Ok(result) => {
//                         println!("Result: {}", result.url());
//                         // let result = monitor_device_generation(30);
//                         // devices_power.insert(device.get_device_mac().to_string(), result);
//                     }
//                     Err(e) => {
//                         println!("Error: {}", e);
//                     }
//                 }
//             }
//             None => {
//                 println!("Device not found: {}, skipping", device);
//                 continue;
//             }
//         }
//         return devices_power;
//     }

//     return devices_power;
// }

// pub async fn throughput(streams_entry: &mut StreamEntry, device_list: &Mutex<Vec<Device>>) {
//     let devices_stress = devices_stress(streams_entry, &device_list).await;

//     let lower: u64 = 0;
//     let upper: u64 = devices_stress.values().sum();

//     while (upper - lower > 1) {
//         let mid = (lower + upper) / 2;
//         // TODO: change throughput parameter
//         let mut result = change_throughput(streams_entry, mid);
//         result.send_stream(false, device_list);
//         let stats = monitor_device_verification(result.get_time_to_live());
//     }
// }

// pub fn change_throughput(
//     streams_entry: &mut StreamEntry,
//     aggregate_throughput: u64,
// ) -> StreamEntry {
//     // generators count and the coming aggregate throughput
//     // g generates at s packets per second and the aggregate throughput is t packets per second
//     let throughput = aggregate_throughput / streams_entry.generators_ids.length();

//     streams_entry.inter_frame_gap = streams_entry.payload_length * 1000 / throughput;

//     return streams_entry.clone();
// }

// pub fn monitor_device_verification(time_to_monitor: u64) -> u64 {
//     let schema_registry_url = "localhost:8081";
//     let sr_settings = SrSettings::new(format!("http://{}", schema_registry_url));
//     let decoder = AvroDecoder::new(sr_settings);

//     let hosts = vec!["localhost:9092".to_owned()];
//     let mut consumer: Consumer = loop {
//         match Consumer::from_hosts(hosts.clone())
//             .with_topic("Verifier".to_owned())
//             .with_fallback_offset(FetchOffset::Earliest)
//             .create()
//         {
//             Ok(v) => break v,
//             Err(e) => {
//                 println!("Error: {:?}", e);
//                 continue;
//             }
//         }
//     };

//     println!("Monitoring device verification...");
//     let end_time = std::time::Instant::now() + std::time::Duration::from_secs(time_to_monitor);
//     let mut aggregate_throughput = 0;
//     let mut count: u64 = 0;
//     loop {
//         for ms in consumer.poll().unwrap().iter() {
//             for m in ms.messages() {
//                 // If the consumer receives an event, this block is executed
//                 //  println!("{:?}", str::from_utf8(m.value).unwrap());
//                 match decoder.decode(Some(m.value)) {
//                     Ok(result) => match result.name {
//                         Some(name) => {
//                             println!("Name: {}", name.name);

//                             match name.namespace {
//                                 Some(namespace) => match namespace.as_str() {
//                                     "org.kafka.avro" => {
//                                         let value = from_value::<Verifier>(&result.value).unwrap();
//                                         println!("Value: {:?}", value);
//                                         aggregate_throughput += value.packets_dropped;
//                                         count += 1;
//                                     }
//                                     _ => {
//                                         println!("Unknown namespace");
//                                     }
//                                 },

//                                 None => {
//                                     println!("No namespace");
//                                 }
//                             }
//                         }
//                         None => {
//                             println!("No name");
//                         }
//                     },
//                     Err(e) => {
//                         println!("Error: {:?}", e);
//                     }
//                 }
//             }

//             consumer.consume_messageset(ms).unwrap();
//             // check if the time is up
//             if end_time < std::time::Instant::now() {
//                 return aggregate_throughput / count;
//             }
//         }
//         // check if the time is up
//         if end_time < std::time::Instant::now() {
//             return aggregate_throughput / count;
//         }
//     }
// }

// pub fn monitor_device_generation(time_to_monitor: u64) -> u64 {
//     let schema_registry_url = "localhost:8081";
//     let sr_settings = SrSettings::new(format!("http://{}", schema_registry_url));
//     let decoder = AvroDecoder::new(sr_settings);

//     let hosts = vec!["localhost:9092".to_owned()];
//     let mut consumer: Consumer = loop {
//         match Consumer::from_hosts(hosts.clone())
//             .with_topic("Generator".to_owned())
//             .with_fallback_offset(FetchOffset::Earliest)
//             .create()
//         {
//             Ok(v) => break v,
//             Err(e) => {
//                 println!("Error: {:?}", e);
//                 continue;
//             }
//         }
//     };

//     println!("Monitoring device generation...");

//     let end_time = std::time::Instant::now() + std::time::Duration::from_secs(time_to_monitor);
//     let mut aggregate_throughput = 0;
//     let mut count: u64 = 0;
//     loop {
//         for ms in consumer.poll().unwrap().iter() {
//             for m in ms.messages() {
//                 // If the consumer receives an event, this block is executed
//                 //  println!("{:?}", str::from_utf8(m.value).unwrap());
//                 match decoder.decode(Some(m.value)) {
//                     Ok(result) => match result.name {
//                         Some(name) => {
//                             println!("Name: {}", name.name);

//                             match name.namespace {
//                                 Some(namespace) => match namespace.as_str() {
//                                     "org.kafka.avro" => {
//                                         let value = from_value::<Generator>(&result.value).unwrap();
//                                         println!("Value: {:?}", value);
//                                         aggregate_throughput +=
//                                             value.packets_sent + value.packets_errors;
//                                         count += 1;
//                                     }
//                                     _ => {
//                                         println!("Unknown namespace");
//                                     }
//                                 },

//                                 None => {
//                                     println!("No namespace");
//                                 }
//                             }
//                         }
//                         None => {
//                             println!("No name");
//                         }
//                     },
//                     Err(e) => {
//                         println!("Error: {:?}", e);
//                     }
//                 }
//             }

//             consumer.consume_messageset(ms).unwrap();
//             // check if the time is up
//             if end_time < std::time::Instant::now() {
//                 return aggregate_throughput / count;
//             }
//         }
//         // check if the time is up
//         if end_time < std::time::Instant::now() {
//             return aggregate_throughput / count;
//         }
//     }
// }
