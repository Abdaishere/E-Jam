use super::AppState;
use crate::models::device::Device;
use actix_web::Responder;
use actix_web::{delete, get, post, put, web, HttpRequest, HttpResponse};

#[doc = r"# Get all devices
get all devices in the list of devices
if the list is empty, return a 204 No Content
if the list is not empty, return a 200 OK
if the list is not found, return a 500 Internal Server Error
## Arguments
* `device_list` - the list of devices
## Returns
* `HttpResponse` - the http response"]
#[get("/devices")]
async fn get_devices(data: web::Data<AppState>) -> impl Responder {
    let devices = data
        .device_list
        .lock()
        .expect("failed to lock device list in get all devices")
        .clone();

    match devices.len() {
        0 => HttpResponse::NoContent()
            .body("No devices in system, please add some devices to use them in the system"),
        _ => HttpResponse::Ok().json(devices),
    }
}

#[doc = r"# Get a device
get a device in the list of devices
if the device is not found, return a 404 Not Found
if the device is found, return a 200 OK
## Arguments
* `device_mac` - the device mac address
## Returns
* `HttpResponse` - the http response
## Panics
* `failed to lock device list in get device {device_mac}` - if the device list is not found in the mutex lock"]
#[get("/devices/{device_mac}")]
async fn get_device(device_mac: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let device_mac = device_mac.into_inner();
    let devices = data
        .device_list
        .lock()
        .expect(format!("failed to lock device list in get device {}", device_mac).as_str());

    let device = devices
        .iter()
        .find(|device| device.get_device_mac() == &device_mac);
    match device {
        Some(device) => HttpResponse::Ok().json(device),
        None => HttpResponse::NotFound().body(format!(
            "Device {} not found, please check the device mac address and try again",
            device_mac
        )),
    }
}

#[doc = r"# add a device
add a device to the list of devices
if the device is already in the list, return a 409 Conflict
if the device is not in the list, add it and return a 201 Created
## Arguments
* `device` - the device to add
## Returns
* `HttpResponse` - the http response
## Panics
* `failed to lock device list in add device {device_mac}` - if the device list is not found in the mutex lock"]
#[post("/devices")]
async fn add_device(device: web::Json<Device>, data: web::Data<AppState>) -> impl Responder {
    let mut devices = data.device_list.lock().expect(
        format!(
            "failed to lock device list in add device {}",
            device.get_device_mac()
        )
        .as_str(),
    );
    let device_index = devices
        .iter()
        .position(|device| device.get_device_mac() == device.get_device_mac());
    match device_index {
        Some(_device_index) => HttpResponse::Conflict().body(format!("Device {} already exists in the system, please change the device mac address and try again", device.get_device_mac())),
        None => {
            let mac = device.get_device_mac().clone();
            devices.push(device.into_inner());
            HttpResponse::Created().body(format!("Device {} added successfully", mac))
        }
    }
}

// TODO: document this function
#[get("/devices/{device_mac}/ping")]
async fn ping_device(device_mac: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let device_mac = device_mac.into_inner();
    let mut devices = data
        .device_list
        .lock()
        .expect(format!("failed to lock device list in ping device {}", device_mac).as_str());

    let device_index = devices
        .iter()
        .position(|device| device.get_device_mac() == &device_mac);

    match device_index {
        Some(device_index) => {
            let response = devices[device_index].is_reachable();
            match response {
                true => HttpResponse::Ok().body("Device is reachable and online in the network"),
                false => HttpResponse::InternalServerError()
                    .body("Could not reach the device, please check the device and try again"),
            }
        }
        None => HttpResponse::NotFound().body(format!(
            "Device {} not found, please check the device mac address and try again",
            device_mac
        )),
    }
}

#[doc = r"# Check a new device
ping a device provided from the user this is used only to check if the device is reachable or not for the user
and does not update the device in the list of devices
if the device is not reachable, return a 404 Not Found
if the device is reachable, return a 200 OK
## Arguments
* `device` - the device to ping
## Returns
* `HttpResponse` - the http response"]
#[post("/devices/ping")]
async fn check_new_device(device: web::Json<Device>) -> impl Responder {
    let mut device = device.into_inner();
    let response = device.is_reachable();

    match response {
        true => HttpResponse::Ok()
            .body("Device is reachable and online in the network and can be added to the system"),
        false => HttpResponse::InternalServerError()
            .body("Could not reach the device, please check the data and try again"),
    }
}

#[doc = r"# Ping all devices
ping all devices in the list of devices
if the list is empty, return a 204 No Content
if the list is not empty, return a 200 OK
if the list is not found, return a 500 Internal Server Error
## Arguments
* `device_list` - the list of devices in the system to ping
## Returns
* `HttpResponse` - the http response"]
#[get("/devices/ping_all")]
async fn ping_all_devices(data: web::Data<AppState>) -> impl Responder {
    let mut devices = data
        .device_list
        .lock()
        .expect("failed to lock device list in ping all devices");

    match devices.len() {
        0 => HttpResponse::NoContent().body("No devices in the system, please add some devices and try again"),
        _ => {
            let mut counter = 0;
            for device in devices.iter_mut() {
                counter += device.is_reachable() as usize;
            }
            match counter {
                0 => HttpResponse::InternalServerError().body("Could not reach any device, please check the devices and try again"),
                _ => HttpResponse::Ok().body(format!(
                    "Ping all devices completed, {} devices are reachable and online in the network",
                    counter
                ))
                
            }
        }
    }
}

#[doc = r"# Update a device
update a device in the list of devices
if the device is not found, return a 404 Not Found
if the device is found, update it and return a 200 OK
## Arguments
* `device_mac` - the mac address of the device
* `device` - the device data to update
## Returns
* `HttpResponse` - the http response
## Panics
* `failed to lock device list in update device {device_mac}` - if the device list is not found in the mutex lock
## Logs
* `updating device {device}` - if the device is found and updated"]
#[put("/devices/{device_mac}")]
async fn update_device(
    device_mac: web::Path<String>,
    device: web::Json<Device>,
    data: web::Data<AppState>,
) -> impl Responder {
    let device_mac = device_mac.into_inner();

    let mut devices = data
        .device_list
        .lock()
        .expect(format!("failed to lock device list in update device {}", device_mac).as_str());

    let device_entry = devices
        .iter_mut()
        .find(|device| device.get_device_mac() == &device_mac);

    match device_entry {
        Some(device_entry) => {
            // this is used to prevent the user from changing the mac address of the device in the update request without deleting and adding the device again to the list
            // to ensure that the user is not changing the mac address of the device in the update request accidentally
            if device_entry.get_device_mac() != device.get_device_mac() {
                return HttpResponse::BadRequest().body("The mac address of the device cannot be changed in the update request, please delete the device and add it again with the new mac address");
            }

            *device_entry = device.clone();
            println!("updated device: {:#?}", device);
            HttpResponse::Ok().body(format!("Device {} updated successfully", device_mac))
        }
        None => HttpResponse::NotFound().body(format!(
            "Device {} not found, please check the device mac address and try again",
            device_mac
        )),
    }
}

#[doc = r"# Delete a device
delete a device in the list of devices
if the device is not found, return a 404 Not Found
if the device is found, delete it and return a 200 OK
## Arguments
* `device_mac` - the mac address of the device
## Returns
* `HttpResponse` - the http response
## Panics
* `failed to lock device list in delete device {device_mac}` - if the device list is not found in the mutex lock"]
#[delete("/devices/{device_mac}")]
async fn delete_device(device_mac: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let device_mac = device_mac.into_inner();
    let mut devices = data
        .device_list
        .lock()
        .expect(format!("failed to lock device list in delete device {}", device_mac).as_str());
    let device_index = devices
        .iter()
        .position(|device| device.get_device_mac() == &device_mac);
    match device_index {
        Some(device_index) => {
            devices.remove(device_index);
            HttpResponse::Ok().body(format!("Device {} deleted successfully and will not be reachable in the system", device_mac))
        }
        None => HttpResponse::NotFound().body(format!(
            "Device {} not found, please check the device mac address and try again",
            device_mac
        )),
    }
}

#[doc = r"# Notify Stream Finished
notify the system that the stream is finished by the device
if the stream is not found, return a 404 Not Found
if the stream is found, update its status and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state
* `req` - the http request to get the client ip address
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in stream finished {stream_id}` - if the streams_entries is not found in the mutex lock
## Logs
* `stream finished {stream_id} by {ip}` - if the stream is found and updated"]
#[post("/streams/{stream_id}/finished")]
async fn stream_finished(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
    req: HttpRequest,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mac_address = req.headers().get("mac-address").unwrap().to_str().unwrap();
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

                stream_entry.notify_process_completed(mac_address, &data.device_list);
                println!("stream finished {} by {}", stream_id, ip);
            };

            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}

#[doc = r"# Notify Stream Started
notify the system that the stream is started by the device
if the stream is not found, return a 404 Not Found
if the stream is found, update its status and return a 200 OK
## Arguments
* `stream_id` - the id of the stream
* `data` - the app state
* `req` - the http request to get the client ip address
## Returns
* `HttpResponse` - the http response
## Panics
* `Failed to lock streams_entries in stream started {stream_id}` - if the streams entries are not found in the mutex lock
## Logs
* `Address {ip} started the stream {stream_id}` - if the stream is found and updated"]
#[post("/streams/{stream_id}/started")]
async fn stream_started(
    stream_id: web::Path<String>,
    data: web::Data<AppState>,
    req: HttpRequest,
) -> impl Responder {
    let stream_id = stream_id.into_inner();
    let mac_address = req.headers().get("mac-address").unwrap().to_str().unwrap();
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
                stream_entry.notify_process_running(mac_address, &data.device_list);
                println!(
                    "Address {} notified of starting the stream {}",
                    val.ip(),
                    stream_id
                );
            };

            HttpResponse::Ok().finish()
        }
        None => HttpResponse::NotFound().finish(),
    }
}
