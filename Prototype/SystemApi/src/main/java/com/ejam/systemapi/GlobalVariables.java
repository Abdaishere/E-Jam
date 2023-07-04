package com.ejam.systemapi;

import org.springframework.stereotype.Component;

import java.io.*;

@Component
public class GlobalVariables {
    private static final GlobalVariables instance = new GlobalVariables();
    public String ADMIN_ADDRESS;
    public int ADMIN_PORT;
    public String GATEWAY_INTERFACE;
    public String ADMIN_CLIENT_INTERFACE;
    public final String ADMIN_CONFIG_FILE = "/etc/EJam/admin_config.txt";
    public final String INTERFACES_FILE = "/etc/EJam/interfaces.txt";

    private GlobalVariables() {
        readInterfaces();
    }

    public static GlobalVariables getInstance() {
        return instance;
    }

    private void readInterfaces() {
        try (BufferedReader br = new BufferedReader(new FileReader(INTERFACES_FILE))) {

            GATEWAY_INTERFACE = br.readLine();
            ADMIN_CLIENT_INTERFACE = br.readLine();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void readAdminConfig() {
        try (BufferedReader br = new BufferedReader(new FileReader(ADMIN_CONFIG_FILE))) {

            ADMIN_ADDRESS = br.readLine();
            ADMIN_PORT = Integer.parseInt(br.readLine());

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void writeAdminConfig(String adminAddress, int adminPort) {
        File file = new File(ADMIN_CONFIG_FILE);
        try {
            file.createNewFile();
            FileWriter fileWriter = new FileWriter(file);
            fileWriter.write(adminAddress + "\n");
            fileWriter.write(adminPort + "\n");
            fileWriter.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
