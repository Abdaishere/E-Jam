import 'dart:convert';
import 'dart:io';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/View/Dialogues/snacks_bar.dart';
import 'package:flutter/material.dart';

class StreamServices {
  static get backendhostaddress => NetworkController.backendhostaddress;
  static Uri uri = Uri.parse('$backendhostaddress/streams');

  static get client => NetworkController.client;

  Future<List<StreamEntry>?> getStreams(
      ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final response = await client.get(uri);
      if (200 == response.statusCode) {
        return (json.decode(response.body) as List)
            .map((e) => StreamEntry.fromJson(e))
            .toList();
      } else if (204 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'No Streams Found');
        return [];
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return [];
      }
    } catch (e) {
      e.toString();
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return null;
    }
  }

  Future<StreamEntry?> getStream(String streamId) async {
    try {
      final response = await client.get(Uri.parse('$uri/$streamId'));
      if (200 == response.statusCode) {
        return StreamEntry.fromJson(json.decode(response.body));
      } else if (404 == response.statusCode) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool?> createStream(StreamEntry stream) async {
    try {
      final response = await client.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(stream.toJson()),
      );
      if (201 == response.statusCode) {
        return true;
      } else if (409 == response.statusCode) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool?> updateStream(
      ScaffoldMessengerState scaffoldMessenger, StreamEntry stream) async {
    try {
      final response = await client.put(
        Uri.parse('$uri/${stream.streamId}'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(stream.toJson()),
      );
      if (200 == response.statusCode) {
        SnacksBar.showSuccessSnack(scaffoldMessenger, response.body.toString(),
            'Updated Successfully');

        return true;
      } else if (400 == response.statusCode) {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            'Cannot Update Stream');
        return false;
      } else if (404 == response.statusCode) {
        SnacksBar.showFailureSnack(
            scaffoldMessenger, response.body.toString(), 'Cannot Find Stream');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      e.toString();
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return null;
    }
  }

  Future<bool> deleteStream(
      ScaffoldMessengerState scaffoldMessenger, String streamId) async {
    try {
      final response = await client.delete(Uri.parse('$uri/$streamId'));
      if (200 == response.statusCode) {
        SnacksBar.showSuccessSnack(scaffoldMessenger, response.body.toString(),
            'Deleted Successfully');
        return true;
      } else if (404 == response.statusCode) {
        SnacksBar.showFailureSnack(
            scaffoldMessenger, response.body.toString(), 'Cannot Find Stream');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      e.toString();
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  Future<bool> startStream(String streamId) async {
    try {
      final response = await client.post(Uri.parse('$uri/$streamId/start'));
      if (200 == response.statusCode) {
        return true;
      } else if (409 == response.statusCode) {
        return false;
      } else if (404 == response.statusCode) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // stop a stream by id
  Future<bool> stopStream(String streamId) async {
    try {
      final response = await client.post(Uri.parse('$uri/$streamId/stop'));
      if (200 == response.statusCode) {
        return true;
      } else if (409 == response.statusCode) {
        return false;
      } else if (404 == response.statusCode) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> startAllStreams(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final response = await client.post(Uri.parse('$uri/start_all'));
      if (200 == response.statusCode) {
        SnacksBar.showSuccessSnack(
            scaffoldMessenger, response.body.toString(), 'Queued Successfully');
        return true;
      } else if (204 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'No Streams to Queue');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      e.toString();
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  Future<bool> stopAllStreams(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final response = await client.post(Uri.parse('$uri/stop_all'));
      if (200 == response.statusCode) {
        SnacksBar.showSuccessSnack(scaffoldMessenger, response.body.toString(),
            'Stopped Successfully');

        return true;
      } else if (204 == response.statusCode) {
        SnacksBar.showWarningSnack(
            scaffoldMessenger, response.body.toString(), 'No Streams to Stop');
        return false;
      } else {
        SnacksBar.showFailureSnack(scaffoldMessenger, response.body.toString(),
            response.statusCode.toString());
        return false;
      }
    } catch (e) {
      e.toString();
      SnacksBar.showFailureSnack(scaffoldMessenger,
          'Unable to connect to Server \n ${e.toString()}', 'Server Error');
      return false;
    }
  }

  Future<bool> forceStartStream(String streamId) async {
    try {
      final response =
          await client.post(Uri.parse('$uri/$streamId/force_start'));
      if (200 == response.statusCode) {
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

  Future<bool> forceStopStream(String streamId) async {
    try {
      final response =
          await client.post(Uri.parse('$uri/$streamId/force_stop'));
      if (200 == response.statusCode) {
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

  Future<StreamStatusDetails?> getStreamStatus(String streamId) async {
    try {
      final response = await client.get(Uri.parse('$uri/$streamId/status'));
      if (200 == response.statusCode) {
        return StreamStatusDetails.fromJson(jsonDecode(response.body));
      } else if (404 == response.statusCode) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<StreamStatusDetails>?> getAllStreamStatus() async {
    try {
      final response = await client.get(Uri.parse('$uri/status_all'));
      if (200 == response.statusCode) {
        return (jsonDecode(response.body) as List)
            .map((e) => StreamStatusDetails.fromJson(e))
            .toList();
      } else if (204 == response.statusCode) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return null;
    }
  }
}
