package InstanceControl;

import NetworkUtilities.BroadcastUtil;

public class Main
{
    public static void main(String[] args)
    {
        BroadcastUtil.broadcastAlive(5);

        InstanceControlFacade instanceControlFacade = new InstanceControlFacade();
        instanceControlFacade.executeComponents();
    }
}
