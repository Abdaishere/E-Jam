use std::thread;

use actix_web::{web, App, HttpServer};
use log::info;

use crate::services::statistics::{run_generator_consumer, run_verifier_consumer};
mod models;
mod services;
#[cfg(feature = "fake_data")]
mod test;

const PORT: u16 = 8080;
const HOST: &str = "localhost";

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    log4rs::init_file("logger.yml", Default::default()).unwrap();

    let app_state = web::Data::new(models::AppState::default());

    // generate fake data for Devices and StreamEntry Struct
    #[cfg(feature = "fake_data")]
    test::generate_fake_metrics(&app_state).await;

    // start consumer threads for generator and verifier statistics
    thread::spawn(|| {
        run_generator_consumer();
    });

    thread::spawn(|| {
        run_verifier_consumer();
    });

    // start fake data generator and verifier statics
    // #[cfg(feature = "fake_data")]
    // {
    //     use crate::models::{Device, StreamEntry};
    //     let streams: Vec<StreamEntry> = app_state
    //         .stream_entries
    //         .lock()
    //         .await
    //         .values()
    //         .cloned()
    //         .collect();
    //     let devices: Vec<Device> = app_state
    //         .device_list
    //         .lock()
    //         .await
    //         .values()
    //         .cloned()
    //         .collect();
    //     let dev_s = devices.clone();
    //     let str_s = streams.clone();
    //     thread::spawn(|| {
    //         test::run_generator_faker(dev_s, str_s);
    //     });
    //     let dev_s = devices;
    //     let str_s = streams.clone();
    //     thread::spawn(|| {
    //         test::run_verifier_faker(dev_s, str_s);
    //     });
    // }

    info!("running on http://{}:{}", HOST, PORT);
    HttpServer::new(move || {
        App::new()
            .app_data(app_state.clone())
            .service(services::index)
            .configure(services::init_routes)
    })
    .bind(format!("{}:{}", HOST, PORT))?
    .run()
    .await
}
