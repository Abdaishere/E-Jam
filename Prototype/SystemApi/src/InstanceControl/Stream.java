package InstanceControl;

import java.util.ArrayList;

enum PayloadType {FIRST, SECOND, RANDOM}

//steam information 
public class Stream
{
    ArrayList<String> senders; //senders mac addresses
    ArrayList<String> receivers; //receivers mac addresses
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
