package com.ejam.systemapi.NetworkUtilities;

import java.io.IOException;
import java.net.*;

/**
 * This class is responsible for providing tools related to the udp protocol
 * such as sending message and receiving
 *
 * @author Khaled
 * @since 01/02/2023
 */
public class UdpUtil
{
    private static DatagramSocket socket = null;

    /**
     * This utility function sends a specific message to a specific address using UDP
     * @param message contains the message to send
     * @param addressRaw the destination address as a string
     * @return success status
     */
    public static boolean sendUpdMessage(String message, String addressRaw)
    {
        //Handle wrong parameters
        if(message==null || message.length()<1)
            message = "test";
        if(addressRaw==null)
            addressRaw = "255.255.255.255";

        try
        {
            InetAddress address = InetAddress.getByName(addressRaw);
            int port = 4445;

            //open socket
            socket = new DatagramSocket();
            socket.setBroadcast(true);

            //prepare buffer
            byte[] buffer = message.getBytes();

            //prepare and send packet
            DatagramPacket packet
                    = new DatagramPacket(buffer, buffer.length, address, port);
            socket.send(packet);
            System.out.println("Debug: sent UDP packet \""+message+"\"");
        }
        catch (UnknownHostException e)
        {
            System.out.println("Error: cannot resolve address "+ addressRaw);
            return false;
        }
        catch (SocketException e)
        {
            System.out.println("Error: Could not open datagram socket");
            return false;
        }
        catch (IOException e)
        {
            System.out.println("Error: Failed to send datagram packet");
        }
        finally
        {
            socket.close();
            socket = null;
        }
        return true;
    }
}
