import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:e_jam/src/services/devices_services.dart';

class DevicesController {
  static List<Device>? devices;
  static bool isLoading = true;
  static DevicesServices devicesServices = DevicesServices();

  static Future loadAllDevices() async {
    isLoading = true;
    return devicesServices.getDevices().then((value) {
      devices = value;
      if (devices != null) {
        AddStreamController.pickedGenerators = {
          for (final Device device in devices!)
            device.name:
                AddStreamController.pickedGenerators[device.name] ?? false
        };

        AddStreamController.pickedVerifiers = {
          for (final Device device in devices!)
            device.name:
                AddStreamController.pickedVerifiers[device.name] ?? false
        };
      }
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
