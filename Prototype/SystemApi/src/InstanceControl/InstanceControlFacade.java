package InstanceControl;

import java.util.ArrayList;

public class InstanceControlFacade
{
    public void executeComponents()
    {
        Communicator communicator = new Communicator();
        ArrayList<Stream> configuration = communicator.receiveConfig();

        ConfigurationManager configurationManager = new ConfigurationManager(configuration);
        InstanceController instanceController = new InstanceController(configuration);
    }
}
