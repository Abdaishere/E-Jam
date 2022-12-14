package InstanceControl;

import java.io.*;
import java.util.concurrent.TimeUnit;

public class UTILs {
    public String username;
    public static String getUserString() throws InterruptedException, IOException {

        String command = "whoami";
        ProcessBuilder processBuilder = new ProcessBuilder();
        processBuilder.command(command);

        Process process = processBuilder.start();

        InputStream inputStream = process.getInputStream();
        String name = "";
        try(BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream))) {
            String line;
            while((line = bufferedReader.readLine()) != null) {
                name = line;
            }

        }
        process.destroyForcibly();

        return name;
        //another way to issue commands to terminal
//        Process proc = Runtime.getRuntime().exec(command);
//
//        // Read the output
//
//        BufferedReader reader =
//                new BufferedReader(new InputStreamReader(proc.getInputStream()));
//
//        String line = "";
//        String line2 = "";
//        while((line2 = reader.readLine()) != null) {
//            line = line2;
//        }
//
//        proc.waitFor();

    }

    UTILs()
    {
        try {
            username = getUserString();
        } catch (InterruptedException e) {
            System.out.print("couldn't get username");
        } catch (IOException e) {
           System.out.print("couldn't get username");
        }
    }
}
