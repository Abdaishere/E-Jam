import 'dart:convert';

import 'package:flutter/widgets.dart';

@immutable
class Device {
  const Device({
    required this.name,
    required this.description,
    required this.location,
    this.lastUpdated,
    required this.ipAddress,
    required this.port,
    required this.macAddress,
    this.genProcesses,
    this.verProcesses,
    this.status,
  });

  final String name;
  final String description;
  final String location;
  final DateTime? lastUpdated;
  final String ipAddress;
  final int port;
  final String macAddress;
  final int? genProcesses;
  final int? verProcesses;
  final DeviceStatus? status;

  factory Device.fromRawJson(String str) => Device.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        name: json["name"],
        description: json["description"],
        location: json["location"],
        lastUpdated:
            DateTime.fromMillisecondsSinceEpoch(json["lastUpdated"] * 1000)
                .toLocal(),
        ipAddress: json["ipAddress"],
        port: json["port"],
        macAddress: json["macAddress"],
        genProcesses: json["genProcesses"],
        verProcesses: json["verProcesses"],
        status: deviceStatusFromString(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "location": location,
        "lastUpdated": lastUpdated ??
            DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
        "ipAddress": ipAddress,
        "port": port,
        "macAddress": macAddress,
        "genProcesses": genProcesses ?? 0,
        "verProcesses": verProcesses ?? 0,
        "status": deviceStatusToString(status),
      };
}

enum DeviceStatus {
  offline,
  online,
  running,
  idle,
}

DeviceStatus deviceStatusFromString(String status) {
  switch (status) {
    case 'Offline':
      return DeviceStatus.offline;
    case 'Online':
      return DeviceStatus.online;
    case 'Running':
      return DeviceStatus.running;
    case 'Idle':
      return DeviceStatus.idle;
    default:
      return DeviceStatus.offline;
  }
}

String deviceStatusToString(DeviceStatus? status) {
  switch (status) {
    case DeviceStatus.offline:
      return 'Offline';
    case DeviceStatus.online:
      return 'Online';
    case DeviceStatus.running:
      return 'Running';
    case DeviceStatus.idle:
      return 'Idle';
    default:
      return 'Offline';
  }
}
