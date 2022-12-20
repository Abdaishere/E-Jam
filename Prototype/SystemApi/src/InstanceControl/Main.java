package InstanceControl;

import InstanceControl.InstanceControlFacade;

import java.io.IOException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.Enumeration;
import InstanceControl.UTILs;
public class Main
{
    public static void main(String[] args)
    {
        UTILs utils;
        InstanceControlFacade instanceControlFacade = new InstanceControlFacade();
        instanceControlFacade.executeComponents();
    }
}
