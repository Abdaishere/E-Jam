# E-Jam API

<img src="E-Jam-api-logo.png" alt="E-Jam API" width="400"/>

![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=for-the-badge&logo=rust&logoColor=white)
![Actix Web](https://img.shields.io/badge/Actix-%23000000.svg?style=for-the-badge&logo=actix&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-%23000000.svg?style=for-the-badge&logo=ubuntu&logoColor=white)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-%23000000.svg?style=for-the-badge&logo=raspberry-pi&logoColor=white)
![RestFul API](https://img.shields.io/badge/RestFul%20API-%23000000.svg?style=for-the-badge&logo=restful-api&logoColor=white)

## The E-Jam API documentation

This API is used to create and manage streams.
The E-Jam API is a REST API that allows you to manage the list of streams in the E-Jam application.
The API is implemented using the Actix Web framework and Rust.

The API is hosted on a Raspberry Pi 4 Model B with 4GB of RAM.
The Raspberry Pi is connected to a 1Gbps network.
The Raspberry Pi is running Ubuntu 20.04 LTS.

The API is hosted on port 8080.
The API is hosted on the IP address

## Stream State Machine

The stream state machine is as follows:

![Stream State Machine](./stream_state_machine.png)

note: The stream state finished is only applied when all devices have finished sending and receiving packets.

The Device State Machine is as follows:

![Device State Machine](./device_state_machine.png)

## API Documentation

The API documentation is available at [http://localhost:8080/](http://localhost:8080/).

## Routes

### GET /streams

Returns a list of all streams in the list of streams.

### GET /streams/{stream_id}

Returns the stream with the given stream_id.

### POST /streams

Adds a new stream to the list

### DELETE /streams/{stream_id}

Deletes the stream with the given stream_id.

### PUT /streams/{stream_id}

Updates the stream with the given stream_id.

### POST /streams/{stream_id}/start

Starts the stream with the given stream_id.

### POST /streams/{stream_id}/force_start

Forces the stream with the given stream_id to start.

### POST /streams/start_all

Starts all streams in the list of streams.

### POST /streams/{stream_id}/stop

Stops the stream with the given stream_id.

### POST /streams/{stream_id}/force_stop

Forces the stream with the given stream_id to stop.

### POST /streams/stop_all

Stops all streams in the list of streams.

### GET /streams/{stream_id}/status

Returns the status of the stream with the given stream_id.

### GET /streams/status

Returns the status of all streams in the list of streams.

### GET /devices

Returns a list of all devices in the list of devices.

### GET /devices/{device_ip}

Returns the device with the given device ip address.

### POST /devices

Adds a new device to the list

### DELETE /devices/{device_ip}

Deletes the device with the given device_ip.

### PUT /devices/{device_ip}

Updates the device with the given device_ip.

## Stream object

The structure of the Stream object as a table is as follows:

<table>
<tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required</th>
    <th>Default</th>
    <th>Min</th>
    <th>Max</th>
    <th>Validation</th>
</tr>
<tr>
    <td>stream_id</td>
    <td>String</td>
    <td>Yes</td>
    <td></td>
    <td>3</td>
    <td>3</td>
    <td>stream_id must be 3 characters long, stream_id must be alphanumeric</td>
</tr>
<tr>
    <td>stream_start_time</td>
    <td>u64</td>
    <td>No</td>
    <td>0</td>
    <td>0</td>
    <td></td>
    <td>stream_start_time must be greater than 0</td>
</tr>
<tr>
    <td>senders_name</td>
    <td>Vec of Strings (name or ip of device)</td>
    <td>Yes</td>
    <td></td>
    <td>1</td>
    <td></td>
    <td>number_of_senders must be greater than 0</td>
</tr>
<tr>
    <td>receivers_name</td>
    <td>Vec of Strings (name or ip of device)</td>
    <td>Yes</td>
    <td></td>
    <td>1</td>
    <td></td>
    <td>number_of_receivers must be greater than 0</td>
</tr>
<tr>
    <td>payload_type</td>
    <td>u8</td>
    <td>Yes</td>
    <td></td>
    <td>0</td>
    <td>2</td>
    <td>payload_type must be 0, 1 or 2</td>
</tr>
<tr>
    <td>number_of_packets</td>
    <td>u32</td>
    <td>Yes</td>
    <td></td>
    <td>0</td>
    <td></td>
    <td>number_of_packets must be greater than 0</td>
</tr>
<tr>
    <td>payload_length</td>
    <td>u16</td>
    <td>Yes</td>
    <td></td>
    <td>0</td>
    <td>1500</td>
    <td>payload_length must be between 0 and 1500</td>
</tr>
<tr>
    <td>seed</td>
    <td>u32</td>
    <td>Yes</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
</tr>
<tr>
    <td>broadcast_frames</td>
    <td>u32</td>
    <td>Yes</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
</tr>
<tr>
    <td>inter_frame_gap</td>
    <td>u32</td>
    <td>Yes</td>
    <td></td>
    <td>0</td>
    <td></td>
    <td>inter_frame_gap must be greater than 0</td>
</tr>
<tr>
    <td>time_to_live</td>
    <td>u32</td>
    <td>Yes</td>
    <td></td>
    <td>0</td>
    <td></td>
    <td>time_to_live must be greater than 0</td>
</tr>
<tr>
    <td>transport_layer_protocol</td>
    <td>TransportLayerProtocol</td>
    <td>No</td>
    <td>TCP</td>
    <td></td>
    <td></td>
    <td>transport_layer_protocol must be TCP or UDP</td>
</tr>
<tr>
    <td>flow_type</td>
    <td>FlowType</td>
    <td>No</td>
    <td>BtB</td>
    <td></td>
    <td></td>
    <td>flow_type must be BtB or Bursts</td>
</tr>
<tr>
    <td>check_content</td>
    <td>bool</td>
    <td>No</td>
    <td>false</td>
    <td></td>
    <td></td>
    <td>check_content must be true or false</td>
</tr>
<tr>
    <td>check_content</td>
    <td>bool</td>
    <td>No</td>
    <td>false</td>
    <td></td>
    <td></td>
    <td>check_content must be true or false</td>
</tr>
<tr>
    <td>stream_status</td>
    <td>StreamStatus</td>
    <td>No</td>
    <td>0</td>
    <td>0</td>
    <td></td>
    <td></td>
</tr>
</table>

## Device object

The structure of the Device object as a table is as follows:

<table>
<tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required</th>
    <th>Default</th>
    <th>Min</th>
    <th>Max</th>
    <th>Validation</th>
</tr>
<tr>
    <td>device_name</td>
    <td>String</td>
    <td>Yes</td>
    <td>defaulted to be either mac or ip address from client side</td>
    <td>1</td>
    <td></td>
    <td>device_name must be greater than 0 characters long</td>
</tr>
<tr>
    <td>device_ip</td>
    <td>String</td>
    <td>Yes</td>
    <td></td>
    <td>7</td>
    <td>15</td>
    <td>device_ip must be between 7 and 15 characters long, device_ip must be a valid ip address</td>
</tr>
<tr>
    <td>mac</td>
    <td>String</td>
    <td>Yes</td>
    <td></td>
    <td></td>
    <td></td>
    <td>must be a valid mac address</td>
</tr>
</table>

## System API endpoints

The following endpoints are available for the system API:

<table>
<tr>
    <th>Endpoint</th>
    <th>Method</th>
    <th>Body</th>
    <th>Response</th>
    <th>Description</th>
</tr>
<tr>
    <td>/connect</td>
    <td>GET</td>
    <td>mac address of the device</td>
    <td></td>
    <td>Connect to the system API</td>
</tr>
<tr>
    <td>/finish</td>
    <td>POST</td>
    <td></td>
    <td>Stream_id</td>
    <td>Notify the Admin-Client that the Stream has finished only when the stream is finished in the systemAPI side</td>
</tr>
<tr>
    <td>/start</td>
    <td>POST</td>
    <td>Stream.to_string()</td>
    <td>Success</td>
    <td>Try to Start the Stream</td>
</tr>
<tr>
    <td>/stop</td>
    <td>POST</td>
    <td>stream_id</td>
    <td>Success</td>
    <td>Stop a currently running Stream</td>
</tr>
</table>
