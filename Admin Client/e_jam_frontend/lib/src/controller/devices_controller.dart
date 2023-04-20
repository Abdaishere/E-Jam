import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:e_jam/src/services/devices_services.dart';
import 'package:flutter/material.dart';

class DevicesController {
  static List<Device>? devices;
  static bool isLoading = true;
  static DevicesServices devicesServices = DevicesServices();

  static Future loadAllDevices() async {
    isLoading = true;
    return devicesServices.getDevices().then((value) {
      devices = value;
      AddStreamController.syncDevicesList();
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

  static Future<bool?> pingAllDevices() {
    isLoading = true;
    return devicesServices.pingAllDevices().then((value) {
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

class AddDeviceController {
  static TextEditingController nameController = TextEditingController();
  static TextEditingController descriptionController = TextEditingController();
  static TextEditingController locationController = TextEditingController();
  static TextEditingController ipController = TextEditingController();
  static TextEditingController portController = TextEditingController(
      text: NetworkController.defaultDevicesPort.toString());
  static TextEditingController macController = TextEditingController();

  static Future<int?> createNewDevice(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: nameController.text,
        description: descriptionController.text,
        location: locationController.text,
        ipAddress: ipController.text,
        port: int.tryParse(portController.text) ??
            NetworkController.defaultDevicesPort,
        macAddress: macController.text,
      );

      return await DevicesController.createNewDevice(device);
    }
    return null;
  }

  static Future<bool?> pingDevice(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: nameController.text,
        description: descriptionController.text,
        location: locationController.text,
        ipAddress: ipController.text,
        port: int.tryParse(portController.text) ??
            NetworkController.defaultDevicesPort,
        macAddress: macController.text,
      );

      return await DevicesController.pingNewDevice(device);
    }
    return null;
  }

  static clearAllFields() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    ipController.clear();
    portController.text = NetworkController.defaultDevicesPort.toString();
    macController.clear();
  }
}
