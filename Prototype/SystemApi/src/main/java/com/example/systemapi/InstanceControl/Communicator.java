package com.example.systemapi.InstanceControl;

import org.springframework.boot.configurationprocessor.json.JSONException;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Map;
import org.springframework.boot.configurationprocessor.json.JSONObject;

/**
 * Receive the configuration from the admin gui and pass it to the configuration manager
 */
@RestController
@RequestMapping(path = "/")
public class Communicator {
    /**
     * Get configuration from Admin GUI
     */
    private final static String ADMIN_IP = "192.168.1.18";
    private final static String MAC_ADDRESS = UTILs.getMyMacAddress();

    @PostMapping("/")
    public ResponseEntity index() {
        return ResponseEntity.ok().build();
    }

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
    public ResponseEntity startStream(@RequestBody String stringObj) throws JSONException {
        System.out.println(stringObj);
        JSONObject jsonObj = new JSONObject(stringObj);
        System.out.println(jsonObj);
        String streamID = (String) jsonObj.get("stream_id");
        long delay = Long.valueOf(jsonObj.get("delay").toString());
        String generator = (String) jsonObj.get("generators");
        String verifier = (String) jsonObj.get("verifiers");
        ArrayList<String> generators = new ArrayList<>();
        generators.add(generator);
        ArrayList<String> verifiers = new ArrayList<>();
        verifiers.add(verifier);
//        ArrayList<String> generators = (ArrayList<String>) jsonObj.get("generators");
//        ArrayList<String> verifiers = (ArrayList<String>) jsonObj.get("verifiers");
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
    public ResponseEntity stopStream(@RequestBody String streamId) {
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
    public static void started(String streamId) throws URISyntaxException {
        URI uri = new URI("http://" + ADMIN_IP + ":8080/streams/" + streamId  + "/started");
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.TEXT_PLAIN);
        RestTemplate restTemplate = new RestTemplate();
        HttpEntity<String> body = new HttpEntity<>(MAC_ADDRESS);
        ResponseEntity<String> response = restTemplate.postForEntity(uri, body, String.class);
        System.out.println(response);
    }

    // notify admin-client that stream has finished
    public static void finished(String streamId) {
        String url = "http://" + ADMIN_IP + ":8080/streams/" + streamId + "/finished";
        RestTemplate restTemplate = new RestTemplate();
        restTemplate.postForObject(url, MAC_ADDRESS, String.class);
    }

    public static void main(String[] args) {
//        Communicator.started("000");
//        Communicator.finished("000");
    }
}
