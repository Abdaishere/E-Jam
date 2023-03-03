package com.example.systemapi.InstanceControl;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.Map;


/**
 * Receive the configuration from the admin gui and pass it to the configuration manager
 */
@RestController
@RequestMapping(path = "/")
public class Communicator {

    /**
     * Get configuration from Admin GUI
     */
    @PostMapping("/connect")
    public ResponseEntity connect(@RequestBody Map<String, Object> jsonObj) {
        String macAddress = (String) jsonObj.get("mac_address");
        System.out.println("Received mac address: " + macAddress);
        if (macAddress.equals(UTILs.getMyMacAddress())) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok().build();
    }

    @PostMapping("/start")
    public ResponseEntity startStream(@RequestBody Map<String, Object> jsonObj) {
        String streamID = (String) jsonObj.get("stream_id");
        long delay = Long.valueOf(jsonObj.get("delay").toString());
        ArrayList<String> generators = (ArrayList<String>) jsonObj.get("generators");
        ArrayList<String> verifiers = (ArrayList<String>) jsonObj.get("verifiers");
        PayloadType payloadType = PayloadType.values()[Integer.valueOf(jsonObj.get("payload_type").toString())];
        long numberOfPackets = Long.valueOf(jsonObj.get("number_of_packets").toString());
        long bcFramesNum = Long.valueOf(jsonObj.get("broadcast_frames").toString());
        int payloadLength = Integer.valueOf(jsonObj.get("broadcast_frames").toString());
        int seed = Integer.valueOf(jsonObj.get("seed").toString());
        long interFrameGap = Long.valueOf(jsonObj.get("inter_frame_gap").toString());
        long lifeTime = Long.valueOf(jsonObj.get("time_to_live").toString());
        TransportProtocol transportProtocol = TransportProtocol.values()[Integer.valueOf(jsonObj.get("transport_layer_protocol").toString())];
        FlowType flowType = FlowType.values()[Integer.valueOf(jsonObj.get("flow_type").toString())];
        boolean checkContent = Boolean.valueOf(jsonObj.get("check_content").toString());

        ArrayList<Stream> streams = new ArrayList<>();
        streams.add(new Stream(streamID, delay, generators, verifiers, payloadType,
                numberOfPackets, payloadLength, seed, bcFramesNum, interFrameGap,
                lifeTime, transportProtocol, flowType, checkContent));

        Thread thread = new Thread(new InstanceController(streams));
        thread.start();

        return ResponseEntity.ok().build();
    }

    @PostMapping("/stop")
    public ResponseEntity stopStream(@RequestBody Map<String, Object> jsonObj) {
        String streamId = (String) jsonObj.get("stream_id");

        // stream is not running
        if (!StreamController.containsStream(streamId)) {
            return ResponseEntity.badRequest().build();
        }

        // get stream from its id
        InstanceController instanceController = StreamController.getStreamById(streamId);

        // kill all processes of the stream
        instanceController.killStreams();

        // remove stream from running streams
        StreamController.removeStream(streamId);

        return ResponseEntity.ok().build();
    }

    // notify admin-client that stream has started
    public static void started(String streamId) {
        String url = "http://localhost:8080/streams/" + streamId + "/started";
        RestTemplate restTemplate = new RestTemplate();
        restTemplate.postForObject(url, null, String.class);
    }

    // notify admin-client that stream has finished
    public static void finished(String streamId) {
        String url = "http://localhost:8080/streams/" + streamId + "/finished";
        RestTemplate restTemplate = new RestTemplate();
        restTemplate.postForObject(url, null, String.class);
    }

    public static void main(String[] args) {
//        Communicator.started("000");
//        Communicator.finished("000");
    }
}
