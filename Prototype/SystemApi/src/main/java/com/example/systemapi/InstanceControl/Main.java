package com.example.systemapi.InstanceControl;

import com.example.systemapi.NetworkUtilities.BroadcastUtil;
import com.example.systemapi.stats.StatsManager;

public class Main
{
    public static void main(String[] args)
    {
        BroadcastUtil.broadcastAlive(5);

        InstanceControlFacade instanceControlFacade = new InstanceControlFacade();
//        instanceControlFacade.executeComponents();
        StatsManager statsManager = StatsManager.getInstance(/* add ip here*/);
        statsManager.setSendFrequency(1.0f);
        statsManager.run();
    }
}
