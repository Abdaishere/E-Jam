import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  TextEditingController get getNameController => _nameController;
  TextEditingController get getDescriptionController => _descriptionController;
  TextEditingController get getLocationController => _locationController;
  TextEditingController get getIpController => _ipController;
  TextEditingController get getPortController => _portController;
  String get getMac => _mac;

  Future<Message?> updateDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      return await context
          .read<DevicesController>()
          .updateDevice(createNewDevice());
    }
    return null;
  }

  Device createNewDevice() {
    return Device(
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      ipAddress: _ipController.text,
      port: int.tryParse(_portController.text) ??
          SystemSettings.defaultDevicesPort,
      macAddress: _mac,
    );
  }

  Future<bool?> pingDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      return await context
          .read<DevicesController>()
          .pingNewDevice(createNewDevice());
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
