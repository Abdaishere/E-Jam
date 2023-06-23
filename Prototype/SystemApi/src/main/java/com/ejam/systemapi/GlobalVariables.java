package com.ejam.systemapi;

import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

@Component
public class GlobalVariables {
    public String ADMIN_ADDRESS = "192.168.1.78";
    public int ADMIN_PORT = 8084;
    public String GATEWAY_INTERFACE;
    public String ADMIN_CLIENT_INTERFACE;

    public GlobalVariables() {
        readInterfaces();
    }

    private void readInterfaces() {
        String fileName = "/etc/EJam/interfaces.txt";
        try (BufferedReader br = new BufferedReader(new FileReader(fileName))) {

            GATEWAY_INTERFACE = br.readLine();
            ADMIN_CLIENT_INTERFACE = br.readLine();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
