package com.ejam.systemapi;

import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

@Component
public class GlobalVariables {
    public String ADMIN_ADDRESS = "192.168.1.3";
    public int ADMIN_PORT = 8080;
    public String GATEWAY_INTERFACE = "eno1";
    public String ADMIN_CLIENT_INTERFACE = "eno1";

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
