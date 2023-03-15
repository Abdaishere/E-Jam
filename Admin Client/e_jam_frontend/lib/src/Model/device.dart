import 'dart:convert';

class Device {
  Device({
    required this.name,
    required this.description,
    required this.location,
    required this.lastUpdated,
    required this.ipAddress,
    required this.port,
    required this.macAddress,
    required this.genProcesses,
    required this.verProcesses,
    required this.status,
  });

  final String name;
  final String description;
  final String location;
  final int lastUpdated;
  final String ipAddress;
  final int port;
  final String macAddress;
  final int genProcesses;
  final int verProcesses;
  final String status;

  factory Device.fromRawJson(String str) => Device.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        name: json["name"],
        description: json["description"],
        location: json["location"],
        lastUpdated: json["lastUpdated"],
        ipAddress: json["ipAddress"],
        port: json["port"],
        macAddress: json["macAddress"],
        genProcesses: json["genProcesses"],
        verProcesses: json["verProcesses"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "location": location,
        "lastUpdated": lastUpdated,
        "ipAddress": ipAddress,
        "port": port,
        "macAddress": macAddress,
        "genProcesses": genProcesses,
        "verProcesses": verProcesses,
        "status": status,
      };
}
