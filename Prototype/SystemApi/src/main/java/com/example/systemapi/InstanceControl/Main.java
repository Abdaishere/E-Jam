package com.example.systemapi.InstanceControl;

import com.example.systemapi.NetworkUtilities.BroadcastUtil;

public class Main
{
    public static void main(String[] args)
    {
        BroadcastUtil.broadcastAlive(5);

        InstanceControlFacade instanceControlFacade = new InstanceControlFacade();
        instanceControlFacade.executeComponents();
    }
}
