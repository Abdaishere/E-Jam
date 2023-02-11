use super::models::{AppState, StreamEntry, StreamStatus};
use actix_web::{delete, get, post, put, web, HttpResponse, Responder};

// get the list of streams
#[get("/streams")]
async fn get_streams(data: web::Data<AppState>) -> impl Responder {
    let streams_entries = data.streams_entries.lock().unwrap().to_vec();
    print!("{:?}", streams_entries);
    HttpResponse::Ok().json(streams_entries)
}

// get a stream from the list of streams
// if the stream is not found, return a 404 Not Found
// if the stream is found, return the stream
#[get("/streams/{stream_id}")]
async fn get_stream(stream_id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let streams_entries = data.streams_entries.lock().unwrap();
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
    let stream_id = stream_entry.get_stream_id().to_string();
    let stream_entry_check = streams_entries
        .iter()
        .find(|&stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry_check {
        Some(_) => HttpResponse::Conflict().finish(),
        None => {
            streams_entries.push(stream_entry.into_inner());
            HttpResponse::Created().finish()
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
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
#[put("/streams/{stream_id}")]
async fn update_stream(
    stream_id: web::Path<String>,
    _stream_entry: web::Json<StreamEntry>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mut streams_entries = data.streams_entries.lock().unwrap();
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            // if the stream is running, stop it
            if stream_entry.get_stream_status() == &StreamStatus::Running {
                stream_entry.stop_stream().await.unwrap();
            }

            // if the stream is queued, remove it from the queue
            if stream_entry.get_stream_status() == &StreamStatus::Queued {
                stream_entry.remove_stream_from_queue().await;
            }

            // update the stream
            *stream_entry = _stream_entry.clone();

            HttpResponse::Ok().finish()
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            // if the stream is running, stop it
            // if the stream is queued, remove it from the queue
            if stream_entry.get_stream_status() == &StreamStatus::Running {
                stream_entry.stop_stream().await.unwrap();
            }

            if stream_entry.get_stream_status() == &StreamStatus::Queued {
                stream_entry.remove_stream_from_queue().await;
            }

            // start the stream
            stream_entry.send_stream().await.unwrap();
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
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
                stream_entry.stop_stream().await.unwrap();
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
    let stream_entry = streams_entries
        .iter_mut()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => {
            stream_entry.stop_stream().await.unwrap();
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
    let mut streams_entries = data.streams_entries.lock().unwrap();
    for stream_entry in streams_entries.iter_mut() {
        if !(stream_entry.get_stream_status() == &StreamStatus::Stopped
            || stream_entry.get_stream_status() == &StreamStatus::Finished
            || stream_entry.get_stream_status() == &StreamStatus::Created)
        {
            // if the stream is queued, remove it from the queue
            if stream_entry.get_stream_status() == &StreamStatus::Queued {
                stream_entry.remove_stream_from_queue().await;
            } else {
                stream_entry.stop_stream().await.unwrap();
            }
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
    let streams_entries = data.streams_entries.lock().unwrap();
    let stream_entry = streams_entries
        .iter()
        .find(|stream_entry| stream_entry.get_stream_id().to_string() == stream_id);
    match stream_entry {
        Some(stream_entry) => HttpResponse::Ok().json(stream_entry.get_stream_status()),
        None => HttpResponse::NotFound().finish(),
    }
}

// get the status of all streams in the list of streams
#[get("/streams/status")]
async fn get_all_streams_status(data: web::Data<AppState>) -> impl Responder {
    let streams_entries = data.streams_entries.lock().unwrap();
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
async fn index() -> &'static str {
    "
    <style>
        h1 {
            text-align: center;
        }
    </style>
    <h1>Welcome to the E-Jam API!</h1>
    <h1>Read the documentation at README.md</h1>
    "
}

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
        .service(force_start_stream)
        .service(start_all_streams)
        .service(stop_stream)
        .service(stop_all_streams)
        .service(force_stop_stream)
        .service(get_stream_status)
        .service(get_all_streams_status);
}
