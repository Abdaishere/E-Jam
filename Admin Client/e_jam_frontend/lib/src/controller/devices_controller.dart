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

  static Future<Device?> loadDeviceDetails(String mac) async {
    isLoading = true;
    return devicesServices.getDevice(mac).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<int> createNewDevice(Device device) async {
    isLoading = true;
    return devicesServices.createDevice(device).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> pingDevice(String deviceMac) {
    isLoading = true;
    return devicesServices.pingDevice(deviceMac).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> pingNewDevice(Device device) {
    isLoading = true;
    return devicesServices.checkNewDevice(device).then((value) {
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

  static Future<bool?> updateDevice(Device device) async {
    isLoading = true;
    return devicesServices.updateDevice(device).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> deleteDevice(String deviceMac) async {
    isLoading = true;
    return devicesServices.deleteDevice(deviceMac).then((value) {
      isLoading = false;
      return value;
    });
  }
}
