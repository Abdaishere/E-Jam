package com.ejam.systemapi.InstanceControl;

import java.io.*;
import java.net.NetworkInterface;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class UTILs {
    public String username;

    //get username from cmd
    public static String getUserString() {
        String name;
        try {
            String command = "whoami";
            ProcessBuilder processBuilder = new ProcessBuilder();
            processBuilder.command(command);

            Process process = processBuilder.start();

            InputStream inputStream = process.getInputStream();
            name = "";
            try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream))) {
                String line;
                while ((line = bufferedReader.readLine()) != null) {
                    name = line;
                }

            }
            process.destroyForcibly();
            if (name.equals("root"))
                name = "mohamed";
            return name;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    UTILs() {
        username = getUserString();
    }

    public static Set<String> listFiles(String dir) {
        return Stream.of(Objects.requireNonNull(new File(dir).listFiles()))
                .filter(file -> !file.isDirectory())
                .map(File::getName)
                .collect(Collectors.toSet());
    }

    public static ArrayList<String> getLines(String fileName) {
        ArrayList<String> lines = new ArrayList<>();
        try {
            File file = new File(fileName);
            Scanner scanner = new Scanner(file);
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                if (line.length() > 0) lines.add(line);
            }
            scanner.close();
        } catch (FileNotFoundException e) {
            System.out.println("ERROR: File not found.");
        }
        return lines;
    }

    public static int getStreamIndex(String streamID) {
        String dir = "/etc/EJam/";
        try {
            int index = 0;
//            String command = "ls -tr --time=birth " + dir;
            ProcessBuilder processBuilder = new ProcessBuilder();
            processBuilder.command("ls", "-tr", "--time=birth", dir);

            Process process = processBuilder.start();

            InputStream inputStream = process.getInputStream();
            try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream))) {
                String fileName;
                while ((fileName = bufferedReader.readLine()) != null) {
                    if (fileName.startsWith("config")) {
                        if (fileName.endsWith(streamID))
                            return index;
                        ++index;
                    }
                }

            }
            process.destroyForcibly();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;

    }

    public static String getMyMacAddress(String interfaceName) {
        Map<String, String> interfaceToAddress = new HashMap<>();
        byte[] mac;
        try {
            Enumeration<NetworkInterface> networkInterfaces = NetworkInterface.getNetworkInterfaces();
            while (networkInterfaces.hasMoreElements()) {
                NetworkInterface network = networkInterfaces.nextElement();
                mac = network.getHardwareAddress();
                if (mac == null) {
                    continue;
                }
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < mac.length; i++) {
                    sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));
                }
                String mac12 = sb.toString().replaceAll("-", "");
                interfaceToAddress.put(network.getName(), mac12);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        String macAddress = interfaceToAddress.get(interfaceName);
        try {
            if (macAddress == null) {
                throw new Exception("Mac is null");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return macAddress;
    }

    public static String convertToColonFormat(String macAddress) {
        macAddress = macAddress.trim();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < macAddress.length(); i += 2) {
            sb.append(Character.toLowerCase(macAddress.charAt(i)));
            sb.append(Character.toLowerCase(macAddress.charAt(i + 1)));
            sb.append(":");
        }
        sb.setLength(sb.length() - 1);
        return sb.toString();
    }

    public static String convertToWithoutColonFormat(String macAddress) {
        macAddress = macAddress.trim();
        return macAddress.replaceAll(":", "");
    }
}
