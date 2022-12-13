package InstanceControl;

import java.util.ArrayList;

enum PayloadType {FIRST, SECOND, RANDOM}


public class Stream
{
    ArrayList<String> senders;
    ArrayList<String> receivers;
    PayloadType payloadType;
    long numberOfPackets;
    long lifeTime;
    int payloadLength, seed;
    int flowType;
    long SendingRate;
    String streamID;

    public Stream()
    {
        senders = new ArrayList<>();
        receivers = new ArrayList<>();
    }

}
