import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
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

class AddDeviceController extends ChangeNotifier {
  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _descriptionController =
      TextEditingController();
  static final TextEditingController _locationController =
      TextEditingController();
  static final TextEditingController _ipController = TextEditingController();
  static final TextEditingController _portController =
      TextEditingController(text: SystemSettings.defaultDevicesPort.toString());
  static final TextEditingController _macController = TextEditingController();

  get getNameController => _nameController;
  get getDescriptionController => _descriptionController;
  get getLocationController => _locationController;
  get getIpController => _ipController;
  get getPortController => _portController;
  get getMacController => _macController;

  Future<Device?> createNewDevice(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        ipAddress: _ipController.text,
        port: int.tryParse(_portController.text) ??
            SystemSettings.defaultDevicesPort,
        macAddress: _macController.text,
      );

      return device;
    }
    return null;
  }

  Future<Device?> pingDevice(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        ipAddress: _ipController.text,
        port: int.tryParse(_portController.text) ??
            SystemSettings.defaultDevicesPort,
        macAddress: _macController.text,
      );

      return device;
    }
    return null;
  }

  clearAllFields() {
    _nameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _ipController.clear();
    _portController.text = SystemSettings.defaultDevicesPort.toString();
    _macController.clear();
  }
}

class EditDeviceController extends ChangeNotifier {
  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _descriptionController =
      TextEditingController();
  static final TextEditingController _locationController =
      TextEditingController();
  static final TextEditingController _ipController = TextEditingController();
  static final TextEditingController _portController =
      TextEditingController(text: SystemSettings.defaultDevicesPort.toString());
  static String _mac = "";

  get getNameController => _nameController;
  get getDescriptionController => _descriptionController;
  get getLocationController => _locationController;
  get getIpController => _ipController;
  get getPortController => _portController;
  get getMac => _mac;

  Future<Device?> updateDevice(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        ipAddress: _ipController.text,
        port: int.tryParse(_portController.text) ??
            SystemSettings.defaultDevicesPort,
        macAddress: _mac,
      );
      return device;
    }
    return null;
  }

  Future<Device?> pingDevice(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        ipAddress: _ipController.text,
        port: int.tryParse(_portController.text) ??
            SystemSettings.defaultDevicesPort,
        macAddress: _mac,
      );

      return device;
    }
    return null;
  }

  clearAllFields() {
    _nameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _ipController.clear();
    _portController.text = SystemSettings.defaultDevicesPort.toString();
    _mac = "";
  }

  updateFields(Device device, String mac) {
    _nameController.text = device.name;
    _descriptionController.text = device.description;
    _locationController.text = device.location;
    _ipController.text = device.ipAddress;
    _portController.text = device.port.toString();
    _mac = mac;
  }
}
