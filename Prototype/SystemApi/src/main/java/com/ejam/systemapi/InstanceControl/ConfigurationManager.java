package com.ejam.systemapi.InstanceControl;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * This class stores and manages the configuration for this certain device
 */
public class ConfigurationManager
{
    public static String configDir;


    public ConfigurationManager(Stream config)
    {
        setConfigDir();
        writeStreamToFile(config);
    }

    //write steam information to file
    private void writeStreamToFile(Stream stream)
    {
        try
        {
            String fileName = configDir;
            fileName += "/";
            fileName += "config_";
            fileName += stream.streamID;
            fileName += ".txt";

            FileWriter fileWriter = new FileWriter(fileName);

            fileWriter.write(stream.streamID+'\n');
            fileWriter.write(Integer.toString(stream.generators.size())+'\n');
            for (String sender: stream.generators)
                fileWriter.write(sender+'\n');

            fileWriter.write(Integer.toString(stream.verifiers.size())+'\n');
            for (String receiver: stream.verifiers)
                fileWriter.write(receiver+'\n');

            fileWriter.write(Integer.toString(stream.payloadType.ordinal())+'\n');
            fileWriter.write(Long.toString(stream.numberOfPackets)+'\n');
            fileWriter.write(Integer.toString(stream.payloadLength)+'\n');
            fileWriter.write(Integer.toString(stream.seed)+'\n');
            fileWriter.write(Long.toString(stream.broadcastFrames)+'\n');
            fileWriter.write(Long.toString(stream.interFrameGap)+'\n');
            fileWriter.write(Long.toString(stream.timeToLive)+'\n');
            fileWriter.write(Integer.toString(stream.transportProtocol.ordinal())+'\n');
            fileWriter.write(Integer.toString(stream.flowType.ordinal())+'\n');
            fileWriter.write(Long.toString(stream.burstLen)+'\n');
            fileWriter.write(Long.toString(stream.burstDelay)+'\n');
            int checkContent = stream.checkContent ? 1 : 0;
            fileWriter.write(Integer.toString(checkContent) + '\n');

            fileWriter.close();
        }
        catch (IOException e)
        {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
    }

    public static void setConfigDir()
    {
        configDir = "/etc/EJam";
    }
}