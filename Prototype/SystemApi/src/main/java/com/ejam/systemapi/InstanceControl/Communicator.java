package com.ejam.systemapi.InstanceControl;
import com.ejam.systemapi.GlobalVariables;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
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
    static GlobalVariables globalVariables = GlobalVariables.getInstance();

    @GetMapping("/")
    public ResponseEntity index() {
        return ResponseEntity.ok().build();
    }

    @PostMapping("/handshake")
    public Map<String, String> handshake(@RequestHeader("admin-address") String adminAddress, @RequestHeader("admin-port") int adminPort) {
        System.out.println("Received ip address: " + adminAddress);
        System.out.println("Received port number: " + adminPort);

        globalVariables.writeAdminConfig(adminAddress, adminPort);
        globalVariables.readAdminConfig();

        Map<String, String> response = new HashMap<>();
        response.put("mac-address", UTILs.convertToColonFormat(UTILs.getMyMacAddress(globalVariables.ADMIN_CLIENT_INTERFACE)));

        return response;
    }

    @PostMapping("/connect")
    public ResponseEntity connect(@RequestHeader("mac-address") String macAddress) {
        System.out.println("Received mac address: " + macAddress);

        String serverMacAddress = UTILs.convertToWithoutColonFormat(macAddress);
        System.out.println(macAddress);
        System.out.println(serverMacAddress);
        System.out.println(UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE));

        if (serverMacAddress.equals(UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE))) {
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.badRequest().build();
    }

    @PostMapping("/start")
    public ResponseEntity startStream(@RequestBody String stringObj) throws JsonProcessingException {
        System.out.println("Received configuration: " + stringObj);
        ObjectMapper mapper = new ObjectMapper();
        JsonNode jsonObj = mapper.readTree(stringObj);
        String streamID = jsonObj.get("streamId").asText();
        long delay = jsonObj.get("delay").asLong();

        ArrayList<String> generators = new ArrayList<>();
        JsonNode generatorsNode = jsonObj.get("generators");
        Iterator<JsonNode> generatorsIterator = generatorsNode.elements();
        while (generatorsIterator.hasNext()) {
            JsonNode generator = generatorsIterator.next();
            generators.add(UTILs.convertToWithoutColonFormat(generator.asText()));
        }

        ArrayList<String> verifiers = new ArrayList<>();
        JsonNode verifiersNode = jsonObj.get("verifiers");
        Iterator<JsonNode> verifiersIterator = verifiersNode.elements();
        while (verifiersIterator.hasNext()) {
            JsonNode verifier = verifiersIterator.next();
            verifiers.add(UTILs.convertToWithoutColonFormat(verifier.asText()));
        }

        PayloadType payloadType = PayloadType.values()[jsonObj.get("payloadType").asInt()];
        long numberOfPackets = jsonObj.get("numberOfPackets").asLong();
        long bcFramesNum = jsonObj.get("broadcastFrames").asLong();
        int payloadLength = jsonObj.get("payloadLength").asInt();
        int seed = jsonObj.get("seed").asInt();
        long interFrameGap = jsonObj.get("interFrameGap").asLong();
        long lifeTime = jsonObj.get("timeToLive").asLong();
        TransportProtocol transportProtocol = TransportProtocol.values()[jsonObj.get("transportLayerProtocol").asInt()];
        FlowType flowType = FlowType.values()[jsonObj.get("flowType").asInt()];
        long burstLen = jsonObj.get("burstLength").asLong();
        long burstDelay = jsonObj.get("burstDelay").asLong();
        boolean checkContent = jsonObj.get("checkContent").asBoolean();

        Stream stream = new Stream(streamID, delay, generators, verifiers, payloadType,
                numberOfPackets, payloadLength, seed, bcFramesNum, interFrameGap,
                lifeTime, transportProtocol, flowType, burstLen, burstDelay, checkContent);

        ConfigurationManager configurationManager = new ConfigurationManager(stream);
        InstanceController instanceController = new InstanceController(stream);
        Thread thread = new Thread(instanceController);
        thread.start();
        ProcessController.addProcess(new StreamProcess(instanceController, thread));

        return ResponseEntity.ok().build();
    }

    @PostMapping("/stop")
    public ResponseEntity stopStream(@RequestHeader("stream-id") String streamId) {
        System.out.println("Received stream id: " + streamId);
        // stream is not running
        if (!ProcessController.containsProcess(streamId)) {
            return ResponseEntity.badRequest().build();
        }

        // get stream from its id
        StreamProcess process = ProcessController.getProcessByStreamId(streamId);
        if (process.killed) {
            System.out.println("stream is already killed");
            return ResponseEntity.ok().build();
        }
        process.killed = true;

        System.out.println("Finished step 1");

        // kill all processes of the stream
        try {
            process.instanceController.killStreams();
        } catch (Exception e) {

        }

        // kill the thread made by that stream
        if (process.thread.isAlive()) {
            System.out.println("Thread is alive");
            process.thread.interrupt();
        }

        System.out.println("Finished step 2");

        // remove stream from running streams
        ProcessController.removeProcess(streamId);

        System.out.println("Finished step 3");

        return ResponseEntity.ok().build();
    }

    // notify admin-client that stream has started or finished
    public static void notify(String streamId, String type) throws URISyntaxException {
        globalVariables.readAdminConfig();

        URI uri = new URI(String.format("http://%s:%d/streams/%s/%s", globalVariables.ADMIN_ADDRESS, globalVariables.ADMIN_PORT, streamId, type));

        System.out.println(uri);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("mac-address", UTILs.convertToColonFormat(UTILs.getMyMacAddress(globalVariables.ADMIN_CLIENT_INTERFACE)));
        RestTemplate restTemplate = new RestTemplate();
        HttpEntity<String> request = new HttpEntity<>(null, headers);
        ResponseEntity<String> response = restTemplate.postForEntity(uri, request, String.class);
        System.out.println(response);
    }

    public static void main(String[] args) throws URISyntaxException {
        Communicator.notify("ABC", "started");
//        Communicator.notify("ABC", "finished");
    }
}
