import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:e_jam/src/services/devices_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesController extends ChangeNotifier {
  static List<Device>? devices;
  static bool isLoading = true;
  static DevicesServices devicesServices = DevicesServices();

  Future loadAllDevices(BuildContext context) async {
    isLoading = true;
    return await devicesServices.getDevices().then((value) {
      devices = value;
      context.read<AddStreamController>().syncDevicesList();
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

  Future<int> createNewDevice(Device device) async {
    isLoading = true;
    return devicesServices.createDevice(device).then((value) {
      isLoading = false;
      return value;
    });
  }

  Future<bool> pingDevice(String deviceMac, BuildContext context) {
    isLoading = true;
    return devicesServices.pingDevice(deviceMac).then((value) {
      loadAllDevices(context);
      isLoading = false;
      return value;
    });
  }

  Future<bool> pingNewDevice(Device device) {
    isLoading = true;
    return devicesServices.checkNewDevice(device).then((value) {
      isLoading = false;
      return value;
    });
  }

  Future<bool?> pingAllDevices() {
    isLoading = true;
    return devicesServices.pingAllDevices().then((value) {
      isLoading = false;
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

  Future<int?> createNewDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
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

      return await context.read<DevicesController>().createNewDevice(device);
    }
    return null;
  }

  Future<bool?> pingDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
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

      return await context.read<DevicesController>().pingNewDevice(device);
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

  Future<bool> updateDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
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
      return await context.read<DevicesController>().updateDevice(device) ??
          false;
    }
    return false;
  }

  Future<bool> pingDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
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

      return await context.read<DevicesController>().pingNewDevice(device);
    }
    return false;
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
