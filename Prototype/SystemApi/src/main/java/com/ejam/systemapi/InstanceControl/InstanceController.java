package com.ejam.systemapi.InstanceControl;

import com.ejam.systemapi.GlobalVariables;

import java.io.*;
import java.net.URISyntaxException;
import java.util.*;

/**
 * This class initializes and manages the generator and verifier instances
 */
public class InstanceController implements Runnable {
    private final String configDir = ConfigurationManager.configDir;
    private final String myMacAddress;
    InputStream genStream, gatewayStream, verStream;
    ArrayList<Long> pids = new ArrayList<>();
    Stream stream;
    GlobalVariables globalVariables = new GlobalVariables();

    public InstanceController(Stream stream) {
        myMacAddress = UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE);
        this.stream = stream;
    }

    public void startStreams() {
//        getExecutables();
        int genNum = startGenerators(stream); //start executable generators instances
        int verNum = startVerifiers(stream); //start executable verifiers instances
        startGateway(genNum, verNum); //start the gateway
    }

    public void killStreams() {
        //kill the current running executables
        for (Long pid : pids) {
            String[] args = {"-9", Long.toString(pid)};
            executeCommand("kill", true, args);
        }
    }

    //reading the console outputs of the executables,
    //for debugging
    private void debugStreams() {

        try {
            String s = null;
            if (gatewayStream != null) {
                BufferedReader gatewayInput = new BufferedReader(new InputStreamReader(gatewayStream));
                while (gatewayInput.ready() && (s = gatewayInput.readLine()) != null) {
                    System.out.println(s);
                }
            } else throw new Exception("Gateway is null");
            if (genStream != null) {
                BufferedReader genInput = new BufferedReader(new InputStreamReader(genStream));
                while (genInput.ready() && (s = genInput.readLine()) != null) {
                    System.out.println(s);
                }
            }
            if (verStream != null) {
                BufferedReader verInput = new BufferedReader(new InputStreamReader(verStream));
                while (verInput.ready() && (s = verInput.readLine()) != null) {
                    System.out.println(s);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //Start generators
    private int startGenerators(Stream stream) {
        int genID = 0;

        for (String sender : stream.generators) {
            System.out.println(sender);
            System.out.println(myMacAddress);
            if (sender.equals(myMacAddress)) {
                String command = "../Executables/Generator";
                String path = configDir + "/config_" + stream.streamID + ".txt";
                String[] args = {Integer.toString(genID++), path};
                executeCommand(command, false, args);
            }
        }
        return genID;
    }

    //Start Verifiers
    private int startVerifiers(Stream stream) {
        int verID = 0;

        for (String receiver : stream.verifiers) {
            if (receiver.equals(myMacAddress)) {
                String command = "../Executables/verifier";
                String[] args = {Integer.toString(verID++)};
                executeCommand(command, false, args);
            }
        }
        return verID;
    }

    private void startGateway(int numGen, int numVer) {
        if (numGen > 0) {
            String command = "sudo";
            String[] genArgs = {"../Executables/Gateway", "0", Integer.toString(numGen)};
            executeCommand(command, false, genArgs);
        }

        if (numVer > 0) {
            String command = "sudo";
            String[] verArgs = {"../Executables/Gateway", "1 ", Integer.toString(numVer)};
            executeCommand(command, false, verArgs);
        }
    }

    //to execute commands in cmd 
    private void executeCommand(String command, boolean waitFor, String... args) {
        try {
            ProcessBuilder processBuilder = new ProcessBuilder();
            switch (args.length) {
                case 0:
                    processBuilder.command(command);
                    break;
                case 1:
                    processBuilder.command(command, args[0]);
                    break;
                case 2:
                    processBuilder.command(command, args[0], args[1]);
                    break;
                case 3:
                    processBuilder.command(command, args[0], args[1], args[2]);
                    break;
            }

            Process process = processBuilder.start();
            long pid = process.pid();

            System.out.println(command + " " + Arrays.toString(args) + " " + pid);

            if (waitFor) {
                int exitVal = process.waitFor();
                if (exitVal != 0) {
//                    System.out.println("Could not execute command: " + command);
                    throw new Exception("Could not execute command: " + command);
                }
                System.out.println(command + " " + pid + " exited");
            } else {
                System.out.println(command + " " + pid + " is executing without wait");
                pids.add(pid);
                if (command.contains("Generator"))
                    genStream = process.getErrorStream();
                else if (command.contains("Gateway") || command.contains("sudo"))
                    gatewayStream = process.getErrorStream();
                else if (command.contains("verifier"))
                    verStream = process.getErrorStream();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void getExecutables() {
        String[] args = {};
        System.out.println(System.getProperty("user.dir"));
//        System.out.println();
        executeCommand("../Executables/GetExecutables.sh", true, args);
    }


    @Override
    public void run() {
        // wait until the start time of the stream
        try {
            Thread.sleep(stream.delay);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        // start the generators, verifiers and gateway
        startStreams();
        debugStreams(); //TODO
        // add stream to running streams

        // notify Admin-client that the stream is finished
        try {
            Communicator.notify(stream.streamID, "started");
        } catch (URISyntaxException e) {
            throw new RuntimeException(e);
        }

        try {
            Thread.sleep(stream.timeToLive);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        // kill the generators, verifiers and gateway
        try {
            killStreams();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // notify Admin-client that the stream is finished
        try {
            Communicator.notify(stream.streamID, "finished");
        } catch (URISyntaxException e) {
            throw new RuntimeException(e);
        }
    }
}
