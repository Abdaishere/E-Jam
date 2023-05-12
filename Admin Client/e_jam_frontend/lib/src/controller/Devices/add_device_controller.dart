import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:flutter/material.dart';

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

  TextEditingController get getNameController => _nameController;
  TextEditingController get getDescriptionController => _descriptionController;
  TextEditingController get getLocationController => _locationController;
  TextEditingController get getIpController => _ipController;
  TextEditingController get getPortController => _portController;
  TextEditingController get getMacController => _macController;

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
