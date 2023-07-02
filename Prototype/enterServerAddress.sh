#!/bin/bash

echo please enter the ip address of this node
read ip

FIRST_LINE="server.port=8000"
PREFIX="server.address="

echo ${FIRST_LINE} > ./SystemApi/src/main/resources/application.properties
echo ${PREFIX}${ip} >> ./SystemApi/src/main/resources/application.properties 