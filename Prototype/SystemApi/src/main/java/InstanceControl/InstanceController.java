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
                    command += "/config_";
                    command += stream.streamID + ".txt";

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
                    //TODO convert mac 12 to mac 6
//                    for(byte b: mac)
//                        myMacAddress += (char)b;
                    break;
                }
            }
        }
        catch (Exception e)
        {

            e.printStackTrace();

        }
    }
}
