package com.example.systemapi.InstanceControl;

import org.springframework.boot.json.JsonParser;
import org.springframework.boot.json.JsonParserFactory;
import org.springframework.web.client.RestTemplate;


import java.util.ArrayList;
import java.util.Map;


/**
 * Receive the configuration from the admin gui and pass it to the configuration manager
 */
public class Communicator implements Runnable {

    /**
     * Get configuration from Admin GUI
     */

    public ArrayList<Stream> receiveConfig() {
        String url = "http://localhost:8080/start";
        RestTemplate restTemplate = new RestTemplate();
        String result = restTemplate.getForObject(url, String.class);
        JsonParser springParser = JsonParserFactory.getJsonParser();
        Map<String, Object> map = springParser.parseMap(result);
        ArrayList<Object> values = new ArrayList<>(map.values());

        String streamID = (String) values.get(0);
        Long delay = (Long) values.get(1);
        ArrayList<String> generators = (ArrayList<String>) values.get(2);
        ArrayList<String> verifiers = (ArrayList<String>) values.get(3);
        PayloadType payloadType = PayloadType.valueOf((String) values.get(4));
        long numberOfPackets = (Long) values.get(5);
        long bcFramesNum = (Long) values.get(6);
        int payloadLength = (Integer) values.get(7);
        int seed = (Integer) values.get(8);
        long interFrameGap = (Long) values.get(9);
        long lifeTime = (Long) values.get(10);
        TransportProtocol transportProtocol = TransportProtocol.valueOf((String) values.get(11));
        FlowType flowType = FlowType.valueOf((String) values.get(12));
        boolean checkContent = (Boolean) values.get(13);

        ArrayList<Stream> streams = new ArrayList<>();
        streams.add(new Stream(streamID, delay, generators, verifiers, payloadType,
                numberOfPackets, payloadLength, seed, bcFramesNum, interFrameGap,
                lifeTime, transportProtocol, flowType, checkContent));

        return streams;
    }

    public int receiveStreamToBeStopped() {
        String url = "http://localhost:8080/stop";
        RestTemplate restTemplate = new RestTemplate();
        String result = restTemplate.getForObject(url, String.class);
        JsonParser springParser = JsonParserFactory.getJsonParser();
        Map<String, Object> map = springParser.parseMap(result);
        ArrayList<Object> values = new ArrayList<>(map.values());
        return (Integer) values.get(0);
    }

    public static void main(String[] args) {
        Communicator communicator = new Communicator();
        communicator.receiveConfig();
    }

    @Override
    public void run() {
//        receiveConfig();
        Object obj = new Object();
    }
}
