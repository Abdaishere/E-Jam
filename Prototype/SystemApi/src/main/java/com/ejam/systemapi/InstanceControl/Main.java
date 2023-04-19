package com.ejam.systemapi.InstanceControl;

import com.ejam.systemapi.NetworkUtilities.BroadcastUtil;
import com.ejam.systemapi.stats.StatsManager;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Main
{
    @Value("${admin.address}")
    private String ADMIN_IP;

    @GetMapping("/admin_address")
    public String getADMIN_IP()
    {
        return ADMIN_IP;
    }

    public static void main(String[] args)
    {
//        System.out.println(UTILs.getMyMacAddress());
//        BroadcastUtil.broadcastAlive(5);
//
//        InstanceControlFacade instanceControlFacade = new InstanceControlFacade();
////        instanceControlFacade.executeComponents();
//        StatsManager statsManager = StatsManager.getInstance(/* add ip here*/);
//        statsManager.setSendFrequency(1.0f);
//        statsManager.run();
    }
}
