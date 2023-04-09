package com.example.systemapi.NetworkUtilities;

import static java.lang.Thread.sleep;

/**
 * This class is responsible for providing tools to broadcast messages over the network
 * @author Khaled
 * @since 01/02/2023
 */
public class BroadcastUtil
{
    /**
     *
     * @param message contains the message to send
     * @param repetitions How many times will the message will be sent
     * @param waitInterval The interval to wait between each call
     * @return Success status
     */
    public static boolean broadcastMessage(String message, int repetitions, long waitInterval)
    {
        //Handle wrong parameters
        repetitions = Math.max(repetitions, 1);
        waitInterval = Math.max(waitInterval, 1);

        boolean overallStatus = false;
        String broadcastAddressRaw = "255.255.255.255";

        while(repetitions>0)
        {
            boolean result = UdpUtil.sendUpdMessage(message, broadcastAddressRaw);
            overallStatus |= result;    //Make sure at least one packet is sent

            try
            {
                sleep(waitInterval);
            }
            catch (InterruptedException ignored) {}
            repetitions--;
        }
        return overallStatus;
    }

    /**
     * This function intends to broadcast 5 udp packages over time = "totalDuration"
     * @param totalDuration Total broadcast period in seconds ex: 2.5s
     */
    public static void broadcastAlive(double totalDuration)
    {
        int numberOfSteps = 5;
        long stepDuration = (long) (totalDuration * 1000 /numberOfSteps);

        boolean result =  broadcastMessage(null,numberOfSteps,stepDuration);

        if(!result)
            System.out.println("Warning: did not broadcast an \"alive\" message");
    }
}
