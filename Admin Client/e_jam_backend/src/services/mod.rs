use super::models::{AppState, StreamEntry, StreamStatus};
use crate::{
    models::{self, device::get_devices_table, stream_details::StreamStatusDetails, Handler},
    services::utils::{handle_starting_connections, handle_stopping_connections},
};
use actix_web::{delete, get, post, put, web, HttpResponse, Responder};
use chrono::Utc;
use log::{debug, info, warn};
use validator::Validate;

mod device;
pub(crate) mod statistics;
mod utils;

use self::{
    device::{
        add_device, check_new_device, delete_device, get_device, get_devices, ping_all_devices,
        ping_device, stream_finished, stream_started, update_device,
    },
    statistics::query::{
        get_all_statistics_for_generator, get_all_statistics_for_verifier,
        get_device_statistics_for_generator, get_device_statistics_for_verifier,
        get_stream_statistics_for_generator, get_stream_statistics_for_verifier,
    },
};

#[doc = r"# Index
The index service for the api server that returns the index page string for the api server with the table of all connected devices and their ip addresses and mac addresses
## Returns
* `String` - the index page string"]
#[get("/")]
async fn index(data: web::Data<AppState>) -> String {
    format!(
        "
    Welcome to the E-Jam API!
    Read the documentation at README.md
    return the table for all connected devices 

    {}
    ",
        get_devices_table(data.device_list.lock().await.to_owned()),
    )
}

#[doc = r"# Get Streams
Gets ALL streams in the list of streams in the app state
if the list of streams is empty, return a 204 No Content
if the list of streams is not empty, return a 200 OK
## Returns
* `HttpResponse` - the http response with the list of streams"]
#[get("/streams")]
async fn get_streams(data: web::Data<AppState>) -> impl Responder {
    let stream_entries: Vec<StreamEntry> =
        data.stream_entries.lock().await.values().cloned().collect();

    match stream_entries.is_empty() {
        true => HttpResponse::NoContent()
            .body("No streams found in the list of streams try adding a stream first"),
        false => HttpResponse::Ok().json(stream_entries),
    }
}

#[doc = r"# Get Stream
Gets a stream by its id in the list of streams in the app state
if the stream is not found, return a 404 Not Found
if the stream is found, return a 200 OK
## Arguments
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the stream"]
#[get("/streams/{stream_id}")]
async fn get_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let stream_entries = data.stream_entries.lock().await;

    let stream_entry = stream_entries.get(&stream_id);

    match stream_entry {
        Some(stream_entry) => HttpResponse::Ok().json(stream_entry),

        None => HttpResponse::NotFound().body(format!(
            "Stream with id {} not found, please try again with a the correct stream id",
            stream_id
        )),
    }
}

#[doc = r"# Add Stream
Adds a stream to the list of streams in the app state if it is not already in the list of streams
if the stream is already in the list of streams, return a 409 Conflict
if the stream is not in the list of streams, add it and return a 201 Created
if the stream id is empty, generate a new stream id and return it in the response.
## Arguments
* `stream_entry` - the stream entry to add
## Returns
* `HttpResponse` - the http response with the stream id"]
#[post("/streams")]
async fn add_stream(
    new_stream_entry: web::Json<StreamEntry>,
    data: web::Data<AppState>,
) -> impl Responder {
    let mut stream_entry = new_stream_entry.into_inner();

    if stream_entry.get_stream_id() == "" {
        stream_entry
            .generate_stream_id(&data.stream_id_counter, &data.stream_entries)
            .await;
    }

    match stream_entry.validate() {
        Ok(_) => (),
        Err(e) => {
            warn!("Validation error: {}", e);
            return HttpResponse::BadRequest().body(format!("Validation error: {}", e));
        }
    }

    let mut streams_entries = data.stream_entries.lock().await;
    let stream_id = stream_entry.get_stream_id().to_string();
    let stream_entry_check = streams_entries.get(&stream_id);

    match stream_entry_check {
        Some(duplicate_stream) => HttpResponse::Conflict().body(format!(
            "Stream with id {} already exists, and is {} in the list of streams",
            stream_id,
            duplicate_stream.get_stream_status().to_string()
        )),
        None => {
            streams_entries.insert(
                stream_entry.get_stream_id().to_string(),
                stream_entry.to_owned(),
            );

            // send the stream back to the client with the default values for all the fields
            HttpResponse::Created().body(format!(
                "Stream with id {} added to the list of streams",
                stream_entry.get_stream_id()
            ))
        }
    }
}

#[doc = r"# Update Stream
Updates a stream in the list of streams in the app state by its id
if the stream is not found, return a 404 Not Found
if the stream is found, update it and return a 200 OK
## Arguments
* `stream_entry` - the stream entry to update
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the stream id"]
#[put("/streams/{stream_id}")]
async fn update_stream(
    stream_id: web::Path<String>,
    new_stream_entry: web::Json<StreamEntry>,
    data: web::Data<AppState>,
) -> impl Responder {
    match new_stream_entry.validate() {
        Ok(_) => (),
        Err(e) => {
            warn!("Validation error: {}", e);
            return HttpResponse::BadRequest().body(format!("Validation error: {}", e));
        }
    }

    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.stream_entries.lock().await;
    let stream_entry = streams_entries.get_mut(&stream_id);

    match stream_entry {
        Some(stream_entry) => {
            // this is to prevent the stream id from being changed in the update stream to ensure that the stream id is unique and the user did not make a mistake
            if new_stream_entry.get_stream_id() != stream_entry.get_stream_id() {
                return HttpResponse::BadRequest().body("Stream id cannot be changed in updating a stream please delete and add the stream again with the new id if you want to change the id of the stream");
            }
            let mut body = format!("stream {} ", stream_id);

            // dequeue if queued
            if stream_entry.check_stream_status(StreamStatus::Queued) {
                warn!("Stream {} is already queued", stream_id);
                let connections = stream_entry
                    .try_remove_stream_from_queue(&data.device_list)
                    .await;
                let dequeued =
                    handle_stopping_connections(connections, stream_entry, &data.device_list).await;
                body += &format!("{} were dequeued ", dequeued);
            }
            // Stop if running
            else if stream_entry.check_stream_status(StreamStatus::Running) {
                warn!("Stream {} is already running", stream_id);
                let connections = stream_entry.stop_stream(&data.device_list).await;
                let stopped =
                    handle_stopping_connections(connections, stream_entry, &data.device_list).await;
                body += &format!("{} were Stopped ", stopped);
            }

            // update the stream
            stream_entry.update(&new_stream_entry);
            info!("{} Updated stream: {:#?}", body, stream_entry);
            HttpResponse::Ok().body(format!(
                "Stream with id {} updated in the list of streams",
                stream_entry.get_stream_id()
            ))
        }
        None => HttpResponse::NotFound().body(format!(
            "Stream with id {} not found, please try again with a the correct stream id",
            stream_id
        )),
    }
}

#[doc = r"# Delete Stream
Deletes a stream in the list of streams in the app state by its id.
If the stream is not found, return a 404 Not Found.
If the stream is running, stop it.
If the stream is queued, remove it from the queue.
If the stream is found, delete it and return a 200 OK.
## Arguments
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the stream id"]
#[delete("/streams/{stream_id}")]
async fn delete_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.stream_entries.lock().await;
    let stream_entry = streams_entries.get_mut(&stream_id);

    match stream_entry {
        Some(stream_entry) => {
            let counter = if stream_entry.check_stream_status(StreamStatus::Running)
                || stream_entry.check_stream_status(StreamStatus::Queued)
            {
                warn!("Stream {} is already running", stream_id);
                if stream_entry.check_stream_status(StreamStatus::Queued) {
                    data.queued_streams.lock().await.remove(&stream_id);
                }
                let connections = stream_entry.stop_stream(&data.device_list).await;

                handle_stopping_connections(connections, stream_entry, &data.device_list).await
            } else {
                0
            };

            streams_entries.remove(&stream_id);

            info!("Deleted stream {}", stream_id);
            info!("{} in {} places", "And every where that Mary went", counter);

            HttpResponse::Ok().body(format!(
                "Deleted stream {} successfully, after stopping in {} devices",
                stream_id, counter
            ))
        }
        None => HttpResponse::NotFound().body(format!(
            "Stream with id {} not found, please try again with a the correct stream id",
            stream_id
        )),
    }
}

#[doc = r"# Start Stream
Starts a stream in the list of streams in the app state by its id.
If the stream is not found, return a 404 Not Found
If the stream is already running or queued, return a 409 Conflict
If the stream is found, queue it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the right details about the stream"]
#[post("/streams/{stream_id}/start")]
async fn start_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();

    let mut streams_entries = data.stream_entries.lock().await;

    let stream_entry = streams_entries.get_mut(&stream_id);

    match stream_entry {
        Some(stream_entry) => {
            if stream_entry.check_stream_status(StreamStatus::Running)
                || stream_entry.check_stream_status(StreamStatus::Queued)
            {
                warn!("Stream {} is already running", stream_id);
                HttpResponse::Conflict().body(format!(
                    "Stream {} is already {}, please stop it first and then queue it again",
                    stream_id,
                    stream_entry.get_stream_status().to_string()
                ))
            } else {
                // queue the stream in a different thread
                let connections = stream_entry.try_queue_stream(&data.device_list).await;

                let connects =
                    handle_starting_connections(connections, stream_entry, &data.device_list).await;

                // add the thread to the queued streams list
                if stream_entry.check_stream_status(StreamStatus::Sent) {
                    stream_entry.update_stream_status(StreamStatus::Queued);
                    data.queued_streams
                        .lock()
                        .await
                        .insert(stream_entry.get_stream_id().to_owned(), Utc::now());
                }

                debug!(
                    "stream {} is {}",
                    stream_id,
                    stream_entry.get_stream_status().to_string()
                );

                match stream_entry.get_stream_status() {

                    StreamStatus::Queued => HttpResponse::Ok().body(format!(
                        "Stream is queued to start after {} seconds for {} devices",
                        stream_entry.get_stream_delay_seconds(),
                        connects
                    )),

                    StreamStatus::Error => {
                        match connects {
                            0 => {
                                HttpResponse::InternalServerError().body("No devices are running the stream".to_string())
                            }
                            1 => {
                                HttpResponse::InternalServerError().body("Only one Process type is running the stream".to_string())
                            }
                            _ => {
                                HttpResponse::InternalServerError().body(format!("Stream {}: {} While Queueing the stream, please check the server for more info", stream_id,
                                stream_entry.get_stream_status().to_string()))
                            },
                        }
                    }
                    _ => HttpResponse::Ok().body(format!(
                        "Stream {} is sent for {} devices with status {}, but not queued",
                        stream_entry.get_stream_id(),
                        connects,
                        stream_entry.get_stream_status().to_string()
                    )),
                }
            }
        }
        None => {
            HttpResponse::NotFound().body(format!("Stream {} not found, to start it", stream_id))
        }
    }
}

#[doc = r"# Stop Stream
Stops a stream in the list of streams in the app state by its id
If the stream is not found, return a 404 Not Found
If the stream is stopped or finished, return a 409 Conflict
If the stream is found, stop it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the right details about the stream"]
#[post("/streams/{stream_id}/stop")]
async fn stop_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();

    let mut streams_entries = data.stream_entries.lock().await;

    let stream_entry = streams_entries.get_mut(&stream_id);

    match stream_entry {
        Some(stream_entry) => {
            if stream_entry.check_stream_status(StreamStatus::Running)
                || stream_entry.check_stream_status(StreamStatus::Queued)
            {
                let connections = if stream_entry.check_stream_status(StreamStatus::Queued) {
                    stream_entry
                        .try_remove_stream_from_queue(&data.device_list)
                        .await
                } else {
                    stream_entry.stop_stream(&data.device_list).await
                };

                let connects =
                    handle_stopping_connections(connections, stream_entry, &data.device_list).await;

                info!("Stopped stream {}", stream_id);

                // the system marks the stream as stopped if the stream has at two or more connections stopped
                if stream_entry.check_stream_status(StreamStatus::Stopped) {
                    HttpResponse::Ok().body(format!(
                        "Stream {} Stopped Successfully, on {} devices",
                        stream_id, connects
                    ))
                } else {
                    let message = format!("Stream {}: {} While Stopping the stream, please check the server logs for more info", stream_id,
                    stream_entry.get_stream_status().to_string());
                    HttpResponse::InternalServerError().body(message)
                }
            } else {
                warn!("Stream {} is already stopped", stream_id);
                HttpResponse::Conflict().body(format!(
                    "Stream {} is already {}",
                    stream_id,
                    stream_entry.get_stream_status().to_string()
                ))
            }
        }

        None => {
            HttpResponse::NotFound().body(format!("Stream {} not found, to stop it", stream_id))
        }
    }
}

#[doc = r"# Start All Streams
Start all streams in the list of streams in the system
If a stream is already running or queued, do nothing
If it is not running or queued, queue the stream.
## Returns
* `HttpResponse` - the http response number of streams queued"]
#[post("/streams/start_all")]
async fn start_all_streams(data: web::Data<AppState>) -> impl Responder {
    let streams_entries_keys: Vec<String> =
        data.stream_entries.lock().await.keys().cloned().collect();

    if streams_entries_keys.is_empty() {
        warn!("No streams to start");
        return HttpResponse::NoContent().body("No streams to start, Please add a stream first");
    }

    let mut counter = 0;
    let mut handles: Vec<Vec<Handler>> = Vec::with_capacity(streams_entries_keys.len());

    for stream_id in streams_entries_keys.iter() {
        let mut stream_entries = data.stream_entries.lock().await;
        let stream_entry = stream_entries.get_mut(stream_id).unwrap();
        let connections = stream_entry.try_queue_stream(&data.device_list).await;

        handles.push(connections);
    }

    for (i, connections) in handles.into_iter().enumerate() {
        let stream_id = &streams_entries_keys[i];
        let mut stream_entries = data.stream_entries.lock().await;
        let stream_entry = stream_entries.get_mut(stream_id).unwrap();

        handle_starting_connections(connections, stream_entry, &data.device_list).await;

        // add the thread to the queued streams list
        if stream_entry.check_stream_status(StreamStatus::Sent) {
            stream_entry.update_stream_status(StreamStatus::Queued);
            counter += 1;
            data.queued_streams
                .lock()
                .await
                .insert(stream_entry.get_stream_id().to_owned(), Utc::now());
        }
    }

    info!("Queued {} streams to start successfully", counter);
    HttpResponse::Ok().body(format!("Queued {} streams to start successfully", counter))
}

#[doc = r"# Stop All Streams
Stops all streams in the list of streams in the system
If the stream is queued, remove it from the queue
If the stream is running, stop it
## Returns
* `HttpResponse` - the http response with the count of streams stopped"]
#[post("/streams/stop_all")]
async fn stop_all_streams(data: web::Data<AppState>) -> impl Responder {
    let streams_entries_keys: Vec<String> =
        data.stream_entries.lock().await.keys().cloned().collect();

    if streams_entries_keys.is_empty() {
        warn!("No streams to stop");
        return HttpResponse::NoContent().body("No streams to stop, Please add a stream first");
    }
    let mut attempt = 0;
    let mut handles: Vec<Vec<Handler>> = Vec::with_capacity(streams_entries_keys.len());

    for stream_id in streams_entries_keys.iter() {
        let mut stream_entries = data.stream_entries.lock().await;
        let stream_entry = stream_entries.get_mut(stream_id).unwrap();

        let connections: Vec<Handler> = if stream_entry.check_stream_status(StreamStatus::Running) {
            stream_entry.stop_stream(&data.device_list).await
        } else {
            stream_entry
                .try_remove_stream_from_queue(&data.device_list)
                .await
        };

        if !connections.is_empty() {
            attempt += 1;
        }

        handles.push(connections);
    }

    let mut counter = 0;
    for (i, connections) in handles.into_iter().enumerate() {
        let stream_id = &streams_entries_keys[i];

        let mut stream_entries = data.stream_entries.lock().await;
        let stream_entry = stream_entries.get_mut(stream_id).unwrap();

        handle_stopping_connections(connections, stream_entry, &data.device_list).await;

        // the system marks the stream as stopped if the stream has at two or more connections stopped
        if stream_entry.check_stream_status(StreamStatus::Stopped) {
            counter += 1;
        }
    }

    info!("Stopping all streams process finished");
    HttpResponse::Ok().body(format!(
        "Stopped {} streams, after {} streams were attempted",
        counter, attempt
    ))
}

#[doc = r" # Force Start a Stream
Force start a stream in the list of streams in the app state by its id.
If the stream is not found, return a 404 Not Found
If the stream is running, stop it
If the stream is queued, remove it from the queue
If the stream is found, start it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the status of the stream and the actions taken"]
#[post("/streams/{stream_id}/force_start")]
async fn force_start_stream(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();

    let stream_entry = data.stream_entries.lock().await.contains_key(&stream_id);

    if !stream_entry {
        return HttpResponse::NotFound().body(format!(
            "stream {} not found in streams, please check the stream id and try again",
            stream_id
        ));
    }

    let mut body = format!("stream {} ", stream_id);
    let mut streams_entries = data.stream_entries.lock().await;
    let stream_entry = streams_entries.get_mut(&stream_id).unwrap();

    // dequeue if queued
    if stream_entry.check_stream_status(StreamStatus::Queued) {
        warn!("Stream {} is already queued", stream_id);
        let connections = stream_entry
            .try_remove_stream_from_queue(&data.device_list)
            .await;
        let dequeued =
            handle_stopping_connections(connections, stream_entry, &data.device_list).await;
        body += &format!("{} were dequeued ", dequeued);
    }
    // Stop if running
    else if stream_entry.check_stream_status(StreamStatus::Running) {
        warn!("Stream {} is already running", stream_id);
        let connections = stream_entry.stop_stream(&data.device_list).await;
        let stopped =
            handle_stopping_connections(connections, stream_entry, &data.device_list).await;
        body += &format!("{} were Stopped ", stopped);
    }

    // force start the stream
    let connections = stream_entry.send_stream(false, &data.device_list).await;
    let counter = handle_starting_connections(connections, stream_entry, &data.device_list).await;

    body += &format!("{} devices were force started ", counter);

    info!("Stream {} force started", stream_id);
    match stream_entry.get_stream_status() {
        StreamStatus::Queued => HttpResponse::Ok().body(body),
        StreamStatus::Error => {
            if counter == 0 {
                HttpResponse::InternalServerError().body("No devices are running the stream")
            } else if counter == 1 {
                HttpResponse::InternalServerError()
                    .body("Only one Process type is running the stream")
            } else {
                HttpResponse::InternalServerError()
                                .body(format!("Stream {}: {} While Queueing the stream, please check the server for more info", stream_id,
                                stream_entry.get_stream_status().to_string()))
            }
        }
        _ => HttpResponse::Ok().body(format!(
            "{} sent for {} devices with status {}",
            body,
            counter,
            stream_entry.get_stream_status().to_string()
        )),
    }
}

#[doc = r" # Force Stop a Stream
Forces stop a stream in the list of streams in the app state by its id.
If the stream is not found, return a 404 Not Found
If the stream is found, stop it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the status of the stream and the actions taken"]
#[post("/streams/{stream_id}/force_stop")]
async fn force_stop_stream(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();

    let mut streams_entries = data.stream_entries.lock().await;

    let stream_entry = streams_entries.get_mut(&stream_id);

    match stream_entry {
        Some(stream_entry) => {
            let mut body: String = format!("{} ", stream_id);

            let connections = stream_entry.stop_stream(&data.device_list).await;
            let stopped =
                handle_stopping_connections(connections, stream_entry, &data.device_list).await;

            body += &format!("{} were Stopped ", stopped);

            info!("{}", body);
            if stream_entry.check_stream_status(StreamStatus::Stopped) {
                HttpResponse::Ok().body(body)
            } else {
                let message = format!("Stream {}: {} While Force Stopping the stream, please check the server for more info", stream_id,
                stream_entry.get_stream_status().to_string());
                HttpResponse::InternalServerError().body(message)
            }
        }
        None => HttpResponse::NotFound().body(format!(
            "stream {} not found in streams, please check the stream id and try again",
            stream_id
        )),
    }
}

#[doc = r" # Get The Status of a Stream
Get the status of a stream in the list of streams in the app state by its id.
If the stream is found, return a 200 OK with the status
If the stream is not found, return a 404 Not Found
## Arguments
* `stream_id` - the id of the stream
## Returns
* `HttpResponse` - the http response with the status of the stream"]
#[get("/streams/{stream_id}/status")]
async fn get_stream_status(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();

    let streams_entries = data.stream_entries.lock().await;

    let stream_entry = streams_entries.get(&stream_id);

    match stream_entry {
        Some(stream_entry) => HttpResponse::Ok().json(stream_entry.get_stream_status_card()),
        None => HttpResponse::NotFound().body(format!(
            "stream {} not found to check its status, please check the stream id and try again",
            stream_id
        )),
    }
}

#[doc = r" # Get The Status of All Streams
Get the status of all streams in the list of streams in the system.
If the stream is found, return a 200 OK with the status
If the stream is not found, return a 404 Not Found
## Returns
* `HttpResponse` - the http response with a list of the status of all streams"]
#[get("/streams/status_all")]
async fn get_all_streams_status(data: web::Data<AppState>) -> impl Responder {
    let stream_entries: Vec<StreamEntry> =
        data.stream_entries.lock().await.values().cloned().collect();

    let mut streams_status: Vec<StreamStatusDetails> = Vec::with_capacity(stream_entries.len());
    if stream_entries.is_empty() {
        return HttpResponse::NoContent()
            .body("No streams found to check their status, please add a stream and try again");
    }

    for stream_entry in stream_entries {
        streams_status.push(stream_entry.get_stream_status_card());
    }

    HttpResponse::Ok().json(streams_status)
}

#[doc = r"# Init Routes
init all the routes for the server"]
pub fn init_routes(config: &mut web::ServiceConfig) {
    config
        .service(index)
        .service(get_all_streams_status)
        .service(start_all_streams)
        .service(stop_all_streams)
        .service(ping_all_devices)
        .service(get_stream_statistics_for_generator)
        .service(get_stream_statistics_for_verifier)
        .service(get_device_statistics_for_generator)
        .service(get_device_statistics_for_verifier)
        .service(get_all_statistics_for_generator)
        .service(get_all_statistics_for_verifier)
        .service(get_streams)
        .service(get_stream)
        .service(add_stream)
        .service(delete_stream)
        .service(update_stream)
        .service(start_stream)
        .service(force_start_stream)
        .service(stop_stream)
        .service(force_stop_stream)
        .service(get_stream_status)
        .service(stream_started)
        .service(get_devices)
        .service(get_device)
        .service(add_device)
        .service(update_device)
        .service(delete_device)
        .service(stream_finished)
        .service(ping_device)
        .service(check_new_device);
}
