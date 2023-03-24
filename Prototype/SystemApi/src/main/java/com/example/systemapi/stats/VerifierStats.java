package com.example.systemapi.stats;

public class VerifierStats {
    public String key;
    public long correctlyReceivedPackets;
    public long erroneousPackets;
    public long droppedPackets;
    public long outOfOrderPackets;

    public VerifierStats(String key, long correctlyReceivedPackets, long erroneousPackets, long droppedPackets, long outOfOrderPackets) {
        this.key = key;
        this.correctlyReceivedPackets = correctlyReceivedPackets;
        this.erroneousPackets = erroneousPackets;
        this.droppedPackets = droppedPackets;
        this.outOfOrderPackets = outOfOrderPackets;
    }
}
