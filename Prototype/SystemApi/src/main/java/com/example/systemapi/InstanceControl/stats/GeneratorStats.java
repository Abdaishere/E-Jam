package com.example.systemapi.InstanceControl.stats;

public class GeneratorStats {
    public String key;
    public long totalPacketsSent;
    public long packetsSentWithErrors;

    public GeneratorStats(String key, long totalPacketsSent, long packetsSentWithErrors) {
        this.key = key;
        this.totalPacketsSent = totalPacketsSent;
        this.packetsSentWithErrors = packetsSentWithErrors;
    }
}
