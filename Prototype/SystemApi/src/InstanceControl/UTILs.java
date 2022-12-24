package InstanceControl;

import java.io.*;
import java.util.concurrent.TimeUnit;

public class UTILs {
    public String username;
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

    UTILs()
    {
        username = getUserString();
    }
}
