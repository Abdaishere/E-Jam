 # Detection of a new node
 ## Problem definition
 The admin client interface is required to be informed about the devices connected on the netwrok. The admin client should be able to identify how many nodes left or entered the netework and have their data (mac address, interface, etc...)

 ## Related concepts
 ### MAC:
 Media Access Control address, sometimes referred to as a hardware or physical address, is a unique, 12-character alphanumeric attribute that is used to identify individual electronic devices on a network.
 ### ARP:
 ARP stands for Address Resolution protocol. Its main usage is to translate (resolve) IP addresses to mac addresses.
 ### Local ARP table:
 The ARP table is built from the replies to the ARP requests, recorded before a packet is sent on the network. It is viewable by two different methods: from terminal and reading a certain file.

 ## Implementation
 One way to know what devices are connected on the local area network is to query the local ARP table by reading the file dedicated to store it on Linux operating systems. It resides by default in the directory "/proc/net/arp".
 To inform the admin client of a change of the number of nodes, the idea basically is to run a thread performing the querying procedure every predetermined interval and comparing device list to the last query then report in case of change.