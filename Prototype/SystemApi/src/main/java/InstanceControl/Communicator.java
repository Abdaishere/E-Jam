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
    public String convertToMac6(String mac12)
    {
        String mac6 = "AAAAAA";
        for (int i = 0; i < 12; i+=2)
        {
            char c = (char)(((int)mac12.charAt(i) - (int)'0') + (((int)mac12.charAt(i+1) - (int)'0') << 4));
            mac6 = mac6.substring(0,i/2)+String.valueOf(c)+mac6.substring(6);
        }
        return mac6;
    }
    public ArrayList<Stream> receiveConfig()
    {
        //Hard coded streams (prototype)
        //stream 1
        Stream stream1 = new Stream();

        //rec 00d861a86fda
        //mac address to send to
        stream1.senders.add(convertToMac6("8cb87eb05fea"));
        stream1.receivers.add(convertToMac6("00d861a86fda"));
        stream1.payloadType = PayloadType.FIRST;
        stream1.numberOfPackets = 100;
        stream1.lifeTime = 100;
        stream1.payloadLength = 13;
        stream1.seed = 0;
        stream1.flowType = 0;
        stream1.streamID = "abc";


        ArrayList<Stream> streams  = new ArrayList<>();
        streams.add(stream1);

        return streams;
    }
}
