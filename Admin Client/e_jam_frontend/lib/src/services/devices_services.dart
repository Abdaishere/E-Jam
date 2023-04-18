import 'dart:convert';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Dialogues/snacks_bar.dart';
import 'package:flutter/material.dart';

class DevicesServices {
  static get backendhostaddress => NetworkController.backendhostaddress;
  static Uri uri = Uri.parse('$backendhostaddress/devices');

  static get client => NetworkController.client;

  Future<List<Device>?> getDevices() async {
    try {
      final response = await client.get(uri);
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
      if (response.statusCode == 200) {
        return Device.fromJson(json.decode(response.body));
      } else if (404 == response.statusCode) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<int> createDevice(Device device) async {
    try {
      final response = await client.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(device.toJson()));
      // if (response.statusCode == 201) {
      //   return true;
      // } else if (409 == response.statusCode) {
      //   return false;
      // } else {
      //   return false;
      // }
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  // ping a device
  Future<bool> pingDevice(String deviceMac) async {
    try {
      final response = await client.get(Uri.parse('$uri/$deviceMac/ping'));
      if (response.statusCode == 200) {
        return true;
      } else if (404 == response.statusCode) {
        return false;
      } else if (500 == response.statusCode) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkNewDevice(Device device) async {
    try {
      final response = await client.post(Uri.parse('$uri/ping'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(device.toJson()));

      if (response.statusCode == 200) {
        return true;
      } else if (500 == response.statusCode) {
        return false;
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
      final response = await client.get(Uri.parse('$uri/ping_all'));
      if (response.statusCode == 200) {
        return true;
      } else if (204 == response.statusCode) {
        return false;
      } else if (500 == response.statusCode) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDevice(Device device) async {
    try {
      final response = await client.put(Uri.parse('$uri/${device.macAddress}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(device.toJson()));
      if (response.statusCode == 200) {
        return true;
      } else if (404 == response.statusCode) {
        return false;
      } else if (400 == response.statusCode) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDevice(String deviceMac) async {
    try {
      final response = await client.delete(Uri.parse('$uri/$deviceMac'));
      if (response.statusCode == 200) {
        return true;
      } else if (404 == response.statusCode) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
