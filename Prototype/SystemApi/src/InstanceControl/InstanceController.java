package InstanceControl;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
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

        int genNum = startGenerators(streams);
        int verNum = startVerifiers(streams);
        startGateway(genNum, verNum);
    }

    //Start generators
    private int startGenerators(ArrayList<Stream> streams)
    {
        int genID = 0;
        for (Stream stream: streams)
        {
            for(String sender: stream.senders)
            {
                if(Objects.equals(sender, myMacAddress))
                {
                    String command = "../Executables/Generator";
                    String path = configDir + "/config_" + stream.streamID + ".txt";
                    String []args = {Integer.toString(genID++), path };
                    executeCommand(command, args);
                }
            }
        }
        return genID;
    }

    //Start Verifiers
    private int startVerifiers(ArrayList<Stream> streams)
    {
        int verID = 0;
        for (Stream stream: streams)
        {
            for(String receiver: stream.receivers)
            {
                if(Objects.equals(receiver, myMacAddress))
                {
                    String command = "../Executables/verifier";
                    String []args = {Integer.toString(verID++)};
                    executeCommand(command, args);
                }
            }
        }
        return verID;
    }

    private void startGateway(int numGen, int numVer)
    {
        String command = "../Executables/Gateway";
        String[] genArgs = {"0", Integer.toString(numGen)};
        executeCommand(command, genArgs);

        command = "../Executables/Gateway";
        String[] verArgs = {"1 ", Integer.toString(numVer)};
        executeCommand(command, verArgs);
    }

    private void executeCommand(String command, String... args)
    {
        try
        {
            ProcessBuilder processBuilder = new ProcessBuilder();
            switch (args.length)
            {
                case 0:
                    processBuilder.command(command);
                    break;
                case 1:
                    processBuilder.command( command, args[0]);
                    break;
                case 2:
                    processBuilder.command( command, args[0], args[1]);
                    break;
                case 3:
                    processBuilder.command( command, args[0], args[1], args[2]);
                    break;
            }

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
        String args[] = {};
        executeCommand("../Executables/GetExecutables.sh", args);
    }

    private void getMyMacAddress()
    {
        byte[] mac;
        try {
            Enumeration<NetworkInterface> networkInterfaces = NetworkInterface.getNetworkInterfaces();
            while(networkInterfaces.hasMoreElements())
            {
                NetworkInterface network = networkInterfaces.nextElement();
                mac = network.getHardwareAddress();
                if(mac == null)
                {
                    throw new Exception("Mac is null");
                }
                else
                {
                    StringBuilder sb = new StringBuilder();
                    for (int i = 0; i < mac.length; i++)
                    {
                        sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));
                    }
                    String mac12 = sb.toString().replaceAll("-","");
                    myMacAddress = mac12;
                    return;
                }
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        myMacAddress = "AAAAAAAAAAAA";
    }
}
