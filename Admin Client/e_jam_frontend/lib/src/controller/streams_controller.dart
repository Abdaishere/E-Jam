import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/services/stream_services.dart';
import 'package:flutter/material.dart';

class StreamsController {
  static List<StreamEntry>? streams;
  static bool isStreamListLoading = true;

  static Future loadStreams(ScaffoldMessengerState scaffoldMessenger) async {
    isStreamListLoading = true;
    return StreamServices.getStreams(scaffoldMessenger).then((value) {
      streams = value;
      streams?.forEach((element) {
        print(element);
      });
      isStreamListLoading = false;
    });
  }
}
