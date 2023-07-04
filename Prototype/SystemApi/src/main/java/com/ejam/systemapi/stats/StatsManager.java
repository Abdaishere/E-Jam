package com.ejam.systemapi.stats;

import com.ejam.systemapi.InstanceControl.UTILs;
import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import com.ejam.systemapi.stats.SchemaRegistry.Verifier;

import java.io.*;
import java.net.Inet4Address;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import static java.lang.Thread.sleep;

/**
 * @author Khaled Waleed
 * This class is responsible for recieving stats objects from generators and verfiers,
 * aggregate them then sends the result to the admin client through Kafka
 */
public class StatsManager implements Runnable {
    private static StatsManager instance = null;
    private float sendFrequency = 1000.0f;
    private final ArrayList<Generator> generatorStats = new ArrayList<>();
    private final ArrayList<Verifier> verifierStats = new ArrayList<>();

    private Thread genStatsThread;
    private Thread verStatsThread;

    /**
     * Get the StatsManager singleton instance
     *
     * @return the StatsManager singleton instance
     */
    public static StatsManager getInstance(Inet4Address ip) {
        if (instance == null) {
            instance = new StatsManager(ip);
        }
        return instance;
    }

    /**
     * A simpler version of the original ``getInstance(int,int)`` function
     * to get the StatsManager singleton instance with values already set
     *
     * @return the StatsManager singleton instance
     */
    public static StatsManager getInstance() {
        if (instance == null) {
            try {
                instance = new StatsManager((Inet4Address) Inet4Address.getByName("127.0.0.1"));
            } catch (UnknownHostException e) {
                throw new RuntimeException(e);
            }
        }
        return instance;
    }

    private StatsManager(Inet4Address ip) {
    }

    private void fillGenStats() {
        //Open pipes that start with sgen_*
        String parentFolder = "/etc/EJam/stats/genStats/";

        ArrayList<BufferedReader> readers = new ArrayList<>();
        Set<String> dirs = UTILs.listFiles(parentFolder);
        ArrayList<String> data = new ArrayList<>();
        for (String dir : dirs) {
            System.out.println("Dir = " + (parentFolder + dir));
            try {
                readers.add(new BufferedReader(new InputStreamReader(new FileInputStream(parentFolder + dir))));
            } catch (FileNotFoundException e) {
                throw new RuntimeException(e);
            }
        }

        genStatsThread = new Thread(() -> {
            try {
                for (BufferedReader reader : readers) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        data.add(line);
                    }
                    reader.close();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            for (String s : data) {
                System.out.println(s);
                generatorStats.add(GeneratorProducer.rebuildFromString(s));
            }
        });
        genStatsThread.start();
    }

    private void fillVerStats() {
        //Open pipes that start with sver_*
        String parentFolder = "/etc/EJam/stats/verStats/";

        ArrayList<BufferedReader> readers = new ArrayList<>();
        Set<String> dirs = UTILs.listFiles(parentFolder);
        ArrayList<String> data = new ArrayList<>();
        for (String dir : dirs) {
            try {
                readers.add(new BufferedReader(new InputStreamReader(new FileInputStream(parentFolder + dir))));
            } catch (FileNotFoundException e) {
                throw new RuntimeException(e);
            }
        }
        verStatsThread = new Thread(() -> {
            try {
                for (BufferedReader reader : readers) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        data.add(line);
                    }
                    reader.close();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

            for (String s : data)
                verifierStats.add(VerifierProducer.rebuildFromString(s));
        });
        verStatsThread.start();
    }

    /**
     * Set the time interval between re-sending live stats reports
     *
     * @param sendFrequency (new time interval)
     */
    public void setSendFrequency(float sendFrequency) {
        this.sendFrequency = sendFrequency;
    }

    /**
     * Send data to the kafka receiver in the admin client once every n seconds where n = "sendFrequency".
     * in other words, this function fires regularly every n seconds .
     * ``sendFrequency`` can be set using the function ``setSendFrequency(float)``
     */
    void sendStatistics() throws IOException {


        // aggregate stats
        Map<String, ArrayList<Generator>> aggregatedGenStats = new HashMap<>();
        for (Generator generator : generatorStats) {
            if (aggregatedGenStats.containsKey(generator.getStreamId().toString())) {
                aggregatedGenStats.get(generator.getStreamId().toString()).add(generator);
            } else {
                ArrayList<Generator> generators = new ArrayList<>();
                generators.add(generator);
                aggregatedGenStats.put(generator.getStreamId().toString(), generators);
            }
        }

        Map<String, ArrayList<Verifier>> aggregatedVerStats = new HashMap<>();
        for (Verifier verifier : verifierStats) {
            if (aggregatedVerStats.containsKey(verifier.getStreamId().toString())) {
                aggregatedVerStats.get(verifier.getStreamId().toString()).add(verifier);
            } else {
                ArrayList<Verifier> verifiers = new ArrayList<>();
                verifiers.add(verifier);
                aggregatedVerStats.put(verifier.getStreamId().toString(), verifiers);
            }
        }

        System.out.println("should send now");
        System.out.println("aggregatedGenStats.size() = " + aggregatedGenStats.size());
        // send stats to kafka broker
        for (String key : aggregatedGenStats.keySet()) {
            long aggregatedPacketsSent = 0, aggregatedPacketsErrors = 0;
            for (Generator generator : aggregatedGenStats.get(key)) {
                aggregatedPacketsSent += generator.getPacketsSent();
                aggregatedPacketsErrors += generator.getPacketsErrors();
            }

            GeneratorProducer.produceDataToKafkaBroker(GeneratorProducer
                    .rebuildFromParams((String) aggregatedGenStats.get(key).get(0).getMacAddress(),
                            (String) aggregatedGenStats.get(key).get(0).getStreamId(),
                            aggregatedPacketsSent,
                            aggregatedPacketsErrors));

            System.out.println("Sending... IN GEN");
        }
        System.out.println("Sending.....");
        for (String key : aggregatedVerStats.keySet()) {
            long aggregatedPacketsCorrect = 0, aggregatedPacketsErrors = 0;
            long aggregatedPacketsDropped = 0, aggregatedPacketsOutOfOrder = 0;
            for (Verifier verifier : aggregatedVerStats.get(key)) {
                aggregatedPacketsCorrect += verifier.getPacketsCorrect();
                aggregatedPacketsErrors += verifier.getPacketsErrors();
                aggregatedPacketsDropped += verifier.getPacketsDropped();
                aggregatedPacketsOutOfOrder += verifier.getPacketsOutOfOrder();
            }

            VerifierProducer.produceDataToKafkaBroker(Verifier.newBuilder()
                    .setMacAddress(aggregatedVerStats.get(key).get(0).getMacAddress())
                    .setStreamId(aggregatedVerStats.get(key).get(0).getStreamId())
                    .setPacketsCorrect(aggregatedPacketsCorrect).setPacketsErrors(aggregatedPacketsErrors)
                    .setPacketsDropped(aggregatedPacketsDropped).setPacketsOutOfOrder(aggregatedPacketsOutOfOrder)
                    .build());

        }
        generatorStats.clear();
        verifierStats.clear();
        System.out.println("Sent stats correctly");
    }


    /**
     * This function is called when the thread is started.
     * It runs in an infinite loop and calls the function ``sendStatistics()`` every ``sendFrequency`` seconds.
     * ``sendFrequency`` can be set using the function ``setSendFrequency(float)``
     *
     * @see #setSendFrequency(float)
     * @see #sendStatistics()
     */
    @Override
    public void run() {
        while (true) {
            try {
                System.out.println("collecting stats");
                fillGenStats();
                fillVerStats();

                System.out.println("After filling");
                try {
                    genStatsThread.join();
                    verStatsThread.join();
                } catch (InterruptedException e) {
                    System.out.println("Exception joining threads" + e.getMessage());
                    throw new RuntimeException(e);
                }

                System.out.println("sending size is " + generatorStats.size());
                sendStatistics();
                sleep((long) sendFrequency);
            } catch (RuntimeException e) {
                System.out.println("Exception in stats collector" + e.getMessage());
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

    }
}
