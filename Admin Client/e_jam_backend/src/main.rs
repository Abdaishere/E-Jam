use actix_web::{web, App, HttpServer};
use log::info;

use std::env;
#[cfg(feature = "fake_data")]
use std::thread;
#[cfg(feature = "fake_data")]
mod faker;
mod models;
mod services;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let args: Vec<String> = env::args().collect();

    // Default values for host and port
    let mut host = String::from("localhost");
    let mut port = 8084;

    // Check if command line arguments were provided
    if args.len() > 1 {
        host = args[1].clone();
    }
    if args.len() > 2 {
        port = args[2].parse().unwrap();
    }

    log4rs::init_file("logger.yml", Default::default()).unwrap();

    let app_state = web::Data::new(models::AppState::default());

    // generate fake data for Devices and StreamEntry Struct
    #[cfg(feature = "fake_data")]
    faker::generate_fake_metrics(&app_state).await;

    // start fake data for generator and verifier statics
    #[cfg(feature = "fake_data")]
    {
        use crate::models::{Device, StreamEntry};
        let streams: Vec<StreamEntry> = app_state
            .stream_entries
            .lock()
            .await
            .values()
            .cloned()
            .collect();

        let devices: Vec<Device> = app_state
            .device_list
            .lock()
            .await
            .values()
            .cloned()
            .collect();

        let dev_s = devices.clone();
        let str_s = streams.clone();
        thread::spawn(|| {
            faker::run_generator_faker(dev_s, str_s);
        });

        let dev_s = devices;
        let str_s = streams.clone();
        thread::spawn(|| {
            faker::run_verifier_faker(dev_s, str_s);
        });
    }

    info!("running on http://{}:{}", host, port);
    HttpServer::new(move || {
        App::new()
            .app_data(app_state.clone())
            .service(services::index)
            .configure(services::init_routes)
    })
    .bind(format!("{}:{}", host, port))?
    .run()
    .await
}
