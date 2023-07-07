#!/bin/bash

echo please enter the interface name for the switch network
read interfaceOne

echo ${interfaceOne} > /etc/EJam/interfaces.txt 

echo please enter the interface name for the admin network
read interfaceTwo

echo ${interfaceTwo} >> /etc/EJam/interfaces.txt 