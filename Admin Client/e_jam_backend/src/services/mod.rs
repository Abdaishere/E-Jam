use super::models::{AppState, StreamEntry, StreamStatus};
use crate::models::{get_devices_table, Device, DEVICE_LIST};
use actix_web::{delete, get, post, put, web, HttpRequest, HttpResponse, Responder};

// get the list of streams
#[get("/streams")]
async fn get_streams(data: web::Data<AppState>) -> impl Responder {
    let streams_entries = data
        .streams_entries
        .lock()
        .expect("Failed to lock streams_entries in get all streams")
        .clone();
    HttpResponse::Ok().json(streams_entries)
}

// get a stream from the list of streams
// if the stream is not found, return a 404 Not Found
// if the stream is found, return the stream
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

// add a stream to the list of streams
// if the stream is already in the list, return a 409 Conflict
// if the stream is not in the list, add it and return a 201 Created
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
                stream_entry.generate_new_stream_id();
            }

            streams_entries.push(stream_entry.clone());

            // send the stream back to the client with the default values for all the fields
            HttpResponse::Created().json(stream_entry)
        }
    }
}

// delete a stream in the list of streams
// if the stream is running, stop it
// if the stream is queued, remove it from the queue
// if the stream is not found, return a 404 Not Found
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

// update a stream in the list of streams
// if the stream is not found, return a 404 Not Found
// if the stream is found, update it and return a 200 OK
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
                stream_entry
                    .stop_stream()
                    .await
                    .expect("Failed to stop stream");
            }

            // if the stream is queued, remove it from the queue
            if stream_entry.get_stream_status() == &StreamStatus::Queued {
                stream_entry.remove_stream_from_queue().await;
            }
            
            // update the stream
            *stream_entry = _stream_entry.clone();

            HttpResponse::Created().json(_stream_entry)
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// start a stream in the list of streams
// if the stream is not found, return a 404 Not Found
// if the stream is already running or queued, return a 409 Conflict
// if the stream is queued, start it and return a 200 OK
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
                stream_entry.queue_stream().await;

                HttpResponse::Ok().finish()
            }
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// force start a stream in the list of streams
// if the stream is not found, return a 404 Not Found
#[post("/streams/{stream_id}/force_start")]
async fn force_start_stream(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
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
                stream_entry
                    .stop_stream()
                    .await
                    .expect(format!("Failed to stop stream {}", stream_id).as_str());
            }

            if stream_entry.get_stream_status() == &StreamStatus::Queued {
                stream_entry.remove_stream_from_queue().await;
            }

            // start the stream
            stream_entry
                .send_stream(true)
                .await
                .expect(format!("Failed to send stream {}", stream_id).as_str());
            println!("Stream {} force started", stream_id);
            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// start all streams in the list of streams
// if the stream is already running or queued, iqnore it
// if the stream is stopped, start it
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
            stream_entry.queue_stream().await;
        }
    }
    HttpResponse::Ok().finish()
}

// stop a stream in the list of streams
// if the stream is not found, return a 404 Not Found
// if the stream is already stopped, return a 409 Conflict
// if the stream is running, stop it and return a 200 OK
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
                HttpResponse::Conflict().finish()
            } else {
                stream_entry
                    .stop_stream()
                    .await
                    .expect(format!("Failed to stop stream in stop_stream {}", stream_id).as_str());
                HttpResponse::Ok().finish()
            }
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// force stop a stream in the list of streams
// if the stream is not found, return a 404 Not Found
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
            stream_entry
                .stop_stream()
                .await
                .expect("Failed to stop stream");
            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// stop all streams in the list of streams
// if the stream is already stopped, ignore it
// if the stream is running, stop it
#[post("/streams/stop_all")]
async fn stop_all_streams(data: web::Data<AppState>) -> impl Responder {
    let mut streams_entries = data
        .streams_entries
        .lock()
        .expect("Failed to lock streams_entries in stop all streams");
    for stream_entry in streams_entries.iter_mut() {
        // if the stream is queued, remove it from the queue
        if stream_entry.get_stream_status() == &StreamStatus::Queued {
            stream_entry.remove_stream_from_queue().await;
        } else if stream_entry.get_stream_status() == &StreamStatus::Running {
            stream_entry
                .stop_stream()
                .await
                .expect("Failed to stop stream");
        }
    }
    HttpResponse::Ok().finish()
}

// get the status of a stream in the list of streams
// if the stream is not found, return a 404 Not Found
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

// get the status of all streams in the list of streams
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

// index page for the API documentation and the html table for the Stream object structure
#[get("/")]
async fn index() -> String {
    "
    Welcome to the E-Jam API!
    Read the documentation at README.md
    return the html table for all connected devices and their ip addresses and mac addresses    
    "
    .to_string()
        + &get_devices_table()
}

// devices services
// get the list of all connected devices
#[get("/devices")]
async fn get_devices() -> impl Responder {
    let devices = DEVICE_LIST
        .lock()
        .expect("failed to lock device list in get all devices")
        .clone();
    HttpResponse::Ok().json(devices)
}

// get a device in the list of devices by its ip address
// if the device is not found, return a 404 Not Found
#[get("/devices/{device_ip}")]
async fn get_device(device_ip: web::Path<String>) -> impl Responder {
    let device_ip = device_ip.into_inner();
    let devices = DEVICE_LIST
        .lock()
        .expect(format!("failed to lock device list in get device {}", device_ip).as_str())
        .clone();
    let device = devices
        .iter()
        .find(|device| device.ip_address.to_string() == device_ip);
    match device {
        Some(device) => HttpResponse::Ok().json(device),
        None => HttpResponse::NotFound().finish(),
    }
}

// add a device in the list of devices
// if the device is already in the list, return a 409 Conflict
// if the device is not in the list, add it and return a 201 Created
#[post("/devices")]
async fn add_device(device: web::Json<Device>) -> impl Responder {
    let mut devices = DEVICE_LIST.lock().expect(
        format!(
            "failed to lock device list in add device {}",
            device.ip_address
        )
        .as_str(),
    );
    let device_index = devices
        .iter()
        .position(|device| device.ip_address.to_string() == device.ip_address.to_string());
    match device_index {
        Some(_device_index) => HttpResponse::Conflict().finish(),
        None => {
            devices.push(device.into_inner());
            HttpResponse::Created().finish()
        }
    }
}

// update a divice in the list of devices by its ip address
// if the device is not found, return a 404 Not Found
// if the device is found, update it and return a 200 OK
#[put("/devices/{device_ip}")]
async fn update_device(device_ip: web::Path<String>, device: web::Json<Device>) -> impl Responder {
    let device_ip = device_ip.into_inner();
    let mut devices = DEVICE_LIST
        .lock()
        .expect(format!("failed to lock device list in update device {}", device_ip).as_str());
    let device_index = devices
        .iter()
        .position(|device| device.ip_address.to_string() == device_ip);
    match device_index {
        Some(device_index) => {
            devices[device_index] = device.into_inner();
            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// delete a device in the list of devices
// if the device is not found, return a 404 Not Found
// if the device is found, delete it and return a 200 OK
#[delete("/devices/{device_ip}")]
async fn delete_device(device_ip: web::Path<String>) -> impl Responder {
    let device_ip = device_ip.into_inner();
    let mut devices = DEVICE_LIST
        .lock()
        .expect(format!("failed to lock device list in delete device {}", device_ip).as_str());
    let device_index = devices
        .iter()
        .position(|device| device.ip_address.to_string() == device_ip);
    match device_index {
        Some(device_index) => {
            devices.remove(device_index);
            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// notify the system that the stream is finished by the client device
// if the stream is not found, return a 404 Not Found
// if the stream is found, update its status and return a 200 OK
#[post("/streams/{stream_id}/finished")]
async fn stream_finished(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
    req: HttpRequest,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in stream finished {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            if let Some(val) = req.peer_addr() {
                // get the ip address of the client
                let ip = val.ip().to_string();

                stream_entry.finish_stream(&ip);
                println!("Address {:?}", val.ip());
            };

            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// notify the system that the stream is started by the client device
// if the stream is not found, return a 404 Not Found
// if the stream is found, update its status and return a 200 OK
#[post("/streams/{stream_id}/started")]
async fn stream_started(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
    req: HttpRequest,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().expect(
        format!(
            "Failed to lock streams_entries in stream started {}",
            stream_id
        )
        .as_str(),
    );
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            if let Some(val) = req.peer_addr() {
                // get the ip address of the client
                
                stream_entry.start_stream();
                println!("Address {:?} started the stream", val.ip());
            };

            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

// TODO: add a route to ping any device in the list of devices to check if it is connected or not and update its status accordingly (online/offline)


// Initializes all routes for the application
// This is called in main.rs
pub fn init_routes(config: &mut web::ServiceConfig) {
    config
        .service(index)
        .service(get_streams)
        .service(get_stream)
        .service(post_stream)
        .service(delete_stream)
        .service(update_stream)
        .service(start_stream)
        .service(stream_started)
        .service(force_start_stream)
        .service(start_all_streams)
        .service(stop_stream)
        .service(stop_all_streams)
        .service(force_stop_stream)
        .service(get_stream_status)
        .service(get_all_streams_status)
        .service(get_devices)
        .service(get_device)
        .service(add_device)
        .service(update_device)
        .service(delete_device)
        .service(stream_finished);
}
