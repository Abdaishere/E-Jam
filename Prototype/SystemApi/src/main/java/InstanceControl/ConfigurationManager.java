package InstanceControl;

import java.util.ArrayList;

/**
 * This class stores and manages the configuration for this certain device
 */
public class ConfigurationManager
{
    public static final String configDir = "/home/EJam/config";


    public ConfigurationManager(ArrayList<Stream> config)
    {
        writeConfigurationToFiles(config);
    }

    //Write Configuration To Files
    private void writeConfigurationToFiles(ArrayList<Stream> config)
    {
        //call writeStreamToFile for all streams
        for(Stream stream: config)
            writeStreamToFile(stream);
    }

    //
    private void writeStreamToFile(Stream stream)
    {
        //TODO
    }
}
