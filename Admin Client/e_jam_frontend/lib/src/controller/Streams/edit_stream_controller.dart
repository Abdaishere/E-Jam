import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/controller/Streams/add_stream_controller.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  syncGeneratorsDevicesList(
      List<String> generators, bool showDeleted, BuildContext context) {
    context.read<DevicesController>().loadAllDevices(true);

    if (!context.mounted) return;
    context.read<AddStreamController>().syncDevicesList();

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
    updateDevicesCounter();
  }

  syncVerifiersDevicesList(
      List<String> verifiers, bool showDeleted, BuildContext context) {
    context.read<DevicesController>().loadAllDevices(true);

    if (!context.mounted) return;
    context.read<AddStreamController>().syncDevicesList();

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

    updateDevicesCounter();
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
              delay: (num.tryParse(_delayController.text) ?? num.parse("-1")),
              streamId: _idController.text,
              generatorsIds: generators,
              verifiersIds: verifiers,
              payloadType: _payloadType,
              burstLength: (num.tryParse(_burstLengthController.text) ??
                  num.parse("-1")),
              burstDelay:
                  (num.tryParse(_burstDelayController.text) ?? num.parse("-1")),
              numberOfPackets:
                  (num.tryParse(_packetsController.text) ?? num.parse("-1")),
              payloadLength: (num.tryParse(_payloadLengthController.text) ??
                  num.parse("-1")),
              seed: (num.tryParse(_seedController.text) ?? num.parse("-1")),
              broadcastFrames: (num.tryParse(_broadcastFramesController.text) ??
                  num.parse("-1")),
              interFrameGap: (num.tryParse(_interFrameGapController.text) ??
                  num.parse("-1")),
              timeToLive:
                  (num.tryParse(_timeToLiveController.text) ?? num.parse("-1")),
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
    _numberOfVerifiers = stream.verifiersIds.length;
    _numberOfGenerators = stream.generatorsIds.length;
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
