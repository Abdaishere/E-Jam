import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';
import 'package:e_jam/src/services/devices_services.dart';
import 'package:flutter/material.dart';

class DevicesController extends ChangeNotifier {
  static List<Device>? devices;
  static bool _isLoading = true;
  static bool _isPinging = false;
  static DateTime _lastRefresh = DateTime.now();
  static final DevicesServices _devicesServices = DevicesServices();

  List<Device>? get getDevices => devices;
  bool get getIsLoading => _isLoading;
  bool get getIsPinging => _isPinging;
  DevicesServices get getDevicesServices => _devicesServices;

  Future loadAllDevices(bool forced) async {
    _isLoading = true;

    if (devices != null &&
        !forced &&
        DateTime.now().difference(_lastRefresh).inSeconds < 10) {
      _isLoading = false;
      return;
    }

    _lastRefresh = DateTime.now();
    return _devicesServices.getDevices().then((value) {
      devices = value;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<Device?> loadDeviceDetails(String mac) async {
    _isLoading = true;
    return _devicesServices.getDevice(mac).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<Message> addNewDevice(Device device) async {
    _isLoading = true;
    return _devicesServices.createDevice(device).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> pingDevice(String deviceMac) {
    _isPinging = true;
    return _devicesServices.pingDevice(deviceMac).then((value) {
      loadAllDevices(true);
      _isPinging = false;
      return value;
    });
  }

  Future<bool> pingNewDevice(Device device) {
    _isPinging = true;
    return _devicesServices.checkNewDevice(device).then((value) {
      _isPinging = false;
      return value;
    });
  }

  Future<bool?> pingAllDevices() {
    _isPinging = true;
    return _devicesServices.pingAllDevices().then((value) {
      _isPinging = false;
      return value;
    });
  }

  Future<Message?> updateDevice(Device device) async {
    _isLoading = true;
    return _devicesServices.updateDevice(device).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> deleteDevice(String deviceMac) async {
    _isLoading = true;
    return _devicesServices.deleteDevice(deviceMac).then((value) {
      _isLoading = false;
      return value;
    });
  }
}
