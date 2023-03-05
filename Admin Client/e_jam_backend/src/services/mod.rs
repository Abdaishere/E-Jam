use super::models::{AppState, StreamEntry, StreamStatus};
use crate::models::device::get_devices_table;
use actix_web::{delete, get, post, put, web, HttpResponse, Responder};

mod device;

use self::device::{
    add_device, delete_device, get_device, get_devices, ping_device, stream_finished,
    stream_started, update_device, ping_all_devices,
};

#[doc = r"# Index
The index service for the api server
## Returns
* `String` - the index page html string"]
#[get("/")]
async fn index(data: web::Data<AppState>) -> String {
    format!(
        "
    Welcome to the E-Jam API!
    Read the documentation at README.md
    return the html table for all connected devices and their ip addresses and mac addresses    
    {}
    ",
        get_devices_table(&data.device_list)
    )
}

#[doc = r"# Get all streams
gets all streams in the list of streams in the app state
if the list of streams is empty, return a 204 No Content
if the list of streams is not empty, return a 200 OK
## Arguments
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in get all streams` - if the streams_entries is not found in the mutex lock"]
#[get("/streams")]
async fn get_streams(data: web::Data<AppState>) -> impl Responder {
    let streams_entries = data
        .streams_entries
        .lock()
        .expect("Failed to lock streams_entries in get all streams")
        .clone();
    match streams_entries.is_empty() {
        true => HttpResponse::NoContent().finish(),
        false => HttpResponse::Ok().json(streams_entries),
    }
}

#[doc = r"# Get a stream
gets a stream by its id in the list of streams in the app state
if the stream is not found, return a 404 Not Found
if the stream is found, return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in get stream {stream_id}` - if the streams_entries is not found in the mutex lock"]
#[get("/streams/{stream_id}")]
async fn get_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let streams_entries = data
        .streams_entries
        .lock()
        .expect(format!("Failed to lock streams_entries in get stream {}", stream_id).as_str())
        .clone();
    let stream_entry = streams_entries
        .iter()
        .find(|&stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => HttpResponse::Ok().json(stream_entry),
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Add a stream
adds a stream to the list of streams in the app state if it is not already in the list of streams
if the stream is already in the list of streams, return a 409 Conflict
if the stream is not in the list of streams, add it and return a 201 Created
if the stream id is empty, generate a new stream id and return it in the response
## Arguments
* `stream_entry` - the stream entry to add
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in post stream {stream_id}` - if the streams_entries is not found in the mutex lock"]
#[post("/streams")]
async fn post_stream(
    stream_entry: web::Json<StreamEntry>,
    data: web::Data<AppState>,
) -> impl Responder {
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in post stream {}",
            stream_entry.get_stream_id()
        )
        .as_str(),
    );
    let stream_id = stream_entry.get_stream_id().to_string();
    let stream_entry_check = streams_entries
        .iter()
        .find(|&stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry_check {
        Some(_) => HttpResponse::Conflict().finish(),
        None => {
            let mut stream_entry = stream_entry.into_inner();

            if stream_entry.get_stream_id() == "" {
                stream_entry.generate_new_stream_id(&data.stream_id_counter);
            }

            streams_entries.push(stream_entry.clone());

            // send the stream back to the client with the default values for all the fields
            HttpResponse::Created().json(stream_entry)
        }
    }
}

#[doc = r"# Update a stream
updates a stream in the list of streams in the app state by its id
if the stream is not found, return a 404 Not Found
if the stream is found, update it and return a 200 OK
## Arguments
* `stream_entry` - the stream entry to update
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in update stream {stream_id}` - if the streams_entries is not found in the mutex lock
* `Failed to stop stream {stream_id}` - if the stream failed to stop"]
#[put("/streams")]
async fn update_stream(
    _stream_entry: web::Json<StreamEntry>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = _stream_entry.get_stream_id();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in update stream {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            // if the stream is running, stop it
            if stream_entry.get_stream_status() == &StreamStatus::Running {
                stream_entry.stop_stream(&data.device_list).await;
            }

            // if the stream is queued, remove it from the queue
            if stream_entry.get_stream_status() == &StreamStatus::Queued {
                stream_entry
                    .remove_stream_from_queue(&data.queued_streams, &data.device_list)
                    .await;
            }

            // update the stream
            *stream_entry = _stream_entry.clone();

            HttpResponse::Created().json(_stream_entry)
        }
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Delete a stream
deletes a stream in the list of streams in the app state by its id
if the stream is not found, return a 404 Not Found
if the stream is running, stop it
if the stream is queued, remove it from the queue
if the stream is found, delete it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in delete stream {stream_id}` - if the streams_entries is not found in the mutex lock"]
#[delete("/streams/{stream_id}")]
async fn delete_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in delete stream {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter()
        .position(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            streams_entries.remove(stream_entry);
            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Start a stream
starts a stream in the list of streams in the app state by its id
if the stream is not found, return a 404 Not Found
if the stream is already running, return a 409 Conflict
if the stream is queued, remove it from the queue
if the stream is found, start it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in start stream {stream_id}` - if the streams_entries is not found in the mutex lock
## Logs
* `Queued stream {stream_id}` - if the stream is queued when starting"]
#[post("/streams/{stream_id}/start")]
async fn start_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in start stream {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            if stream_entry.get_stream_status() == &StreamStatus::Running
                || stream_entry.get_stream_status() == &StreamStatus::Queued
            {
                HttpResponse::Conflict().finish()
            } else {
                // queue the stream in a different thread
                stream_entry
                    .queue_stream(&data.queued_streams, &data.device_list)
                    .await;
                println!("Queued stream {}", stream_id);
                HttpResponse::Ok().finish()
            }
        }
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Stop a stream
stops a stream in the list of streams in the app state by its id
if the stream is not found, return a 404 Not Found
if the stream is stopped or finished, return a 409 Conflict
if the stream is found, stop it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in stop stream {stream_id}` - if the streams_entries is not found in the mutex lock
* `Failed to stop stream {stream_id}` - if the stream failed to stop
## Logs
* `Stopped stream {stream_id}` - if the stream is stopped
* `Stream {stream_id} is already stopped` - if the stream is already stopped"]
#[post("/streams/{stream_id}/stop")]
async fn stop_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in stop stream {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            if stream_entry.get_stream_status() == &StreamStatus::Stopped
                || stream_entry.get_stream_status() == &StreamStatus::Finished
            {
                println!("Stream {} is already stopped", stream_id);
                HttpResponse::Conflict().finish()
            } else {
                stream_entry.stop_stream(&data.device_list).await;
                println!("Stopped stream {}", stream_id);
                HttpResponse::Ok().finish()
            }
        }
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Start all streams
start all streams in the list of streams in the app state
if the stream is already running or queued, do nothing
if not running or queued, queue the stream
## Arguments
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in start all streams` - if the streams_entries is not found in the mutex lock
## Logs
* `Queued all streams to start` - if all streams are queued to start"]
#[post("/streams/start_all")]
async fn start_all_streams(data: web::Data<AppState>) -> impl Responder {
    let mut streams_entries = data
        .streams_entries
        .lock()
        .expect("Failed to lock streams_entries in start all streams");
    for stream_entry in streams_entries.iter_mut() {
        if !(stream_entry.get_stream_status() == &StreamStatus::Running
            || stream_entry.get_stream_status() == &StreamStatus::Queued)
        {
            stream_entry
                .queue_stream(&data.queued_streams, &data.device_list)
                .await;
        }
    }
    println!("Queued all streams to start");
    HttpResponse::Ok().finish()
}

#[doc = r"# Stop all streams
stosps all streams in the list of streams in the app state
if the stream is queued, remove it from the queue
if the stream is running, stop it
## Arguments
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in stop all streams` - if the streams_entries is not found in the mutex lock
## Logs
* `Failed to stop stream` - if the stream failed to stop
* `Stopped all streams` - if all streams are stopped"]
#[post("/streams/stop_all")]
async fn stop_all_streams(data: web::Data<AppState>) -> impl Responder {
    let mut streams_entries = data
        .streams_entries
        .lock()
        .expect("Failed to lock streams_entries in stop all streams");
    for stream_entry in streams_entries.iter_mut() {
        // if the stream is queued, remove it from the queue
        if stream_entry.get_stream_status() == &StreamStatus::Queued {
            stream_entry
                .remove_stream_from_queue(&data.queued_streams, &data.device_list)
                .await;
        } else if stream_entry.get_stream_status() == &StreamStatus::Running {
            stream_entry.stop_stream(&data.device_list).await;

            if stream_entry.get_stream_status() == &StreamStatus::Stopped {
                println!("Stopped stream {}", stream_entry.get_stream_id());
            } else {
                println!("Failed to stop stream {}", stream_entry.get_stream_id());
            }
        }
    }
    HttpResponse::Ok().finish()
}

#[doc = r"# Force start a stream
force start a stream in the list of streams in the app state by its id
if the stream is not found, return a 404 Not Found
if the stream is running, stop it
if the stream is queued, remove it from the queue
if the stream is found, start it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in force start stream {stream_id}` - if the streams_entries is not found in the mutex lock
* `Failed to stop stream {stream_id} when force starting` - if the stream failed to stop when force starting
* `Failed to force start stream {stream_id}` - if the stream failed to force start
## Logs
* `Force Starting stream {stream_id}` - if the stream is started
* `Stream {stream_id} is already running` - if the stream is already running
* `Stream {stream_id} is aleardy queued` - if the stream is queued
* `Stream {stream_id} force started` - if the stream is force started"]
#[post("/streams/{stream_id}/force_start")]
async fn force_start_stream(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    print!("Force Starting stream {}", stream_id);
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in force start stream {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            // if the stream is running, stop it
            // if the stream is queued, remove it from the queue
            if stream_entry.get_stream_status() == &StreamStatus::Running {
                println!("Stream {} is already running", stream_id);
                stream_entry.stop_stream(&data.device_list).await;
            }

            if stream_entry.get_stream_status() == &StreamStatus::Queued {
                println!("Stream {} is aleardy queued", stream_id);
                stream_entry
                    .remove_stream_from_queue(&data.queued_streams, &data.device_list)
                    .await;
            }

            // start the stream
            stream_entry.send_stream(true, &data.device_list).await;
            println!("Stream {} force started", stream_id);
            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Force stop a stream
forces stop a stream in the list of streams in the app state by its id
if the stream is not found, return a 404 Not Found
if the stream is found, stop it and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in force stop stream {stream_id}` - if the streams_entries is not found in the mutex lock
## Logs
* `Failed to stop stream {stream_id}` - if the stream failed to stop
* `Force Stopped stream {stream_id}` - if the stream is stopped"]
#[post("/streams/{stream_id}/force_stop")]
async fn force_stop_stream(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in force stop stream, stream_id: {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            stream_entry.stop_stream(&data.device_list).await;

            println!("Force Stopped stream {}", stream_id);
            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Get the status of a stream
get the status of a stream in the list of streams in the app state by its id
if the stream is found, return a 200 OK with the status
if the stream is not found, return a 404 Not Found
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in get stream status for {stream_id}` - if the streams_entries is not found in the mutex lock"]
#[get("/streams/{stream_id}/status")]
async fn get_stream_status(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in get stream status for {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => HttpResponse::Ok().json(stream_entry.get_stream_status()),
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Get the status of all streams
get the status of all streams in the list of streams in the app state
if the stream is found, return a 200 OK with the status
if the stream is not found, return a 404 Not Found
## Arguments
* `data` - the app state data for the streams
## Returns
* `HttpResponse` - the http response with a list of tuples of the stream status and the stream id"]
#[get("/streams_status")]
async fn get_all_streams_status(data: web::Data<AppState>) -> impl Responder {
    let streams_entries = data
        .streams_entries
        .lock()
        .expect("Failed to lock streams_entries in get all streams status")
        .clone();
    let mut streams_status: Vec<(&StreamStatus, String)> = Vec::new();
    for stream_entry in streams_entries.iter() {
        streams_status.push((
            stream_entry.get_stream_status(),
            stream_entry.get_stream_id().to_string(),
        ));
    }
    HttpResponse::Ok().json(streams_status)
}

#[doc = r"INIT ROUTES
init all the routes for the server"]
pub fn init_routes(config: &mut web::ServiceConfig) {
    config
        .service(index)
        .service(get_streams)
        .service(get_stream)
        .service(post_stream)
        .service(delete_stream)
        .service(update_stream)
        .service(start_stream)
        .service(force_start_stream)
        .service(start_all_streams)
        .service(stop_stream)
        .service(stop_all_streams)
        .service(force_stop_stream)
        .service(get_stream_status)
        .service(get_all_streams_status)
        .service(stream_started)
        .service(get_devices)
        .service(get_device)
        .service(add_device)
        .service(update_device)
        .service(delete_device)
        .service(stream_finished)
        .service(ping_device)
        .service(ping_all_devices);
}
