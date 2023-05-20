import 'dart:async';
import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';
import 'package:e_jam/src/services/statistics.dart';
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

  Future loadAllStreams(bool forced) async {
    _isLoading = true;
    if (_streams != null &&
        _streamsStatusDetails != null &&
        !forced &&
        DateTime.now().difference(_lastRefresh).inSeconds < 20) {
      _isLoading = false;
      return;
    }

    _lastRefresh = DateTime.now();
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

  Future<Message?> createNewStream(StreamEntry stream) async {
    _isLoading = true;
    return _streamServices.createStream(stream).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<Message?> updateStream(String id, StreamEntry stream) async {
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
      return success;
    });
  }

  Future<bool> stopAllStreams() async {
    _isLoading = true;
    return _streamServices.stopAllStreams().then((success) {
      _isLoading = false;
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
        DateTime.now().difference(_lastRefresh).inSeconds < 10) {
      _isLoading = false;
      return;
    }

    _lastRefresh = DateTime.now();
    return _streamServices.getAllStreamStatus().then((value) {
      _streamsStatusDetails = value;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<List<VerifierStatisticsInstance>> loadVerifierStatistics(
      String id) async {
    _isLoading = true;
    return _streamServices.getVerifierStatisticsInstances(id).then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<List<GeneratorStatisticsInstance>> loadGeneratorStatistics(
      String id) async {
    _isLoading = true;
    return _streamServices.getGeneratorStatisticsInstance(id).then((value) {
      _isLoading = false;
      return value;
    });
  }
}

class StatisticsController extends ChangeNotifier {
  static final StatisticsService _statisticsService = StatisticsService();
  static DateTime _lastRefresh1 = DateTime.now();
  static DateTime _lastRefresh2 = DateTime.now();
  List<VerifierStatisticsInstance> _verifierStatistics = [];
  List<GeneratorStatisticsInstance> _generatorStatistics = [];

  List<VerifierStatisticsInstance> get getVerifierStatistics =>
      _verifierStatistics;
  List<GeneratorStatisticsInstance> get getGeneratorStatistics =>
      _generatorStatistics;

  loadAllVerifierStatistics() async {
    if (DateTime.now().difference(_lastRefresh1).inSeconds > 10) {
      return _statisticsService
          .getAllVerifierStatisticsInstances()
          .then((value) {
        if (value.isNotEmpty) {
          _lastRefresh1 = DateTime.now();
          _verifierStatistics = value;
        }
        notifyListeners();
      });
    }
  }

  loadAllGeneratorStatistics() async {
    if (DateTime.now().difference(_lastRefresh2).inSeconds > 10) {
      return _statisticsService
          .getAllGeneratorStatisticsInstance()
          .then((value) {
        if (value.isNotEmpty) {
          _generatorStatistics = value;
          _lastRefresh2 = DateTime.now();
        }
        notifyListeners();
      });
    }
  }
}
