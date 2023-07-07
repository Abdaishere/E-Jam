import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';
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

  Future<Message?> addStream(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (context.mounted) {
        return context.read<StreamsController>().createNewStream(
              createStreamEntry(),
            );
      }
    }
    return null;
  }

  StreamEntry createStreamEntry() {
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

    return StreamEntry(
      name: _nameController.text,
      description: _descriptionController.text,
      delay: num.parse(_delayController.text).floor(),
      streamId: _idController.text,
      generatorsIds: generators,
      verifiersIds: verifiers,
      payloadType: _payloadType,
      burstLength: num.parse(_burstLengthController.text).floor(),
      burstDelay: num.parse(_burstDelayController.text).floor(),
      numberOfPackets: num.parse(_packetsController.text).floor(),
      payloadLength: num.parse(_payloadLengthController.text).floor(),
      seed: num.parse(_seedController.text).floor(),
      broadcastFrames: num.parse(_broadcastFramesController.text).floor(),
      interFrameGap: num.parse(_interFrameGapController.text).floor(),
      duration: num.parse(_timeToLiveController.text).floor(),
      transportLayerProtocol: _transportLayerProtocol,
      flowType: _flowType,
      checkContent: _checkContent,
    );
  }

  loadAllFields(StreamEntry stream) {
    _nameController.text = stream.name;
    _descriptionController.text = stream.description;
    _delayController.text = stream.delay.toString();
    _timeToLiveController.text = stream.duration.toString();
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
