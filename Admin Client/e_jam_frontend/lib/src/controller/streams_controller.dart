import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/services/stream_services.dart';
import 'package:flutter/material.dart';

class StreamsController {
  static List<StreamEntry>? streams;
  static List<StreamStatusDetails>? streamsStatusDetails;
  static bool isLoading = true;
  static StreamServices streamServices = StreamServices();

  static Future loadAllStreamsWithDetails(
      ScaffoldMessengerState scaffoldMessenger) async {
    isLoading = true;
    return streamServices.getStreams(scaffoldMessenger).then((value) {
      streams = value;
      isLoading = false;
    });
  }

  static Future<StreamEntry?> loadStreamDetails(
      ScaffoldMessengerState scaffoldMessenger, String id) async {
    isLoading = true;
    return streamServices.getStream(scaffoldMessenger, id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool?> createNewStream(
      ScaffoldMessengerState scaffoldMessenger, StreamEntry stream) async {
    isLoading = true;
    return streamServices.createStream(scaffoldMessenger, stream).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool?> updateStream(
      ScaffoldMessengerState scaffoldMessenger, StreamEntry stream) async {
    isLoading = true;
    return streamServices.updateStream(scaffoldMessenger, stream).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> deleteStream(
      ScaffoldMessengerState scaffoldMessenger, String id) async {
    isLoading = true;
    return streamServices.deleteStream(scaffoldMessenger, id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> queueStream(
      ScaffoldMessengerState scaffoldMessenger, String id) async {
    isLoading = true;
    return streamServices.startStream(scaffoldMessenger, id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> pauseStream(
      ScaffoldMessengerState scaffoldMessenger, String id) async {
    isLoading = true;
    return streamServices.stopStream(scaffoldMessenger, id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> startAllStreams(
      ScaffoldMessengerState scaffoldMessenger) async {
    isLoading = true;
    return streamServices.startAllStreams(scaffoldMessenger).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> stopAllStreams(
      ScaffoldMessengerState scaffoldMessenger) async {
    isLoading = true;
    return streamServices.stopAllStreams(scaffoldMessenger).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> startStream(
      ScaffoldMessengerState scaffoldMessenger, String id) async {
    isLoading = true;
    return streamServices.forceStartStream(scaffoldMessenger, id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> stopStream(
      ScaffoldMessengerState scaffoldMessenger, String id) async {
    isLoading = true;
    return streamServices.forceStopStream(scaffoldMessenger, id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<StreamStatusDetails?> loadStreamStatusDetails(
      ScaffoldMessengerState scaffoldMessenger, String id) async {
    isLoading = true;
    return streamServices.getStreamStatus(scaffoldMessenger, id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future loadAllStreamStatus(
      ScaffoldMessengerState scaffoldMessenger) async {
    isLoading = true;
    return streamServices.getAllStreamStatus(scaffoldMessenger).then((value) {
      streamsStatusDetails = value;
      isLoading = false;
    });
  }
}
