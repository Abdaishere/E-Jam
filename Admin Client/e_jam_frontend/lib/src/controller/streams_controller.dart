import 'package:e_jam/src/Model/Classes/device.dart';
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

  static Future loadAllStreamsWithDetails() async {
    isLoading = true;
    return streamServices.getStreams().then((value) {
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

  static Future<bool?> updateStream(String id, StreamEntry stream) async {
    isLoading = true;
    return streamServices.updateStream(id, stream).then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> deleteStream(String id) async {
    isLoading = true;
    return streamServices.deleteStream(id).then((value) {
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

  static Future<bool> startAllStreams() async {
    isLoading = true;
    return streamServices.startAllStreams().then((value) {
      isLoading = false;
      return value;
    });
  }

  static Future<bool> stopAllStreams() async {
    isLoading = true;
    return streamServices.stopAllStreams().then((value) {
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
    return await streamServices.getAllStreamStatus().then((value) {
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
  static int payloadType = 2;
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
          delay: (int.tryParse(delayController.text) ?? 0),
          streamId: idController.text,
          generatorsIds: generators,
          verifiersIds: verifiers,
          payloadType: payloadType,
          burstLength: (int.tryParse(burstLengthController.text) ?? 0),
          burstDelay: (int.tryParse(burstDelayController.text) ?? 0),
          numberOfPackets: (int.tryParse(packetsController.text) ?? 0),
          payloadLength: (int.tryParse(payloadLengthController.text) ?? 0),
          seed: (int.tryParse(seedController.text) ?? 0),
          broadcastFrames: (int.tryParse(broadcastFramesController.text) ?? 0),
          interFrameGap: (int.tryParse(interFrameGapController.text) ?? 0),
          timeToLive: (int.tryParse(timeToLiveController.text) ?? 0),
          transportLayerProtocol: transportLayerProtocol,
          flowType: flowType,
          checkContent: checkContent,
        ),
      );
    }
    return null;
  }

  static syncDevicesList() {
    if (DevicesController.devices == null) return;

    AddStreamController.pickedGenerators = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: pickedGenerators[device.macAddress] ?? false
    };

    pickedVerifiers = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: pickedVerifiers[device.macAddress] ?? false
    };
  }

  static defaultStreamFields() {
    flowType = FlowType.bursts;
    payloadType = 2;
    transportLayerProtocol = TransportLayerProtocol.tcp;
    checkContent = false;
    pickedGenerators =
        pickedGenerators.map((key, value) => MapEntry(key, false));
    pickedVerifiers = pickedVerifiers.map((key, value) => MapEntry(key, false));
  }
}

class EditStreamController {
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
  static int payloadType = 2;
  static TransportLayerProtocol transportLayerProtocol =
      TransportLayerProtocol.tcp;
  static bool checkContent = false;
  static Map<String, bool> pickedGenerators = {};
  static Map<String, bool> pickedVerifiers = {};

  static syncGeneratorsDevicesList(
      List<String> generators, bool showDeleted) async {
    if (DevicesController.devices == null) {
      await DevicesController.loadAllDevices();
      if (DevicesController.devices == null) {
        return;
      }
    }

    pickedGenerators = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: false
    };

    for (final String mac in generators) {
      if (pickedGenerators[mac] == null) {
        if (showDeleted) pickedGenerators[mac] = true;
      } else {
        pickedGenerators[mac] = true;
      }
    }
  }

  static syncVerifiersDevicesList(
      List<String> verifiers, bool showDeleted) async {
    if (DevicesController.devices == null) {
      await DevicesController.loadAllDevices();
      if (DevicesController.devices == null) {
        return;
      }
    }

    pickedVerifiers = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: false
    };

    for (final String mac in verifiers) {
      if (pickedVerifiers[mac] == null) {
        if (showDeleted) pickedVerifiers[mac] = true;
      } else {
        pickedVerifiers[mac] = true;
      }
    }
  }

  static Future<bool?> updateStream(
      GlobalKey<FormState> formKey, String id) async {
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

      return StreamsController.updateStream(
        id,
        StreamEntry(
          name: nameController.text,
          description: descriptionController.text,
          delay: (int.tryParse(delayController.text) ?? 0),
          streamId: idController.text,
          generatorsIds: generators,
          verifiersIds: verifiers,
          payloadType: payloadType,
          burstLength: (int.tryParse(burstLengthController.text) ?? 0),
          burstDelay: (int.tryParse(burstDelayController.text) ?? 0),
          numberOfPackets: (int.tryParse(packetsController.text) ?? 0),
          payloadLength: (int.tryParse(payloadLengthController.text) ?? 0),
          seed: (int.tryParse(seedController.text) ?? 0),
          broadcastFrames: (int.tryParse(broadcastFramesController.text) ?? 0),
          interFrameGap: (int.tryParse(interFrameGapController.text) ?? 0),
          timeToLive: (int.tryParse(timeToLiveController.text) ?? 0),
          transportLayerProtocol: transportLayerProtocol,
          flowType: flowType,
          checkContent: checkContent,
        ),
      );
    }
    return null;
  }

  static updateAllFields(StreamEntry stream) {
    idController.text = stream.streamId;
    nameController.text = stream.name;
    descriptionController.text = stream.description;
    delayController.text = stream.delay.toString();
    timeToLiveController.text = stream.timeToLive.toString();
    interFrameGapController.text = stream.interFrameGap.toString();
    payloadLengthController.text = stream.payloadLength.toString();
    burstLengthController.text = stream.burstLength.toString();
    burstDelayController.text = stream.burstDelay.toString();
    broadcastFramesController.text = stream.broadcastFrames.toString();
    packetsController.text = stream.numberOfPackets.toString();
    seedController.text = stream.seed.toString();
    flowType = stream.flowType;
    payloadType = stream.payloadType;
    transportLayerProtocol = stream.transportLayerProtocol;
    checkContent = stream.checkContent;
    syncGeneratorsDevicesList(stream.generatorsIds, true);
    syncVerifiersDevicesList(stream.verifiersIds, true);
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
    payloadType = 2;
    transportLayerProtocol = TransportLayerProtocol.tcp;
    checkContent = false;
    pickedGenerators = {};
    pickedVerifiers = {};
  }
}
