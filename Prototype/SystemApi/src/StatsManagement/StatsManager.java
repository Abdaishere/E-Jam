package StatsManagement;

import InstanceControl.UTILs;

import java.io.*;
import java.net.Inet4Address;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Set;

import static java.lang.Thread.sleep;

/**
 * @author Khaled Waleed
 * This class is responsible for recieving stats objects from generators and verfiers,
 * aggregate them then sends the result to the admin client through Kafka
 */
public class StatsManager implements Runnable
{
    private Inet4Address kafkaServerAddress;
    private static StatsManager instance = null;
    private float sendFrequency = 1.0f;
    private ArrayList<GeneratorStatsContainer> generatorStatsContainers;
    private ArrayList<VerifierStatsContainer> verifierStatsContainers;

    private Thread genStatsThread;
    private Thread verStatsThread;

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

        ArrayList<BufferedReader> readers = new ArrayList<>();
        Set<String> dirs = UTILs.listFiles(parentFolder);
        ArrayList<String> data = new ArrayList<>();
        for (String dir : dirs)
        {
            try
            {
                readers.add(new BufferedReader(new InputStreamReader(new FileInputStream(dir))));
            }
            catch (FileNotFoundException e)
            {
                throw new RuntimeException(e);
            }
        }
        genStatsThread = new Thread(new Runnable()
        {
            public void run()
            {
                try
                {
                    for (BufferedReader reader : readers)
                    {
                        String line = reader.readLine();
                        data.add(line);
                        reader.close();
                    }
                } catch (IOException e)
                {
                    throw new RuntimeException(e);
                }
                for(String s: data)
                    verifierStatsContainers.add(new VerifierStatsContainer(s));

            }
        });
        genStatsThread.start();
    }

    private void fillVerStats()
    {
        verifierStatsContainers.clear();


        //Open pipes that start with sver_*
        String parentFolder = "../Executables/verStatus/";

        ArrayList<BufferedReader> readers = new ArrayList<>();
        Set<String> dirs = UTILs.listFiles(parentFolder);
        ArrayList<String> data = new ArrayList<>();
        for (String dir : dirs)
        {
            try
            {
                readers.add(new BufferedReader(new InputStreamReader(new FileInputStream(dir))));
            }
            catch (FileNotFoundException e)
            {
                throw new RuntimeException(e);
            }
        }
        verStatsThread = new Thread(new Runnable()
        {
            public void run()
            {
                try
                {
                    for (BufferedReader reader : readers)
                    {
                        String line = reader.readLine();
                        data.add(line);
                        reader.close();
                    }
                } catch (IOException e)
                {
                    throw new RuntimeException(e);
                }

                for(String s: data)
                    verifierStatsContainers.add(new VerifierStatsContainer(s));
            }
        });
        verStatsThread.start();
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

    /**
     *
     */
    @Override
    public void run()
    {
        try
        {
            while (true)
            {
                fillGenStats();
                fillVerStats();

                try
                {
                    genStatsThread.join();
                    verStatsThread.join();
                } catch (InterruptedException e)
                {
                    throw new RuntimeException(e);
                }
                sendStatistics();
                sleep((long) sendFrequency);
            }
        } catch (RuntimeException | InterruptedException e)
        {
            run();
        }
    }
}
