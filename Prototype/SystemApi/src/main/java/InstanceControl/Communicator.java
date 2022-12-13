package InstanceControl;

import java.util.ArrayList;

/**
 * Receive the configuration from the admin gui and pass it to the configuration manager
 */
public class Communicator
{

    /**
     * Get configuration from Admin GUI
     */
    public ArrayList<Stream> receiveConfig()
    {
        //Hard coded streams (prototype)
        //stream 1
        Stream stream1 = new Stream();
        stream1.senders.add("AAAAAA");
        stream1.senders.add("BBBBBB");
        stream1.receivers.add("CCCCCC");
        stream1.receivers.add("DDDDDD");
        stream1.payloadType = PayloadType.FIRST;
        stream1.numberOfPackets = 100;
        stream1.lifeTime = 100;
        stream1.payloadLength = 13;
        stream1.seed = 0;
        stream1.flowType = 0;
        stream1.streamID = "abc";



        //stream 1
        Stream stream2 = new Stream();
        stream2.senders.add("AAAAAA");
        stream2.receivers.add("CCCCCC");
        stream2.payloadType = PayloadType.SECOND;
        stream2.numberOfPackets = 100;
        stream2.lifeTime = 100;
        stream2.payloadLength = 13;
        stream2.seed = 0;
        stream2.flowType = 0;
        stream2.streamID = "XyZ";

        ArrayList<Stream> streams  = new ArrayList<>();
        streams.add(stream1);
        streams.add(stream2);

        return streams;
    }
}
