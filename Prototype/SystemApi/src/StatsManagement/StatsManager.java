package StatsManagement;

import InstanceControl.UTILs;

import java.net.Inet4Address;
import java.net.UnknownHostException;
import java.util.ArrayList;

/**
 * @author Khaled Waleed
 * This class is responsible for recieving stats objects from generators and verfiers,
 * aggregate them then sends the result to the admin client through Kafka
 */
public class StatsManager
{
    private Inet4Address kafkaServerAddress;
    private static StatsManager instance = null;
    private float sendFrequency = 1.0f;
    private ArrayList<GeneratorStatsContainer> generatorStatsContainers;
    private ArrayList<VerifierStatsContainer> verifierStatsContainers;

    /**
     * Get the StatsManager singleton instance
     * @return the StatsManager singleton instance
     */
    public static StatsManager getInstance(Inet4Address ip)
    {
        if(instance == null)
        {
            instance = new StatsManager(ip);
        }
        return instance;
    }

    /**
     * A simpler version of the original ``getInstance(int,int)`` function
     * to get the StatsManager singleton instance with values already set
     * @return the StatsManager singleton instance
     */
    public static StatsManager getInstance()
    {
        if(instance == null)
        {
            try
            {
                instance = new StatsManager((Inet4Address) Inet4Address.getByName("127.0.0.1"));
            }
            catch (UnknownHostException e)
            {
                throw new RuntimeException(e);
            }
        }
        return instance;
    }

    private StatsManager(Inet4Address ip)
    {
        kafkaServerAddress = ip;
    }

    private void fillGenStats()
    {
        generatorStatsContainers.clear();

        //Open pipes that start with sgen_*
        String parentFolder = "../Executables/genStats/";
        for(String fileName: UTILs.listFiles(parentFolder))
        {
            //TODO replace with pipe open
            ArrayList<String> lines = UTILs.getLines(parentFolder + fileName);
            //Convert content to containers
            GeneratorStatsContainer container = new GeneratorStatsContainer(lines.get(0));
            //add to array
            generatorStatsContainers.add(container);
        }
    }

    private void fillVerStats()
    {
        verifierStatsContainers.clear();

        //Open pipes that start with sver_*
        String parentFolder = "../Executables/verStats/";
        for(String fileName: UTILs.listFiles(parentFolder))
        {
            //TODO replace with pipe open
            ArrayList<String> lines = UTILs.getLines(parentFolder + fileName);
            //Convert content to containers
            VerifierStatsContainer container = new VerifierStatsContainer(lines.get(0));
            //add to array
            verifierStatsContainers.add(container);
        }
    }
    public void runTasks()
    {
        fillGenStats();
        fillVerStats();

        sendStatistics();
    }
    /**
     * Set the time interval between re-sending live stats reports
     * @param sendFrequency (new time interval)
     */
    public void setSendFrequency(float sendFrequency)
    {
        this.sendFrequency = sendFrequency;
    }

    /**
     * Send data to the kafka receiver in the admin client once every n seconds where n = "sendFrequency".
     * in other words, this function fires regularly every n seconds .
     * ``sendFrequency`` can be set using the function ``setSendFrequency(float)``
     */
    void sendStatistics()
    {
        //TODO initiate connection with kafka server
        //TODO send stored data
    }

}
