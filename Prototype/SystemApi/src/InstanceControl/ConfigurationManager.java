package InstanceControl;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * This class stores and manages the configuration for this certain device
 */
public class ConfigurationManager
{
    public static String configDir;


    public ConfigurationManager(ArrayList<Stream> config)
    {
        setConfigDir();
        writeConfigurationToFiles(config);
    }

    //Write Configuration To Files
    private void writeConfigurationToFiles(ArrayList<Stream> config)
    {
        //call writeStreamToFile for all streams
        for(Stream stream: config)
            writeStreamToFile(stream);
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
            fileWriter.write(Integer.toString(stream.senders.size())+'\n');
            for (String sender: stream.senders)
                fileWriter.write(sender+'\n');

            fileWriter.write(Integer.toString(stream.receivers.size())+'\n');
            for (String receiver: stream.receivers)
                fileWriter.write(receiver+'\n');

            fileWriter.write(Integer.toString(stream.payloadType.ordinal())+'\n');
            fileWriter.write(Long.toString(stream.numberOfPackets)+'\n');
            fileWriter.write(Integer.toString(stream.payloadLength)+'\n');
            fileWriter.write(Integer.toString(stream.seed)+'\n');
            fileWriter.write(Long.toString(stream.bcFramesNum)+'\n');
            fileWriter.write(Long.toString(stream.interFrameGap)+'\n');
            fileWriter.write(Long.toString(stream.lifeTime)+'\n');
            fileWriter.write(stream.transportProtocol.toString()+'\n');
            fileWriter.write(stream.flowType.toString()+'\n');
            int checkContent = stream.checkContent ? 1 : 0;
            fileWriter.write(checkContent+'\n');


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
