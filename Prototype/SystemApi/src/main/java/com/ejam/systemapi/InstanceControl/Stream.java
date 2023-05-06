package com.ejam.systemapi.InstanceControl;

import java.util.ArrayList;

enum PayloadType {FIRST, SECOND, RANDOM}
enum TransportProtocol {TCP, UDP}
enum FlowType {BACK_TO_BACK, BURSTY}


//steam information 
public class Stream
{
    String streamID;                //A 3 alphanumeric charaters defining a stream
    Long delay;                     //Delay in ms
    ArrayList<String> generators;      //senders mac addresses
    ArrayList<String> verifiers;    //receivers mac addresses
    PayloadType payloadType;        //The type of the payload
    long numberOfPackets;           //Number of packets flowing in the stream before it ends
    long broadcastFrames;           //after x regular frame, send a broadcast frame
    int payloadLength, seed;        //Payload length, and seed to use in RNGs
    long interFrameGap;             //Time to wait between each packet generation in the stream in ms
    long timeToLive;                  //Time to live before ending execution in ms
    TransportProtocol transportProtocol;  //The protocol used in the transport layer
    FlowType flowType;                  //The production pattern that the packets uses

    long burstLen;				    //Number of packets in a burst
    long burstDelay;				//Delay between bursts in milliseconds
    boolean checkContent;                  //Whether to check content or not




    public Stream()
    {
        generators = new ArrayList<>();
        verifiers = new ArrayList<>();
    }

    public Stream(String streamID, long delay, ArrayList<String> generators, ArrayList<String> verifiers,
                  PayloadType payloadType, long numberOfPackets, int payloadLength, int seed, long bcFramesNum,
                  long interFrameGap, long lifeTime, TransportProtocol transportProtocol,
                  FlowType flowType, long burstLen, long burstDelay, boolean checkContent) {
        this.streamID = streamID;
        this.delay = delay;
        this.generators = generators;
        this.verifiers = verifiers;
        this.payloadType = payloadType;
        this.numberOfPackets = numberOfPackets;
        this.payloadLength = payloadLength;
        this.seed = seed;
        this.broadcastFrames = bcFramesNum;
        this.interFrameGap = interFrameGap;
        this.timeToLive = lifeTime;
        this.transportProtocol = transportProtocol;
        this.flowType = flowType;
        this.burstLen = burstLen;
        this.burstDelay = burstDelay;
        this.checkContent = checkContent;
    }
}
