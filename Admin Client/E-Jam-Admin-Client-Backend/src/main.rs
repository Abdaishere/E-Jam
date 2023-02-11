use actix_web::{web, App, HttpServer};
mod models;
mod services;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let app_state = web::Data::new(models::AppState::default());

    HttpServer::new(move || {
        App::new()
            .app_data(app_state.clone())
            .service(services::index)
            .configure(services::init_routes)
    })
    .bind("localhost:8080")?
    .run()
    .await
}
