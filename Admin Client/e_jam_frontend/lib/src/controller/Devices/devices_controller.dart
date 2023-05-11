import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/services/devices_services.dart';
import 'package:flutter/material.dart';

class DevicesController extends ChangeNotifier {
  static List<Device>? devices;
  static bool isLoading = true;
  static bool isPinging = false;
  static DevicesServices devicesServices = DevicesServices();

  get getDevices => devices;
  get getIsLoading => isLoading;
  get getIsPinging => isPinging;
  get getDevicesServices => devicesServices;

  Future loadAllDevices() async {
    isLoading = true;
    return await devicesServices.getDevices().then((value) {
      devices = value;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<Device?> loadDeviceDetails(String mac) async {
    isLoading = true;
    return devicesServices.getDevice(mac).then((value) {
      isLoading = false;
      return value;
    });
  }

  Future<int> addNewDevice(Device device) async {
    isLoading = true;
    return devicesServices.createDevice(device).then((value) {
      isLoading = false;
      return value;
    });
  }

  Future<bool> pingDevice(String deviceMac) {
    isPinging = true;
    return devicesServices.pingDevice(deviceMac).then((value) {
      loadAllDevices();
      isPinging = false;
      return value;
    });
  }

  Future<bool> pingNewDevice(Device device) {
    isPinging = true;
    return devicesServices.checkNewDevice(device).then((value) {
      isPinging = false;
      return value;
    });
  }

  Future<bool?> pingAllDevices() {
    isPinging = true;
    return devicesServices.pingAllDevices().then((value) {
      isPinging = false;
      return value;
    });
  }

  Future<bool?> updateDevice(Device device) async {
    isLoading = true;
    return devicesServices.updateDevice(device).then((value) {
      isLoading = false;
      return value;
    });
  }

  Future<bool> deleteDevice(String deviceMac) async {
    isLoading = true;
    return devicesServices.deleteDevice(deviceMac).then((value) {
      isLoading = false;
      return value;
    });
  }
}
