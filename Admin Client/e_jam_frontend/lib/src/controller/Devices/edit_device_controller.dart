import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:flutter/material.dart';

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
