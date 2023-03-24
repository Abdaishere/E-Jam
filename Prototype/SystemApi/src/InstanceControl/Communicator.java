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

//    public String convertToMac6(String mac12)
//    {
//        String mac6 = "AAAAAA";
//        for (int i = 0; i < 12; i+=2)
//        {
//            char c = (char)(((int)mac12.charAt(i) - (int)'0') + (((int)mac12.charAt(i+1) - (int)'0') << 4));
//            // bug: last substring was not taken correctly, the line below is correct
//            mac6 = mac6.substring(0,i/2)+String.valueOf(c)+mac6.substring(i/2 + 1);
//        }
//        return mac6;
//    }
    public ArrayList<Stream> receiveConfig()
    {
        //Hard coded streams (prototype)
        //stream 1
        Stream stream1 = new Stream();

        //rec 00d861a86fda
        //mac address to send to
        stream1.senders.add("8CB87EB05FEA");
        stream1.receivers.add("00D861A86FDA");
        stream1.payloadType = PayloadType.FIRST;
        stream1.numberOfPackets = 0;
        stream1.payloadLength = 13;
        stream1.seed = 0;
        stream1.flowType = FlowType.BACK_TO_BACK;
        stream1.streamID = "abc";
        stream1.bcFramesNum = 100;
        stream1.interFrameGap = 0;
        stream1.lifeTime = 25000;
        stream1.transportProtocol = TransportProtocol.TCP;
        stream1.checkContent = false;


        ArrayList<Stream> streams  = new ArrayList<>();
        streams.add(stream1);

        return streams;
    }
}
