use actix_web::{web, App, HttpServer};
use log::info;
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

    #[cfg(feature = "fake_data")]
    test::generate_fake_metrics(&app_state).await;

    // run consume on a separate thread
    std::thread::spawn(|| {
        services::consumer::run_generator_consumer();
    });

    std::thread::spawn(|| {
        services::consumer::run_verifier_consumer();
    });

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
