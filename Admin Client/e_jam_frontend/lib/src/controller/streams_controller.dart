import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
import 'package:e_jam/src/services/stream_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StreamsController extends ChangeNotifier {
  static List<StreamEntry>? _streams;
  static List<StreamStatusDetails>? _streamsStatusDetails;
  static bool _isLoading = true;
  static final StreamServices _streamServices = StreamServices();

  get getStreams => _streams;
  get getStreamsStatusDetails => _streamsStatusDetails;
  get getIsLoading => _isLoading;
  get getStreamServices => _streamServices;

  Future loadAllStreamsWithDetails() async {
    _isLoading = true;
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

  Future<bool?> createNewStream(StreamEntry stream) async {
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
    return _streamServices.startAllStreams().then((value) {
      _isLoading = false;
      return value;
    });
  }

  Future<bool> stopAllStreams() async {
    _isLoading = true;
    return _streamServices.stopAllStreams().then((value) {
      _isLoading = false;
      return value;
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

  Future loadAllStreamStatus() async {
    _isLoading = true;
    return await _streamServices.getAllStreamStatus().then((value) {
      _streamsStatusDetails = value;
      _isLoading = false;
      notifyListeners();
    });
  }
}

class AddStreamController extends ChangeNotifier {
  static final TextEditingController _idController = TextEditingController();
  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _descriptionController =
      TextEditingController();
  static final TextEditingController _delayController = TextEditingController();
  static final TextEditingController _timeToLiveController =
      TextEditingController();
  static final TextEditingController _interFrameGapController =
      TextEditingController();
  static final TextEditingController _payloadLengthController =
      TextEditingController();
  static final TextEditingController _burstLengthController =
      TextEditingController();
  static final TextEditingController _burstDelayController =
      TextEditingController();
  static final TextEditingController _broadcastFramesController =
      TextEditingController();
  static final TextEditingController _packetsController =
      TextEditingController();
  static final TextEditingController _seedController = TextEditingController();
  static FlowType _flowType = FlowType.bursts;
  static int _payloadType = 2;
  static TransportLayerProtocol _transportLayerProtocol =
      TransportLayerProtocol.tcp;
  static bool _checkContent = false;
  static Map<String, bool> _pickedGenerators = {};
  static Map<String, bool> _pickedVerifiers = {};

  get getIdController => _idController;
  get getNameController => _nameController;
  get getDescriptionController => _descriptionController;
  get getDelayController => _delayController;
  get getTimeToLiveController => _timeToLiveController;
  get getInterFrameGapController => _interFrameGapController;
  get getPayloadLengthController => _payloadLengthController;
  get getBurstLengthController => _burstLengthController;
  get getBurstDelayController => _burstDelayController;
  get getBroadcastFramesController => _broadcastFramesController;
  get getPacketsController => _packetsController;
  get getSeedController => _seedController;
  get getFlowType => _flowType;
  get getPayloadType => _payloadType;
  get getTransportLayerProtocol => _transportLayerProtocol;
  get getCheckContent => _checkContent;
  get getPickedGenerators => _pickedGenerators;
  get getPickedVerifiers => _pickedVerifiers;

  void checkContentSwitch() {
    _checkContent = !_checkContent;
    notifyListeners();
  }

  void setPayloadType(int value) {
    _payloadType = value;
    notifyListeners();
  }

  void setFlowType(FlowType value) {
    _flowType = value;
    notifyListeners();
  }

  void setTransportLayerProtocol(TransportLayerProtocol value) {
    _transportLayerProtocol = value;
    notifyListeners();
  }

  void setPickedGenerators(Map<String, bool> value) {
    _pickedGenerators = value;
    notifyListeners();
  }

  void setPickedVerifiers(Map<String, bool> value) {
    _pickedVerifiers = value;
    notifyListeners();
  }

  Future<bool?> addStream(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      List<String> generators = [];
      List<String> verifiers = [];
      _pickedGenerators.forEach((key, value) {
        if (value) {
          generators.add(key);
        }
      });

      _pickedVerifiers.forEach((key, value) {
        if (value) {
          verifiers.add(key);
        }
      });

      return context.read<StreamsController>().createNewStream(
            StreamEntry(
              name: _nameController.text,
              description: _descriptionController.text,
              delay: (int.tryParse(_delayController.text) ?? 0),
              streamId: _idController.text,
              generatorsIds: generators,
              verifiersIds: verifiers,
              payloadType: _payloadType,
              burstLength: (int.tryParse(_burstLengthController.text) ?? 0),
              burstDelay: (int.tryParse(_burstDelayController.text) ?? 0),
              numberOfPackets: (int.tryParse(_packetsController.text) ?? 0),
              payloadLength: (int.tryParse(_payloadLengthController.text) ?? 0),
              seed: (int.tryParse(_seedController.text) ?? 0),
              broadcastFrames:
                  (int.tryParse(_broadcastFramesController.text) ?? 0),
              interFrameGap: (int.tryParse(_interFrameGapController.text) ?? 0),
              timeToLive: (int.tryParse(_timeToLiveController.text) ?? 0),
              transportLayerProtocol: _transportLayerProtocol,
              flowType: _flowType,
              checkContent: _checkContent,
            ),
          );
    }
    return null;
  }

  syncDevicesList() {
    if (DevicesController.devices == null) return;

    AddStreamController._pickedGenerators = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: _pickedGenerators[device.macAddress] ?? false
    };

    _pickedVerifiers = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: _pickedVerifiers[device.macAddress] ?? false
    };
  }

  clearAllFields() {
    _idController.clear();
    _nameController.clear();
    _descriptionController.clear();
    _delayController.clear();
    _timeToLiveController.clear();
    _interFrameGapController.clear();
    _payloadLengthController.clear();
    _burstLengthController.clear();
    _burstDelayController.clear();
    _broadcastFramesController.clear();
    _packetsController.clear();
    _seedController.clear();
    _flowType = FlowType.bursts;
    _payloadType = 2;
    _transportLayerProtocol = TransportLayerProtocol.tcp;
    _checkContent = false;
    _pickedGenerators =
        _pickedGenerators.map((key, value) => MapEntry(key, false));
    _pickedVerifiers =
        _pickedVerifiers.map((key, value) => MapEntry(key, false));
  }
}

class EditStreamController extends ChangeNotifier {
  static final TextEditingController _idController = TextEditingController();
  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _descriptionController =
      TextEditingController();
  static final TextEditingController _delayController = TextEditingController();
  static final TextEditingController _timeToLiveController =
      TextEditingController();
  static final TextEditingController _interFrameGapController =
      TextEditingController();
  static final TextEditingController _payloadLengthController =
      TextEditingController();
  static final TextEditingController _burstLengthController =
      TextEditingController();
  static final TextEditingController _burstDelayController =
      TextEditingController();
  static final TextEditingController _broadcastFramesController =
      TextEditingController();
  static final TextEditingController _packetsController =
      TextEditingController();
  static final TextEditingController _seedController = TextEditingController();
  static FlowType _flowType = FlowType.bursts;
  static int _payloadType = 2;
  static TransportLayerProtocol _transportLayerProtocol =
      TransportLayerProtocol.tcp;
  static bool _checkContent = false;
  static Map<String, bool> _pickedGenerators = {};
  static Map<String, bool> _pickedVerifiers = {};

  get getIdController => _idController;
  get getNameController => _nameController;
  get getDescriptionController => _descriptionController;
  get getDelayController => _delayController;
  get getTimeToLiveController => _timeToLiveController;
  get getInterFrameGapController => _interFrameGapController;
  get getPayloadLengthController => _payloadLengthController;
  get getBurstLengthController => _burstLengthController;
  get getBurstDelayController => _burstDelayController;
  get getBroadcastFramesController => _broadcastFramesController;
  get getPacketsController => _packetsController;
  get getSeedController => _seedController;
  get getFlowType => _flowType;
  get getPayloadType => _payloadType;
  get getTransportLayerProtocol => _transportLayerProtocol;
  get getCheckContent => _checkContent;
  Map<String, bool> get getPickedGenerators => _pickedGenerators;
  Map<String, bool> get getPickedVerifiers => _pickedVerifiers;

  void checkContentSwitch() {
    _checkContent = !_checkContent;
    notifyListeners();
  }

  void setPayloadType(int value) {
    _payloadType = value;
    notifyListeners();
  }

  void setFlowType(FlowType value) {
    _flowType = value;
    notifyListeners();
  }

  void setTransportLayerProtocol(TransportLayerProtocol value) {
    _transportLayerProtocol = value;
    notifyListeners();
  }

  void setPickedGenerators(Map<String, bool> value) {
    _pickedGenerators = value;
    notifyListeners();
  }

  void setPickedVerifiers(Map<String, bool> value) {
    _pickedVerifiers = value;
    notifyListeners();
  }

  syncGeneratorsDevicesList(
      List<String> generators, bool showDeleted, BuildContext context) async {
    if (DevicesController.devices == null) {
      await context.read<DevicesController>().loadAllDevices().then((value) => {
            if (context.mounted)
              context.read<AddStreamController>().syncDevicesList()
          });
      if (DevicesController.devices == null) {
        return;
      }
    }

    _pickedGenerators = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: false
    };

    for (final String mac in generators) {
      if (_pickedGenerators[mac] == null) {
        if (showDeleted) _pickedGenerators[mac] = true;
      } else {
        _pickedGenerators[mac] = true;
      }
    }
  }

  syncVerifiersDevicesList(
      List<String> verifiers, bool showDeleted, BuildContext context) async {
    if (DevicesController.devices == null) {
      await context.read<DevicesController>().loadAllDevices().then((value) => {
            if (context.mounted)
              context.read<AddStreamController>().syncDevicesList()
          });
      if (DevicesController.devices == null) {
        return;
      }
    }

    _pickedVerifiers = {
      for (final Device device in DevicesController.devices!)
        device.macAddress: false
    };

    for (final String mac in verifiers) {
      if (_pickedVerifiers[mac] == null) {
        if (showDeleted) _pickedVerifiers[mac] = true;
      } else {
        _pickedVerifiers[mac] = true;
      }
    }
  }

  Future<bool?> updateStream(
      GlobalKey<FormState> formKey, String id, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      List<String> generators = [];
      List<String> verifiers = [];
      _pickedGenerators.forEach((key, value) {
        if (value) {
          generators.add(key);
        }
      });

      _pickedVerifiers.forEach((key, value) {
        if (value) {
          verifiers.add(key);
        }
      });

      return context.read<StreamsController>().updateStream(
            id,
            StreamEntry(
              name: _nameController.text,
              description: _descriptionController.text,
              delay: (int.tryParse(_delayController.text) ?? 0),
              streamId: _idController.text,
              generatorsIds: generators,
              verifiersIds: verifiers,
              payloadType: _payloadType,
              burstLength: (int.tryParse(_burstLengthController.text) ?? 0),
              burstDelay: (int.tryParse(_burstDelayController.text) ?? 0),
              numberOfPackets: (int.tryParse(_packetsController.text) ?? 0),
              payloadLength: (int.tryParse(_payloadLengthController.text) ?? 0),
              seed: (int.tryParse(_seedController.text) ?? 0),
              broadcastFrames:
                  (int.tryParse(_broadcastFramesController.text) ?? 0),
              interFrameGap: (int.tryParse(_interFrameGapController.text) ?? 0),
              timeToLive: (int.tryParse(_timeToLiveController.text) ?? 0),
              transportLayerProtocol: _transportLayerProtocol,
              flowType: _flowType,
              checkContent: _checkContent,
            ),
          );
    }
    return null;
  }

  loadAllFields(StreamEntry stream, BuildContext context) {
    _idController.text = stream.streamId;
    _nameController.text = stream.name;
    _descriptionController.text = stream.description;
    _delayController.text = stream.delay.toString();
    _timeToLiveController.text = stream.timeToLive.toString();
    _interFrameGapController.text = stream.interFrameGap.toString();
    _payloadLengthController.text = stream.payloadLength.toString();
    _burstLengthController.text = stream.burstLength.toString();
    _burstDelayController.text = stream.burstDelay.toString();
    _broadcastFramesController.text = stream.broadcastFrames.toString();
    _packetsController.text = stream.numberOfPackets.toString();
    _seedController.text = stream.seed.toString();
    _flowType = stream.flowType;
    _payloadType = stream.payloadType;
    _transportLayerProtocol = stream.transportLayerProtocol;
    _checkContent = stream.checkContent;
    syncGeneratorsDevicesList(stream.generatorsIds, true, context);
    syncVerifiersDevicesList(stream.verifiersIds, true, context);
  }

  clearAllFields() {
    _idController.clear();
    _nameController.clear();
    _descriptionController.clear();
    _delayController.clear();
    _timeToLiveController.clear();
    _interFrameGapController.clear();
    _payloadLengthController.clear();
    _burstLengthController.clear();
    _burstDelayController.clear();
    _broadcastFramesController.clear();
    _packetsController.clear();
    _seedController.clear();
    _flowType = FlowType.bursts;
    _payloadType = 2;
    _transportLayerProtocol = TransportLayerProtocol.tcp;
    _checkContent = false;
    _pickedGenerators = {};
    _pickedVerifiers = {};
  }
}
