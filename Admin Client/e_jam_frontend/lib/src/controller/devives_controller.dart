import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/services/devices_services.dart';
import 'package:flutter/material.dart';

class DevicesController {
  static List<Device>? devices;
  static bool isLoading = true;
  static DevicesServices devicesServices = DevicesServices();

  static Future loadAllDevices(ScaffoldMessengerState scaffoldMessenger) async {
    isLoading = true;
    return devicesServices.getDevices(scaffoldMessenger).then((value) {
      devices = value;
      isLoading = false;
    });
  }

  static Future<Device?> loadDeviceDetails(
      ScaffoldMessengerState scaffoldMessenger, String mac) async {
    isLoading = true;
    return devicesServices.getDevice(scaffoldMessenger, mac).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool?> createNewDevice(
      ScaffoldMessengerState scaffoldMessenger, Device device) async {
    isLoading = true;
    return devicesServices
        .createDevice(scaffoldMessenger, device)
        .then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool?> pingDevice(
      ScaffoldMessengerState scaffoldMessenger, String deviceMac) {
    isLoading = true;
    return devicesServices
        .pingDevice(scaffoldMessenger, deviceMac)
        .then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool?> checkNewDevice(
      ScaffoldMessengerState scaffoldMessenger, Device device) {
    isLoading = true;
    return devicesServices
        .checkNewDevice(scaffoldMessenger, device)
        .then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool?> pingAllDevices(
      ScaffoldMessengerState scaffoldMessenger) {
    isLoading = true;
    return devicesServices.pingAllDevices(scaffoldMessenger).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool?> updateDevice(
      ScaffoldMessengerState scaffoldMessenger, Device device) async {
    isLoading = true;
    return devicesServices
        .updateDevice(scaffoldMessenger, device)
        .then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> deleteDevice(
      ScaffoldMessengerState scaffoldMessenger, String deviceMac) async {
    isLoading = true;
    return devicesServices
        .deleteDevice(scaffoldMessenger, deviceMac)
        .then((value) {
      isLoading = false;
      return value;
    });
  }
}
