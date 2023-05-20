use crate::{
    models::{AppState, RUNTIME},
    services::statistics::{run_generator_consumer, run_verifier_consumer},
};
use actix_web::{get, web, HttpResponse, Responder};
use kafka::consumer::FetchOffset;

#[doc = "Gets the all generators statistics for all streams"]
#[get("/statistics_all/generator/{fetch_offset}")]
async fn get_all_statistics_for_generator(fetch_offset: web::Path<String>) -> impl Responder {
    let fetch_offset = fetch_offset.into_inner();
    let offset: FetchOffset = match fetch_offset.as_str() {
        "earliest" => FetchOffset::Earliest,
        "latest" => FetchOffset::Latest,
        _ => {
            return HttpResponse::NotFound().body(String::from(
                "Invalid fetch offset. Please use 'earliest' or 'latest'",
            ))
        }
    };
    let handle = RUNTIME.spawn_blocking(move || run_generator_consumer("", "", offset));
    match handle.await {
                Ok(generators) => match generators {
                    Ok(generators) => HttpResponse::Ok().json(generators),
                    Err(_) => HttpResponse::InternalServerError().body(String::from("An error occurred while fetching data please check the server logs for more details"),
                ),
                },
                Err(e) => HttpResponse::InternalServerError().body(format!("Error: {:?}", e),
            ),
    }
}

#[doc = "Gets the all generators statistics for all streams"]
#[get("/statistics_all/verifier/{fetch_offset}")]
async fn get_all_statistics_for_verifier(fetch_offset: web::Path<String>) -> impl Responder {
    let fetch_offset = fetch_offset.into_inner();
    let offset: FetchOffset = match fetch_offset.as_str() {
        "earliest" => FetchOffset::Earliest,
        "latest" => FetchOffset::Latest,
        _ => {
            return HttpResponse::NotFound().body(String::from(
                "Invalid fetch offset. Please use 'earliest' or 'latest'",
            ))
        }
    };

    let handle = RUNTIME.spawn_blocking(move || run_verifier_consumer("", "", offset));
    match handle.await {
                Ok(verifiers) => match verifiers {
                    Ok(verifiers) => HttpResponse::Ok().json(verifiers),
                    Err(_) => HttpResponse::InternalServerError().body(String::from("An error occurred while fetching data please check the server logs for more details"),),
                },
                Err(e) => HttpResponse::InternalServerError().body(format!("Error: {:?}", e),
            ),
    }
}

#[doc = "Gets the earliest generator statistics for a stream"]
#[get("/streams/{stream_id}/statistics/generator/earliest")]
async fn get_stream_statistics_for_generator(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let stream_entry = data.stream_entries.lock().await.contains_key(&stream_id);

    match stream_entry {
        true => {
            let handle = RUNTIME.spawn_blocking(move || {
                run_generator_consumer(&stream_id, "", FetchOffset::Earliest)
            });

            match handle.await {
                Ok(generators) => match generators {
                    Ok(generators) => HttpResponse::Ok().json(generators),
                    Err(_) => HttpResponse::InternalServerError().body(String::from("An error occurred while fetching data please check the server logs for more details")),
                },
                Err(e) => HttpResponse::InternalServerError().body(format!("Error: {:?}", e)),
            }
        }
        false => HttpResponse::NotFound().body(format!(
            "stream {} not found to check its status, please check the stream id and try again",
            stream_id
        )),
    }
}

#[doc = "Gets the earliest verifier statistics for a stream"]
#[get("/streams/{stream_id}/statistics/verifier/earliest")]
async fn get_stream_statistics_for_verifier(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let stream_entry = data.stream_entries.lock().await.contains_key(&stream_id);

    match stream_entry {
        true => {
            let handle = RUNTIME.spawn_blocking(move || {
                run_verifier_consumer(&stream_id, "", FetchOffset::Earliest)
            });

            match handle.await {
                Ok(verifiers) => match verifiers {
                    Ok(verifiers) => HttpResponse::Ok().json(verifiers),
                    Err(_) => HttpResponse::InternalServerError().body(String::from("An error occurred while fetching data please check the server logs for more details")),
                },
                Err(e) => HttpResponse::InternalServerError().body(format!("Error: {:?}", e)),
            }
        }
        false => HttpResponse::NotFound().body(format!(
            "stream {} not found to check its status, please check the stream id and try again",
            stream_id
        )),
    }
}

#[doc = "Gets the earliest generator statistics for a device"]
#[get("/devices/{device_mac}/statistics/generator/earliest")]
async fn get_device_statistics_for_generator(
    device_mac: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let device_mac = device_mac.into_inner();
    let device = data.device_list.lock().await.contains_key(&device_mac);

    match device {
        true => {
            let handle = RUNTIME.spawn_blocking(move || {
                run_generator_consumer("", &device_mac, FetchOffset::Earliest)
            });

            match handle.await {
                Ok(generators) => match generators {
                    Ok(generators) => HttpResponse::Ok().json(generators),
                    Err(_) => HttpResponse::InternalServerError().body(String::from("An error occurred while fetching data please check the server logs for more details")),
                },
                Err(e) => HttpResponse::InternalServerError().body(format!("Error: {:?}", e)),
            }
        }
        false => HttpResponse::NotFound().body(format!(
            "Device {} not found, please check the device mac address and try again",
            device_mac
        )),
    }
}

#[doc = "Gets the earliest verifier statistics for a device"]
#[get("/devices/{device_mac}/statistics/verifier/earliest")]
async fn get_device_statistics_for_verifier(
    device_mac: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let device_mac = device_mac.into_inner();
    let device = data.device_list.lock().await.contains_key(&device_mac);

    match device {
        true => {
            let handle = RUNTIME.spawn_blocking(move || {
                run_verifier_consumer("", &device_mac, FetchOffset::Earliest)
            });

            match handle.await {
                Ok(verifiers) => match verifiers {
                    Ok(verifiers) => HttpResponse::Ok().json(verifiers),
                    Err(_) => HttpResponse::InternalServerError().body(String::from("An error occurred while fetching data please check the server logs for more details")),
                },
                Err(e) => HttpResponse::InternalServerError().body(format!("Error: {:?}", e)),
            }
        }
        false => HttpResponse::NotFound().body(format!(
            "Device {} not found, please check the device mac address and try again",
            device_mac
        )),
    }
}
