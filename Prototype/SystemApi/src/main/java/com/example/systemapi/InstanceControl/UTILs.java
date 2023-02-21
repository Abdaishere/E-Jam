package com.example.systemapi.InstanceControl;

import java.io.*;
import java.util.concurrent.TimeUnit;

public class UTILs {
    public String username;
    //get username from cmd
    public static String getUserString()
    {
        String name = "";
        try
        {
            String command = "whoami";
            ProcessBuilder processBuilder = new ProcessBuilder();
            processBuilder.command(command);

            Process process = processBuilder.start();

            InputStream inputStream = process.getInputStream();
            name = "";
            try(BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream))) {
                String line;
                while((line = bufferedReader.readLine()) != null) {
                    name = line;
                }

            }
            process.destroyForcibly();
            if(name.equals("root"))
                name = "mohamed";
            return name;
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

//    public String convertToMac6(String mac12)
//    {
//        String mac6 = "AAAAAA";
//        for (int i = 0; i < 12; i+=2)
//        {
//            char c = (char)(((int)mac12.charAt(i) - (int)'0') + (((int)mac12.charAt(i+1) - (int)'0') << 4));
//            // bug: last substring was not taken correctly, the line below is correct
//            mac6 = mac6.substring(0,i/2)+String.valueOf(c)+mac6.substring(i/2 + 1);
//        }
//        return mac6;
//    }

    UTILs()
    {
        username = getUserString();
    }
}
