package InstanceControl;

import java.util.ArrayList;

enum PayloadType {FIRST, SECOND, RANDOM}
enum TransportProtocol {TCP, UDP}
enum FlowType {BACK_TO_BACK, BURSTY}


//steam information 
public class Stream
{
    String streamID;                //A 3 alphanumeric charaters defining a stream
    ArrayList<String> senders;      //senders mac addresses
    ArrayList<String> receivers;    //receivers mac addresses
    PayloadType payloadType;        //The type of the payload
    long numberOfPackets;           //Number of packets flowing in the stream before it ends
    long bcFramesNum;               //after x regular frame, send a broadcast frame
    int payloadLength, seed;        //Payload length, and seed to use in RNGs
    long interFrameGap;             //Time to wait between each packet generation in the stream in ms
    long lifeTime;                  //Time to live before ending execution in ms
    TransportProtocol transportProtocol;  //The protocol used in the transport layer
    FlowType flowType;              //The production pattern that the packets uses
    long burstLen;				    //Number of packets in a burst
    long burstDelay;				//Delay between bursts in milliseconds
    boolean checkContent;                  //Whether to check content or not



    public Stream()
    {
        senders = new ArrayList<>();
        receivers = new ArrayList<>();
    }

}
