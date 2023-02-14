package InstanceControl;

import java.util.ArrayList;

public class InstanceControlFacade //facade class to hide dependencies and the order of creation 
{
    public void executeComponents()
    {
        Communicator communicator = new Communicator();
        ArrayList<Stream> configuration = communicator.receiveConfig();

        ConfigurationManager configurationManager = new ConfigurationManager(configuration);
        InstanceController instanceController = new InstanceController(configuration);
    }
}
