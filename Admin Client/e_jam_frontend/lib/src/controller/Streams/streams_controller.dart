import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/services/stream_services.dart';
import 'package:flutter/material.dart';

class StreamsController extends ChangeNotifier {
  static List<StreamEntry>? _streams;
  static List<StreamStatusDetails>? _streamsStatusDetails;
  static bool _isLoading = true;
  static DateTime _lastRefresh = DateTime.now();
  static final StreamServices _streamServices = StreamServices();

  List<StreamEntry>? get getStreams => _streams;
  List<StreamStatusDetails>? get getStreamsStatusDetails =>
      _streamsStatusDetails;
  bool get getIsLoading => _isLoading;
  StreamServices get getStreamServices => _streamServices;

  Future loadAllStreamsWithDetails(bool forced) async {
    _isLoading = true;
    if (_streams != null &&
        !forced &&
        DateTime.now().difference(_lastRefresh).inSeconds < 5) {
      _isLoading = false;
      return;
    }
    return _streamServices.getStreams().then((value) {
      _streams = value;
      _isLoading = false;
    });
  }

  Future<StreamEntry?> loadStreamDetails(String id) async {
    return _streamServices.getStream(id).then((value) {
      return value;
    });
  }

  Future<int?> createNewStream(StreamEntry stream) async {
    _isLoading = true;
    return _streamServices.createStream(stream).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool?> updateStream(String id, StreamEntry stream) async {
    _isLoading = true;
    return _streamServices.updateStream(id, stream).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> deleteStream(String id) async {
    _isLoading = true;
    return _streamServices.deleteStream(id).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> queueStream(String id) async {
    _isLoading = true;
    return _streamServices.startStream(id).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> pauseStream(String id) async {
    _isLoading = true;
    return _streamServices.stopStream(id).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> startAllStreams() async {
    _isLoading = true;
    return _streamServices.startAllStreams().then((success) {
      _isLoading = false;
      SystemSettings.streamsAreRunning = true;
      return success;
    });
  }

  Future<bool> stopAllStreams() async {
    _isLoading = true;
    return _streamServices.stopAllStreams().then((success) {
      _isLoading = false;
      SystemSettings.streamsAreRunning = false;
      return success;
    });
  }

  Future<bool> startStream(String id) async {
    _isLoading = true;
    return _streamServices.forceStartStream(id).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> stopStream(String id) async {
    _isLoading = true;
    return _streamServices.forceStopStream(id).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<StreamStatusDetails?> loadStreamStatusDetails(String id) async {
    _isLoading = true;
    return _streamServices.getStreamStatus(id).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future loadAllStreamStatus(bool forced) async {
    _isLoading = true;
    if (_streamsStatusDetails != null &&
        !forced &&
        DateTime.now().difference(_lastRefresh).inSeconds < 5) {
      _isLoading = false;
      return;
    }

    return _streamServices.getAllStreamStatus().then((value) {
      _streamsStatusDetails = value;
      _isLoading = false;
      _lastRefresh = DateTime.now();
      notifyListeners();
    });
  }
}
