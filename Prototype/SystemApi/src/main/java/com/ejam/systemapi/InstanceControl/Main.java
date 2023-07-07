package com.ejam.systemapi.InstanceControl;

import com.ejam.systemapi.GlobalVariables;

public class Main {
    public static void main(String[] args) {
        GlobalVariables globalVariables = GlobalVariables.getInstance();
        System.out.println(globalVariables.ADMIN_ADDRESS);
        System.out.println(globalVariables.ADMIN_PORT);
//        System.out.println(UTILs.getMyMacAddress());
//        BroadcastUtil.broadcastAlive(5);

//        StatsManager statsManager = StatsManager.getInstance(/* add ip here*/);
//        statsManager.setSendFrequency(1.0f);
//        statsManager.run();
    }
}
