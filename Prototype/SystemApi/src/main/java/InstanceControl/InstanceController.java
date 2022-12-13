package InstanceControl;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Objects;

/**
 * This class initializes and manages the generator and verifier instances
 */
public class InstanceController
{
    private final String configDir = ConfigurationManager.configDir;
    private String myMacAddress;
    public InstanceController(ArrayList<Stream> streams)
    {
        getExecutables();
        getMyMacAddress();

        startGenerators(streams);
        startVerifiers(streams);
    }

    //Start generators
    private void startGenerators(ArrayList<Stream> streams)
    {
        int genID = 0;
        for (Stream stream: streams)
        {
            for(String sender: stream.senders)
            {
                if(Objects.equals(sender, myMacAddress))
                {
                    String command = "../Executables/Generator ";
                    command += genID++;
                    command += " ";
                    command += configDir;
                    executeCommand(command);
                }
            }
        }
    }
    //Start Verifiers
    private void startVerifiers(ArrayList<Stream> streams)
    {
        int verID = 0;
        for (Stream stream: streams)
        {
            for(String receiver: stream.receivers)
            {
                if(Objects.equals(receiver, myMacAddress))
                {
                    String command = "../Executables/verifier ";
                    command += verID++;
                    executeCommand(command);
                }
            }
        }
    }

    private void executeCommand(String command)
    {
        try
        {
            ProcessBuilder processBuilder = new ProcessBuilder();
            processBuilder.command("bash", command);

            Process process = processBuilder.start();

            int exitVal = process.waitFor();
            if (exitVal != 0)
            {
                throw new Exception("Could not execute command: "+ command);
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    private void getExecutables()
    {
        executeCommand("../Executables/GetExecutables.sh");
    }

    private void getMyMacAddress()
    {
        //TODO
        myMacAddress = "";
    }
}
