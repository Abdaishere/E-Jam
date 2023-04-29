package com.ejam.systemapi.InstanceControl;

import java.util.HashMap;

public class ProcessController {
    private static HashMap<String, StreamProcess> runningProcesses = new HashMap<>();

    public ProcessController() {
        runningProcesses = new HashMap<>();
    }

    public static void addProcess(StreamProcess process) {
        runningProcesses.put(process.instanceController.stream.streamID, process);
    }

    public static void removeProcess(String streamID) {
        runningProcesses.remove(streamID);
    }

    public static StreamProcess getProcessByStreamId(String streamID) {
        return runningProcesses.get(streamID);
    }

    public static boolean containsProcess(String streamID) {
        return runningProcesses.containsKey(streamID);
    }
}


class StreamProcess {
    public InstanceController instanceController;
    public Thread thread;

    boolean killed = false;
    
    public StreamProcess(InstanceController instanceController, Thread thread) {
        this.instanceController = instanceController;
        this.thread = thread;
    }
}