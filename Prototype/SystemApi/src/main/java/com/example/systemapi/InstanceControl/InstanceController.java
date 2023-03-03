package com.example.systemapi.InstanceControl;

import java.io.*;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.rmi.server.ExportException;
import java.util.*;

import static java.lang.Thread.sleep;

/**
 * This class initializes and manages the generator and verifier instances
 */
public class InstanceController implements Runnable
{
    private final String configDir = ConfigurationManager.configDir;
    private final String myMacAddress;
    InputStream genStream, gatewayStream, verStream;
    ArrayList<Long> pids = new ArrayList<>();
    ArrayList<Stream> streams;

    public InstanceController (ArrayList<Stream> streams)
    {
        myMacAddress = UTILs.getMyMacAddress();
        this.streams = streams;
    }

    public void startStreams() {
        getExecutables();
        int genNum = startGenerators(streams); //start executable generators instances
        int verNum = startVerifiers(streams); //start executable verifiers instances
        startGateway(genNum, verNum); //start the gateway
    }

    public void killStreams() {
        //kill the current running executables
        for(Long pid:pids)
        {
            String[] args = {"-9", Long.toString(pid)};
            executeCommand("kill",true , args);
        }
    }

    //reading the console outputs of the executables,
    //for debugging
    private void debugStreams()
    {

        try {
            String s = null;
            if(gatewayStream != null)
            {
                BufferedReader gatewayInput = new BufferedReader(new InputStreamReader(gatewayStream));
                while (gatewayInput.ready() && (s = gatewayInput.readLine()) != null)
                {
                    System.out.println(s);
                }
            }
            else throw new Exception("Gateway is null");
            if(genStream != null)
            {
                BufferedReader genInput = new BufferedReader(new InputStreamReader(genStream));
                while (genInput.ready() && (s = genInput.readLine()) != null)
                {
                    System.out.println(s);
                }
            }
            if(verStream != null)
            {
                BufferedReader verInput = new BufferedReader(new InputStreamReader(verStream));
                while (verInput.ready() && (s = verInput.readLine()) != null)
                {
                    System.out.println(s);
                }
            }

        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    //Start generators
    private int startGenerators(ArrayList<Stream> streams)
    {
        int genID = 0;
        for (Stream stream: streams)
        {
            for(String sender: stream.generators)
            {
                if(Objects.equals(sender, myMacAddress))
                {
                    String command = "../Executables/Generator";
                    String path = configDir + "/config_" + stream.streamID + ".txt";
                    String []args = {Integer.toString(genID++), path };
                    executeCommand(command, false, args);
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
            for(String receiver: stream.verifiers)
            {
                if(Objects.equals(receiver, myMacAddress))
                {
                    String command = "../Executables/verifier";
                    String []args = {Integer.toString(verID++)};
                    executeCommand(command, false, args);
                }
            }
        }
        return verID;
    }

    private void startGateway(int numGen, int numVer)
    {
        if(numGen > 0) {
            String command = "sudo";
            String[] genArgs = {"../Executables/Gateway","0", Integer.toString(numGen)};
            executeCommand(command, false, genArgs);
        }

        if(numVer > 0) {
            String command = "sudo";
            String[] verArgs = {"../Executables/Gateway","1 ", Integer.toString(numVer)};
            executeCommand(command, false, verArgs);
        }
    }

    //to execute commands in cmd 
    private void executeCommand(String command, boolean waitFor, String... args)
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
            long pid = process.pid();

            System.out.println(command + " " + Arrays.toString(args) + " " + pid);

            if(waitFor) {
                int exitVal = process.waitFor();
                if (exitVal != 0) {
                    throw new Exception("Could not execute command: " + command);
                }
                System.out.println(command + " " + pid + " exited");
            }
            else
            {
                System.out.println(command + " " + pid + " is executing without wait");
                pids.add(pid);
                if(command.contains("Generator"))
                    genStream = process.getErrorStream();
                else if(command.contains("Gateway") || command.contains("sudo"))
                    gatewayStream = process.getErrorStream();
                else if(command.contains("verifier"))
                    verStream = process.getErrorStream();
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
        executeCommand("../Executables/GetExecutables.sh", true, args);
    }


    @Override
    public void run() {
        Stream stream = streams.get(0);

        // wait until the start time of the stream
        try {
            Thread.sleep(stream.delay);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        // start the generators, verifiers and gateway
        startStreams();
//        debugStreams(); //TODO
        // add stream to running streams
        StreamController.addStream(this);

        // notify Admin-client that the stream is finished
        Communicator.started(stream.streamID);

        try {
            Thread.sleep(stream.lifeTime);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        // kill the generators, verifiers and gateway
        killStreams();

        // notify Admin-client that the stream is finished
        Communicator.finished(stream.streamID);
    }
}
