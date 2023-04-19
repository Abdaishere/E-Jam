import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
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

  static Future<StreamEntry?> loadStreamDetails(String id) async {
    return streamServices.getStream(id).then((value) {
      return value;
    });
  }

  static Future<bool?> createNewStream(StreamEntry stream) async {
    isLoading = true;
    return streamServices.createStream(stream).then((value) {
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

  static Future<bool> queueStream(String id) async {
    isLoading = true;
    return streamServices.startStream(id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> pauseStream(String id) async {
    isLoading = true;
    return streamServices.stopStream(id).then((value) {
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

  static Future<bool> startStream(String id) async {
    isLoading = true;
    return streamServices.forceStartStream(id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> stopStream(String id) async {
    isLoading = true;
    return streamServices.forceStopStream(id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<StreamStatusDetails?> loadStreamStatusDetails(String id) async {
    isLoading = true;
    return streamServices.getStreamStatus(id).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future loadAllStreamStatus() async {
    isLoading = true;
    return streamServices.getAllStreamStatus().then((value) {
      streamsStatusDetails = value;
      isLoading = false;
    });
  }
}

class AddStreamController {
  static TextEditingController idController = TextEditingController();
  static TextEditingController nameController = TextEditingController();
  static TextEditingController descriptionController = TextEditingController();
  static TextEditingController delayController = TextEditingController();
  static TextEditingController timeToLiveController = TextEditingController();
  static TextEditingController interFrameGapController =
      TextEditingController();
  static TextEditingController payloadLengthController =
      TextEditingController();
  static TextEditingController burstLengthController = TextEditingController();
  static TextEditingController burstDelayController = TextEditingController();
  static TextEditingController broadcastFramesController =
      TextEditingController();
  static TextEditingController packetsController = TextEditingController();
  static TextEditingController seedController = TextEditingController();
  static FlowType flowType = FlowType.bursts;
  static int payloadType = 0;
  static TransportLayerProtocol transportLayerProtocol =
      TransportLayerProtocol.tcp;
  static bool checkContent = false;
  static Map<String, bool> pickedGenerators = {};
  static Map<String, bool> pickedVerifiers = {};

  static Future<bool?> addStream(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      List<String> generators = [];
      List<String> verifiers = [];
      pickedGenerators.forEach((key, value) {
        if (value) {
          generators.add(key);
        }
      });

      pickedVerifiers.forEach((key, value) {
        if (value) {
          verifiers.add(key);
        }
      });

      return StreamsController.createNewStream(
        StreamEntry(
          name: nameController.text,
          description: descriptionController.text,
          delay: int.parse(delayController.text),
          streamId: idController.text,
          generatorsIds: generators,
          verifiersIds: verifiers,
          payloadType: payloadType,
          burstLength: int.parse(burstLengthController.text),
          burstDelay: int.parse(burstDelayController.text),
          numberOfPackets: int.parse(packetsController.text),
          payloadLength: int.parse(payloadLengthController.text),
          seed: int.parse(seedController.text),
          broadcastFrames: int.parse(broadcastFramesController.text),
          interFrameGap: int.parse(interFrameGapController.text),
          timeToLive: int.parse(timeToLiveController.text),
          transportLayerProtocol: transportLayerProtocol,
          flowType: flowType,
          checkContent: checkContent,
          runningGenerators: const Process.empty(),
          runningVerifiers: const Process.empty(),
        ),
      );
    }
    return null;
  }

  static clearAllFields() {
    idController.clear();
    nameController.clear();
    descriptionController.clear();
    delayController.clear();
    timeToLiveController.clear();
    interFrameGapController.clear();
    payloadLengthController.clear();
    burstLengthController.clear();
    burstDelayController.clear();
    broadcastFramesController.clear();
    packetsController.clear();
    seedController.clear();
    flowType = FlowType.bursts;
    payloadType = 0;
    transportLayerProtocol = TransportLayerProtocol.tcp;
    checkContent = false;
    pickedGenerators = {};
    pickedVerifiers = {};
  }
}
