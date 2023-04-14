import 'dart:convert';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Dialogues/snacks_bar.dart';
import 'package:flutter/material.dart';

class DevicesServices {
  static get backendhostaddress => NetworkController.backendhostaddress;
  static Uri uri = Uri.parse('$backendhostaddress/devices');

  static get client => NetworkController.client;

  Future<List<Device>?> getDevices(
      ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => Device.fromJson(e))
            .toList();
      } else if (204 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'No Devices Found');
        return [];
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return null;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return null;
    }
  }

  Future<Device?> getDevice(
      ScaffoldMessengerState scaffoldMessenger, String deviceMac) async {
    try {
      final response = await client.get(Uri.parse('$uri/$deviceMac'));
      if (response.statusCode == 200) {
        return Device.fromJson(json.decode(response.body));
      } else if (404 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'No Devices Found');
        return null;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return null;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return null;
    }
  }

  Future<bool> createDevice(
      ScaffoldMessengerState scaffoldMessenger, Device device) async {
    try {
      final response = await client.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(device.toJson()));
      if (response.statusCode == 201) {
        SnacksBar.showSuccessSnack(
            scaffoldMessenger, response.body.toString(), 'Device Added');
        return true;
      } else if (409 == response.statusCode) {
        SnacksBar.showWarningSnack(scaffoldMessenger, response.body.toString(),
            'Device Already Exists');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  // ping a device
  Future<bool> pingDevice(
      ScaffoldMessengerState scaffoldMessenger, String deviceMac) async {
    try {
      final response = await client.get(Uri.parse('$uri/$deviceMac/ping'));
      if (response.statusCode == 200) {
        SnacksBar.showSuccessSnack(
            scaffoldMessenger, response.body.toString(), 'Device Pinged');
        return true;
      } else if (404 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'Device Not Found');
        return false;
      } else if (500 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'Device Offline');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  Future<bool> checkNewDevice(
      ScaffoldMessengerState scaffoldMessenger, Device device) async {
    try {
      final response = await client.post(Uri.parse('$uri/ping'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(device.toJson()));

      if (response.statusCode == 200) {
        SnacksBar.showSuccessSnack(
            scaffoldMessenger, response.body.toString(), 'Device Pinged');
        return true;
      } else if (500 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'Device Offline');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  // ping all devices
  Future<bool> pingAllDevices(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final response = await client.get(Uri.parse('$uri/ping_all'));
      if (response.statusCode == 200) {
        SnacksBar.showSuccessSnack(
            scaffoldMessenger, response.body.toString(), 'All Devices Pinged');
        return true;
      } else if (204 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'No Devices Found');
        return false;
      } else if (500 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'Device Offline');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  Future<bool> updateDevice(
      ScaffoldMessengerState scaffoldMessenger, Device device) async {
    try {
      final response = await client.put(Uri.parse('$uri/${device.macAddress}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(device.toJson()));
      if (response.statusCode == 200) {
        SnacksBar.showSuccessSnack(
            scaffoldMessenger, response.body.toString(), 'Device Updated');
        return true;
      } else if (404 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'Device Not Found');
        return false;
      } else if (400 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'Invalid Data');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  Future<bool> deleteDevice(
      ScaffoldMessengerState scaffoldMessenger, String deviceMac) async {
    try {
      final response = await client.delete(Uri.parse('$uri/$deviceMac'));
      if (response.statusCode == 200) {
        SnacksBar.showSuccessSnack(
            scaffoldMessenger, response.body.toString(), 'Device Deleted');
        return true;
      } else if (404 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'Device Not Found');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }
}
