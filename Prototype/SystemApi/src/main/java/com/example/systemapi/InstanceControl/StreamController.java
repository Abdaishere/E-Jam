package com.example.systemapi.InstanceControl;

import java.util.HashMap;

public class StreamController {
    private static HashMap<String, InstanceController> runningStreams;

    public StreamController() {
        runningStreams = new HashMap<>();
    }

    public static void addStream(InstanceController instance) {
        runningStreams.put(instance.streams.get(0).streamID, instance);
    }

    public static void removeStream(String streamID) {
        runningStreams.remove(streamID);
    }

    public static InstanceController getStreamById(String streamID) {
        return runningStreams.get(streamID);
    }

    public static boolean containsStream(String streamID) {
        return runningStreams.containsKey(streamID);
    }
}
