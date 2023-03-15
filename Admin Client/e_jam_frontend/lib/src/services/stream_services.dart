import 'dart:convert';
import 'package:e_jam/src/Model/shared_preferences.dart';
import 'package:e_jam/src/Model/stream_entry.dart';

class StreamServices {
  static get backendhostaddress => NetworkController.backendhostaddress;
  static Uri uri = Uri.parse('$backendhostaddress/streams');

  static get client => NetworkController.client;

  static Future<List<StreamEntry>?> getStreams() async {
    try {
      final response = await client.get(uri);
      if (200 == response.statusCode) {
        Iterable l = json.decode(response.body);
        final List<StreamEntry> streams =
            List<StreamEntry>.from(l.map((data) => StreamEntry.fromJson(data)));
        return streams;
      } else if (204 == response.statusCode) {
        return [];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<StreamEntry?> getStream(String id) async {
    try {
      final response = await client.get(Uri.parse('$uri/$id'));

      if (200 == response.statusCode) {
        final StreamEntry stream = StreamEntry.fromRawJson(response.body);
        return stream;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> addStream(StreamEntry stream) async {
    try {
      final response = await client.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: stream.toJson(),
      );

      if (201 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> deleteStream(String id) async {
    try {
      final response = await client.delete(Uri.parse('$uri/$id'));

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> updateStream(StreamEntry stream) async {
    try {
      final response = await client.put(
        Uri.parse('$uri/${stream.streamId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: stream.toJson(),
      );

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> startStream(String id) async {
    try {
      final response = await client.post(
        Uri.parse('$uri/$id/start'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> forceStartStream(String id) async {
    try {
      final response = await client.post(
        Uri.parse('$uri/$id/force_start'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> startAllStreams(String id) async {
    try {
      final response = await client.post(
        Uri.parse('$uri/start_all'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> stopStream(String id) async {
    try {
      final response = await client.post(
        Uri.parse('$uri/$id/stop'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> forceStopStream(String id) async {
    try {
      final response = await client.post(
        Uri.parse('$uri/$id/force_stop'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  Future<bool> stopAllStreams(String id) async {
    try {
      final response = await client.post(
        Uri.parse('$uri/stop_all'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (200 == response.statusCode) {
        isOffline = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isOffline = true;
      return false;
    }
  }

  // get the status of a stream
  // TODO: parse the response body to its streamEntry object
  Future<String> getStreamStatus(String id) async {
    try {
      final response = await client.get(Uri.parse('$uri/$id/status'));

      if (200 == response.statusCode) {
        isOffline = false;
        return response.body;
      } else {
        return '';
      }
    } catch (e) {
      isOffline = true;
      return '';
    }
  }

  // get the status of all streams
  // TODO: parse the response body to its streamEntry object
  Future<List<dynamic>> getAllStreamStatus() async {
    try {
      final response = await client.get(Uri.parse('$uri/status'));

      if (200 == response.statusCode) {
        isOffline = false;
        return response.body;
      } else {
        return [];
      }
    } catch (e) {
      isOffline = true;
      return [];
    }
  }
}
