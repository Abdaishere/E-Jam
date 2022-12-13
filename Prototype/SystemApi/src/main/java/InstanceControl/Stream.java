package InstanceControl;

import java.util.ArrayList;

enum PayloadType {FIRST, SECOND, RANDOM}


public class Stream
{
    ArrayList<String> senders;
    ArrayList<String> receivers;
    String myMacAddress;
    PayloadType payloadType;
    long numberOfPackets = 100;
    long lifeTime = 100;
    int payloadLength, seed;
    int flowType;
    long SendingRate;
    String streamID;
}
