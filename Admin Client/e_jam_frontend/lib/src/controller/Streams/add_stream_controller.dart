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
  get getNumberOfGenerators => _numberOfGenerators;
  get getPickedVerifiers => _pickedVerifiers;
  get getNumberOfVerifiers => _numberOfVerifiers;

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
      if (context.mounted) {
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
                payloadLength:
                    (int.tryParse(_payloadLengthController.text) ?? 0),
                seed: (int.tryParse(_seedController.text) ?? 0),
                broadcastFrames:
                    (int.tryParse(_broadcastFramesController.text) ?? 0),
                interFrameGap:
                    (int.tryParse(_interFrameGapController.text) ?? 0),
                timeToLive: (int.tryParse(_timeToLiveController.text) ?? 0),
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
