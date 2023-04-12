package com.ejam.systemapi.InstanceControl;

import com.ejam.systemapi.NetworkUtilities.BroadcastUtil;
import com.ejam.systemapi.stats.StatsManager;

public class Main
{
    public static void main(String[] args)
    {
        System.out.println(UTILs.getMyMacAddress());
//        BroadcastUtil.broadcastAlive(5);
//
//        InstanceControlFacade instanceControlFacade = new InstanceControlFacade();
////        instanceControlFacade.executeComponents();
//        StatsManager statsManager = StatsManager.getInstance(/* add ip here*/);
//        statsManager.setSendFrequency(1.0f);
//        statsManager.run();
    }
}
