package InstanceControl;

import StatsManagement.StatsManager;

import java.util.ArrayList;

public class InstanceControlFacade //facade class to hide dependencies and the order of creation 
{
    public void executeComponents()
    {
        Communicator communicator = new Communicator();
        ArrayList<Stream> configuration = communicator.receiveConfig();

        ConfigurationManager configurationManager = new ConfigurationManager(configuration);
        InstanceController instanceController = new InstanceController(configuration);

        StatsManager statsManager = StatsManager.getInstance(/* add ip here*/);
        statsManager.setSendFrequency(1.0f);
        statsManager.run();
    }
}
