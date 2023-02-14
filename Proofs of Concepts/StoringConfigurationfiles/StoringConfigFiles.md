 # Storing Configuration Files
 ## Problem definition
 After getting the streams' distripution and their details, the system needs to store and deliver instructions to the nodes involved in the test procedure. We need a method to somehow store the in-memory object instaces (represinting the required configureation) on the disk.
 We have exposed to a very simmilar concept while using java Spring boot, but is it applicable in C++ ?

 ## Related concepts
 ### Serialization:
 Serialization is the process of converting a data object (a combination of code and data represented within a region of data storage) into a series of bytes that saves the state of the object in an easily transmittable form. In this serialized form, the data can be delivered to another data storage.

 ### XML:
 XML stands for eXtensible Markup Language. XML is a markup language and file format for storing, transmitting, and reconstructing arbitrary data. It defines a set of rules for encoding documents in a format that is both human-readable and machine-readable.

 ## Result
 QT library has a module which is able to achieve this (QDomdocument). This module is able to generate the Configuration file as in xml format. But QT will not be used in other than the admin client, so to de-serialize another library is used (TinyXML) which is currently suffecent for the program's need.
 Another solution is to use libstudxml which does not require extra libraries on either sides other than libstudxml itself. it is able to serialize and de-serialize objects, but it is somewhat harder to use.
 Since serialization will occure in the admin client's interface which already includes a module using QT framework and the serializing stage comes right after that configuration module, the first solution is more applicable and easier to use.