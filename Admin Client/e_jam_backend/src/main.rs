use actix_web::{web, App, HttpServer};
mod models;
mod services;

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
