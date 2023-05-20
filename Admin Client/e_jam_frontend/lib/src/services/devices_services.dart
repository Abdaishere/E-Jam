import 'dart:convert';
import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';

class DevicesServices {
  static Uri uri = Uri.parse('${NetworkController.serverIpAddress}/devices');
  static get client => NetworkController.client;

  Future<List<Device>?> getDevices() async {
    try {
      final response = await client.get(uri).timeout(NetworkController.timeout);

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => Device.fromJson(e))
            .toList();
      } else if (204 == response.statusCode) {
        return [];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Device?> getDevice(String deviceMac) async {
    try {
      final response = await client.get(Uri.parse('$uri/$deviceMac'));

      if (300 > response.statusCode) {
        return Device.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Message?> createDevice(Device device) async {
    try {
      final response = await client
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(device.toJson()))
          .timeout(NetworkController.timeout);

      return Message(message: response.body, responseCode: response.statusCode);
    } catch (e) {
      return null;
    }
  }

  // ping a device
  Future<bool> pingDevice(String deviceMac) async {
    try {
      final response = await client
          .get(Uri.parse('$uri/$deviceMac/ping'))
          .timeout(NetworkController.timeout);

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkNewDevice(Device device) async {
    try {
      final response = await client
          .post(Uri.parse('$uri/ping'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(device.toJson()))
          .timeout(NetworkController.timeout);

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ping all devices
  Future<bool> pingAllDevices() async {
    try {
      final response = await client
          .get(Uri.parse('$uri/ping_all'))
          .timeout(NetworkController.timeout);

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDevice(Device device) async {
    try {
      final response = await client
          .put(Uri.parse('$uri/${device.macAddress}'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(device.toJson()))
          .timeout(NetworkController.timeout);

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDevice(String deviceMac) async {
    try {
      final response = await client
          .delete(Uri.parse('$uri/$deviceMac'))
          .timeout(NetworkController.timeout);

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<VerifierStatisticsInstance>> getVerifierStatisticsInstances(
      String deviceMac) async {
    try {
      final response = await client
          .get(Uri.parse('$uri/$deviceMac/statistics/verifier/earliest'))
          .timeout(NetworkController.timeout);
      if (200 == response.statusCode) {
        return (jsonDecode(response.body) as List).map((e) {
          return VerifierStatisticsInstance.fromJson(e);
        }).toList();
      } else if (204 == response.statusCode) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<GeneratorStatisticsInstance>> getGeneratorStatisticsInstance(
      String deviceMac) async {
    try {
      final response = await client
          .get(Uri.parse('$uri/$deviceMac/statistics/generator/earliest'))
          .timeout(NetworkController.timeout);
      if (200 == response.statusCode) {
        return (jsonDecode(response.body) as List).map((e) {
          print(e);
          return GeneratorStatisticsInstance.fromJson(e);
        }).toList();
      } else if (204 == response.statusCode) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
