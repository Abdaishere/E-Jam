use actix_web::{web, App, HttpServer};
use log::info;
mod models;
mod services;

#[cfg(feature = "fake_data")]
mod faker;

#[cfg(feature = "fake_data")]
const FAKE_DEVICES_COUNT: usize = 1e3 as usize;

#[cfg(feature = "fake_data")]
const FAKE_STREAM_ENTRIES_COUNT: usize = 1e5 as usize;

#[doc = r"This is the port that the server will listen on"]
const PORT: u16 = 8080;

#[doc = r"This is the host that the server will listen on"]
const HOST: &str = "localhost";

#[doc = r"This is the main function that starts the server
It is the entry point of the application
It is annotated with the `#[actix_web::main]` attribute which is a macro that creates an asynchronous main function that runs the server on a separate thread and waits for it to finish before exiting the program
The Host and Port are defined as constants at the top of the file and are used to bind the server to the specified host and port"]
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let app_state = web::Data::new(models::AppState::default());

    log4rs::init_file("logger.yml", Default::default()).unwrap();
    info!("running on http://{}:{}", HOST, PORT);

    // run consume on a separate thread
    std::thread::spawn(|| {
        services::consumer::run_generator_consumer();
    });

    std::thread::spawn(|| {
        services::consumer::run_verifier_consumer();
    });

    #[cfg(feature = "fake_data")]
    println!("Fake data feature enabled");

    // generate testing data
    #[cfg(feature = "fake_data")]
    faker::generate_fake_devices(&app_state.device_list, FAKE_DEVICES_COUNT).await;

    #[cfg(feature = "fake_data")]
    faker::generate_fake_stream_entries(
        &app_state.stream_entries,
        &app_state.device_list,
        FAKE_STREAM_ENTRIES_COUNT,
        &app_state.stream_id_counter,
        &app_state.stream_entries,
    )
    .await;

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
