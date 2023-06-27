package com.ejam.systemapi.InstanceControl;

import com.ejam.systemapi.GlobalVariables;
import com.ejam.systemapi.NetworkUtilities.BroadcastUtil;
import com.ejam.systemapi.stats.StatsManager;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

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
