use std::collections::HashMap;

use super::models::StreamEntry;
use crate::models::{Device, Handler};
use log::{debug, error, info};
use tokio::sync::Mutex;

pub async fn handle_starting_connections(
    connections: Vec<Handler>,
    stream_entry: &mut StreamEntry,
    device_list: &Mutex<HashMap<String, Device>>,
) -> i32 {
    let stream_id = stream_entry.get_stream_id().to_owned();

    if connections.is_empty() {
        debug!("No device is receiving stream {} to run", stream_id);
        return 0;
    }

    info!(
        "The running threads for Queuing stream {} are {} thread.",
        stream_id,
        connections.len()
    );

    /*
    If you want to lock the stream_entries only when you receive a response from a device, move it inside a for loop and lock it again when get_received_devices is called
    this will make the stream_entries locked for a shorter time, but will lock it more times
    Keep in mind that you can also send data to the targeted device as a chunk which has it's own pros and cons.
    */

    let mut results = Vec::with_capacity(connections.len());
    for handler in connections.into_iter() {
        let info = handler.connections;
        let handle = handler.handle;

        match handle.await {
            Ok(response) => {
                // gather all results in main thread and analyze them by device type
                results.push(
                    stream_entry
                        .analyze_device_response(info, response, device_list, true)
                        .await,
                );
            }
            Err(e) => {
                error!("Failed to stop stream {} on {:?}: {}", stream_id, info, e);
            }
        }
    }

    // get the number of devices that are running the stream and return it
    stream_entry
        .update_received_devices_result(results, true)
        .await
}

pub async fn handle_stopping_connections(
    connections: Vec<Handler>,
    stream_entry: &mut StreamEntry,
    device_list: &Mutex<HashMap<String, Device>>,
) -> i32 {
    let stream_id = stream_entry.get_stream_id().to_owned();

    if connections.is_empty() {
        debug!("No device is receiving stream {} to stop", stream_id);
        return 0;
    }

    info!(
        "The running threads for Stopping stream {} are {} thread",
        stream_id,
        connections.len()
    );

    /*
    if you want to lock the stream_entries only when you receive a response from a device, move it inside a for loop and lock it again when get_received_devices is called
    this will make the stream_entries locked for a shorter time, but will lock it more times
    Keep in mind that you can also send data to the targeted device as a chunk which has it's own pros and cons. (using Kafka or not)
    */

    let mut results = Vec::with_capacity(connections.len());
    for handler in connections {
        let info = handler.connections;
        let handle = handler.handle;

        match handle.await {
            Ok(response) => {
                // gather all results in main thread and analyze them by device type
                results.push(
                    stream_entry
                        .analyze_device_response(info, response, device_list, false)
                        .await,
                );
            }
            Err(e) => {
                error!("Failed to stop stream {} on {:?}: {}", stream_id, info, e);
            }
        }
    }

    // get the number of devices that are running the stream and return it
    stream_entry
        .update_received_devices_result(results, false)
        .await
}
