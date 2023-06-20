import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  Future<Message?> addDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (context.mounted) {
        return context.read<DevicesController>().addNewDevice(
              createNewDevice(),
            );
      }
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
      macAddress: _macController.text,
    );
  }

  Future<bool?> pingDevice(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      return context.read<DevicesController>().pingNewDevice(
            createNewDevice(),
          );
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
