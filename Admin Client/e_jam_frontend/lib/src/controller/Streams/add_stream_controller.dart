import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  static int _numberOfGenerators = 0;
  static Map<String, bool> _pickedVerifiers = {};
  static int _numberOfVerifiers = 0;

  TextEditingController get getIdController => _idController;
  TextEditingController get getNameController => _nameController;
  TextEditingController get getDescriptionController => _descriptionController;
  TextEditingController get getDelayController => _delayController;
  TextEditingController get getTimeToLiveController => _timeToLiveController;
  TextEditingController get getInterFrameGapController =>
      _interFrameGapController;
  TextEditingController get getPayloadLengthController =>
      _payloadLengthController;
  TextEditingController get getBurstLengthController => _burstLengthController;
  TextEditingController get getBurstDelayController => _burstDelayController;
  TextEditingController get getBroadcastFramesController =>
      _broadcastFramesController;
  TextEditingController get getPacketsController => _packetsController;
  TextEditingController get getSeedController => _seedController;
  FlowType get getFlowType => _flowType;
  int get getPayloadType => _payloadType;
  TransportLayerProtocol get getTransportLayerProtocol =>
      _transportLayerProtocol;
  bool get getCheckContent => _checkContent;
  Map<String, bool> get getPickedGenerators => _pickedGenerators;
  int get getNumberOfGenerators => _numberOfGenerators;
  Map<String, bool> get getPickedVerifiers => _pickedVerifiers;
  int get getNumberOfVerifiers => _numberOfVerifiers;

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
    updateDevicesCounter();
  }

  void setPickedVerifiers(Map<String, bool> value) {
    _pickedVerifiers = value;
    updateDevicesCounter();
  }

  void updateDevicesCounter() async {
    _numberOfGenerators = 0;
    _numberOfVerifiers = 0;

    getPickedGenerators.forEach((key, value) {
      if (value) _numberOfGenerators++;
    });

    getPickedVerifiers.forEach((key, value) {
      if (value) _numberOfVerifiers++;
    });

    notifyListeners();
  }

  Future<int?> addStream(
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
      if (context.mounted) {
        return context.read<StreamsController>().createNewStream(
              StreamEntry(
                name: _nameController.text,
                description: _descriptionController.text,
                delay: (num.tryParse(_delayController.text) ?? num.parse("-1")),
                streamId: _idController.text,
                generatorsIds: generators,
                verifiersIds: verifiers,
                payloadType: _payloadType,
                burstLength: (num.tryParse(_burstLengthController.text) ??
                    num.parse("-1")),
                burstDelay: (num.tryParse(_burstDelayController.text) ??
                    num.parse("-1")),
                numberOfPackets:
                    (num.tryParse(_packetsController.text) ?? num.parse("-1")),
                payloadLength: (num.tryParse(_payloadLengthController.text) ??
                    num.parse("-1")),
                seed: (num.tryParse(_seedController.text) ?? num.parse("-1")),
                broadcastFrames:
                    (num.tryParse(_broadcastFramesController.text) ??
                        num.parse("-1")),
                interFrameGap: (num.tryParse(_interFrameGapController.text) ??
                    num.parse("-1")),
                timeToLive: (num.tryParse(_timeToLiveController.text) ??
                    num.parse("-1")),
                transportLayerProtocol: _transportLayerProtocol,
                flowType: _flowType,
                checkContent: _checkContent,
              ),
            );
      }
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

    updateDevicesCounter();
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
    _numberOfGenerators = 0;
    _numberOfVerifiers = 0;
    notifyListeners();
  }
}
