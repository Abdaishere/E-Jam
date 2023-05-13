import 'dart:convert';
import 'dart:io';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';

class StreamServices {
  static Uri uri = Uri.parse('${NetworkController.serverIpAddress}/streams');
  static get client => NetworkController.client;

  Future<List<StreamEntry>?> getStreams() async {
    try {
      final response = await client.get(uri).timeout(NetworkController.timeout);

      if (200 == response.statusCode) {
        return (json.decode(response.body) as List)
            .map((e) => StreamEntry.fromJson(e))
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

  Future<StreamEntry?> getStream(String streamId) async {
    try {
      final response = await client.get(Uri.parse('$uri/$streamId'));
      if (300 > response.statusCode) {
        return StreamEntry.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Message?> createStream(StreamEntry stream) async {
    try {
      final response = await client
          .post(
            uri,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: json.encode(stream.toJson()),
          )
          .timeout(NetworkController.timeout);
      return Message(message: response.body, responseCode: response.statusCode);
    } catch (e) {
      return null;
    }
  }

  Future<bool?> updateStream(String id, StreamEntry stream) async {
    try {
      final response = await client
          .put(
            Uri.parse('$uri/$id'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: json.encode(stream.toJson()),
          )
          .timeout(NetworkController.timeout);

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteStream(String streamId) async {
    try {
      final response = await client.delete(Uri.parse('$uri/$streamId'));

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> startStream(String streamId) async {
    try {
      final response = await client.post(Uri.parse('$uri/$streamId/start'));

      if (300 > response.statusCode) {
        return true;
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

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> startAllStreams() async {
    try {
      final response = await client.post(Uri.parse('$uri/start_all'));

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopAllStreams() async {
    try {
      final response = await client.post(Uri.parse('$uri/stop_all'));

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> forceStartStream(String streamId) async {
    try {
      final response =
          await client.post(Uri.parse('$uri/$streamId/force_start'));

      if (300 > response.statusCode) {
        return true;
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

      if (300 > response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<StreamStatusDetails?> getStreamStatus(String streamId) async {
    try {
      final response = await client
          .get(Uri.parse('$uri/$streamId/status'))
          .timeout(NetworkController.timeout);

      if (300 > response.statusCode) {
        return StreamStatusDetails.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<StreamStatusDetails>?> getAllStreamStatus() async {
    try {
      final response = await client
          .get(Uri.parse('$uri/status_all'))
          .timeout(NetworkController.timeout);

      if (200 == response.statusCode) {
        return (jsonDecode(response.body) as List)
            .map((e) => StreamStatusDetails.fromJson(e))
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
}
