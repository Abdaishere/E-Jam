package StatsManagement;

import java.net.Inet4Address;
import java.util.ArrayList;

/**
 * @author Khaled Waleed
 * This class is responsible for recieving stats objects from generators and verfiers,
 * aggregate them then sends the result to the admin client through Kafka
 */
public class StatsManager
{
    private static StatsManager instance = null;
    private float sendFrequency = 1.0f;
    private ArrayList<StatsContainer> dataContainers;

    /**
     * Get the StatsManager singleton instance
     * @param numGens Number of generators on host
     * @param numVers Number of Verifiers on host
     * @return the StatsManager singleton instance
     */
    public static StatsManager getInstance(int numGens, int numVers)
    {
        if(instance == null)
        {
            instance = new StatsManager(numGens, numVers);
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
            instance = new StatsManager(0, 0);
        }
        return instance;
    }

    private StatsManager(int numGens, int numVers)
    {
        //TODO create named pipes according to the number of generators and verifiers

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
     * A function used to receive data from processes and store them
     */
    private void receiveData()
    {
        //TODO prepare pipes and read from them
        //TODO store data containers
    }

    /**
     * Send data to the kafka receiver in the admin client once every n seconds where n = "sendFrequency".
     * in other words, this function fires regularly every n seconds .
     * ``sendFrequency`` can be set using the function ``setSendFrequency(float)``
     * @param address denotes the address of the kafka server in the admin client
     */
    void sendStatistics(Inet4Address address)
    {
        //TODO initiate connection with kafka server
        //TODO send stored data
    }

}
