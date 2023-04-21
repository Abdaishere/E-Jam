import 'dart:math';

import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Details_Views/devices_checklist_picker.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';

class EditStreamView extends StatefulWidget {
  const EditStreamView(
      {super.key,
      required this.reload,
      required this.stream,
      required this.id});

  final Function() reload;
  final StreamEntry stream;
  final String id;
  @override
  State<EditStreamView> createState() => _EditStreamViewState();
}

class _EditStreamViewState extends State<EditStreamView>
    with SingleTickerProviderStateMixin {
  bool pickedVerifiersFirstTime = true;
  bool pickedGeneratorsFirstTime = true;
  final formKey = GlobalKey<FormState>();
  StreamEntry get stream => widget.stream;
  late int _numberOfGenerators;
  late int _numberOfVerifiers;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _delayController;
  late TextEditingController _timeToLiveController;
  late TextEditingController _interFrameGapController;
  late TextEditingController _payloadLengthController;
  late TextEditingController _burstLengthController;
  late TextEditingController _burstDelayController;
  late TextEditingController _broadcastFramesController;
  late TextEditingController _packetsController;
  late TextEditingController _seedController;
  late FlowType _flowType;
  late int _payloadType;
  late TransportLayerProtocol _transportLayerProtocol;
  late bool _checkContent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: stream.name);
    _descriptionController = TextEditingController(text: stream.description);
    _delayController = TextEditingController(text: stream.delay.toString());
    _timeToLiveController =
        TextEditingController(text: stream.timeToLive.toString());
    _interFrameGapController =
        TextEditingController(text: stream.interFrameGap.toString());
    _payloadLengthController =
        TextEditingController(text: stream.payloadLength.toString());
    _burstLengthController =
        TextEditingController(text: stream.burstLength.toString());
    _burstDelayController =
        TextEditingController(text: stream.burstDelay.toString());
    _broadcastFramesController =
        TextEditingController(text: stream.broadcastFrames.toString());
    _packetsController =
        TextEditingController(text: stream.numberOfPackets.toString());
    _seedController = TextEditingController(text: stream.seed.toString());
    _flowType = stream.flowType;
    _payloadType = stream.payloadType;
    _transportLayerProtocol = stream.transportLayerProtocol;
    _checkContent = stream.checkContent;
    _numberOfVerifiers = stream.verifiersIds.length;
    _numberOfGenerators = stream.generatorsIds.length;
    EditStreamController.syncGeneratorsDevicesList(stream.generatorsIds);
    EditStreamController.syncVerifiersDevicesList(stream.verifiersIds);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _delayController.dispose();
    _timeToLiveController.dispose();
    _interFrameGapController.dispose();
    _payloadLengthController.dispose();
    _burstLengthController.dispose();
    _burstDelayController.dispose();
    _broadcastFramesController.dispose();
    _packetsController.dispose();
    _seedController.dispose();
    EditStreamController.pickedGenerators.clear();
    EditStreamController.pickedVerifiers.clear();
    super.dispose();
  }

  _updateDevicesCounter() {
    int counter1 = 0;
    EditStreamController.pickedGenerators.forEach((key, value) {
      if (value) counter1++;
    });

    int counter2 = 0;
    EditStreamController.pickedVerifiers.forEach((key, value) {
      if (value) counter2++;
    });

    if (mounted &&
        (counter1 != _numberOfGenerators || counter2 != _numberOfVerifiers)) {
      setState(() {
        _numberOfGenerators = counter1;
        _numberOfVerifiers = counter2;
      });
    }
  }

  _editStream() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      List<String> generators = [];
      List<String> verifiers = [];
      EditStreamController.pickedGenerators.forEach((key, value) {
        if (value) {
          generators.add(key);
        }
      });

      EditStreamController.pickedVerifiers.forEach((key, value) {
        if (value) {
          verifiers.add(key);
        }
      });

      bool success = await StreamsController.updateStream(
            stream.streamId,
            StreamEntry(
              name: _nameController.text,
              description: _descriptionController.text,
              delay: (int.tryParse(_delayController.text) ?? 0),
              streamId: stream.streamId,
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
          ) ??
          false;

      if (success && mounted) {
        widget.reload();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.id,
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: SizedBox(
        height: MediaQuery.of(context).size.height *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.8),
        width: MediaQuery.of(context).size.width *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.6),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Stream'),
              centerTitle: true,
            ),
            body: Form(
              key: formKey,
              child: _addStreamFields(),
            ),
            bottomNavigationBar: _bottomOptionsBar(context),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _addStreamFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _nameCheckContentButtonFields(),
          _streamDescriptionField(),
          _delayTimeToLiveInterFrameGapFields(),
          const SizedBox(height: 20),
          _streamDevicesLists(),
          _packetsBroadcastFramesSizes(),
          _generationSeed(),
          _payloadLengthAndType(),
          _burstLengthAndDelay(),
          _flowAndTLPTypes(),
        ],
      ),
    );
  }

  Row _streamDevicesLists() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Row(
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: const Icon(
                    MaterialCommunityIcons.progress_upload,
                    semanticLabel: 'Generators',
                    color: uploadColor,
                  ),
                ),
                const VerticalDivider(),
                const Text(
                  'Generators',
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Text(
              _numberOfGenerators.toString(),
              style: TextStyle(
                color: _numberOfGenerators == 0 ? Colors.red : null,
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                DialogRoute(
                  context: context,
                  builder: (BuildContext context) => Center(
                    child: DevicesCheckListPicker(
                      areGenerators: true,
                      saveChanges: () => _updateDevicesCounter(),
                      devicesReloader: () => {
                        EditStreamController.syncGeneratorsDevicesList(
                            stream.generatorsIds),
                      },
                      isStateless: true,
                    ),
                  ),
                  settings: const RouteSettings(name: 'AddGenerators'),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Row(
              children: const [
                Icon(
                  MaterialCommunityIcons.progress_check,
                  semanticLabel: 'Verifiers',
                  color: downloadColor,
                ),
                VerticalDivider(),
                Text(
                  'Verifiers',
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            trailing: Text(
              _numberOfVerifiers.toString(),
              style: TextStyle(
                  color: _numberOfVerifiers == 0 ? Colors.red : null,
                  fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).push(
                DialogRoute(
                  context: context,
                  builder: (BuildContext context) => Center(
                    child: DevicesCheckListPicker(
                      areGenerators: false,
                      saveChanges: () => _updateDevicesCounter(),
                      devicesReloader: () => {
                        EditStreamController.syncVerifiersDevicesList(
                            stream.verifiersIds),
                      },
                      isStateless: true,
                    ),
                  ),
                  settings: const RouteSettings(name: 'AddVerifiers'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Row _flowAndTLPTypes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Icon(MaterialCommunityIcons.transit_connection_variant),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<FlowType>(
            decoration: const InputDecoration(
              labelText: 'Flow Type',
              hintText: 'Flow Type',
            ),
            value: _flowType,
            items: const [
              DropdownMenuItem(
                value: FlowType.backToBack,
                child: Text('Back to Back'),
              ),
              DropdownMenuItem(
                value: FlowType.bursts,
                child: Text('Bursts'),
              ),
            ],
            validator: (value) {
              if (value == null) {
                return 'Please enter a valid flow type';
              }
              return null;
            },
            onChanged: (value) {
              _flowType = value!;
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<TransportLayerProtocol>(
            decoration: const InputDecoration(
              labelText: 'Transport Layer Protocol',
              hintText: 'TLP Type',
            ),
            value: _transportLayerProtocol,
            items: const [
              DropdownMenuItem(
                value: TransportLayerProtocol.tcp,
                child: Text('TCP'),
              ),
              DropdownMenuItem(
                value: TransportLayerProtocol.udp,
                child: Text('UDP'),
              ),
            ],
            onChanged: (value) {
              _transportLayerProtocol = value!;
            },
          ),
        ),
      ],
    );
  }

  Row _burstLengthAndDelay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Burst length',
              hintText: 'Length of the burst',
              icon: Icon(MaterialCommunityIcons.broadcast),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a burst length';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid burst length';
              }
              return null;
            },
            controller: _burstLengthController,
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Burst Delay',
              hintText: 'Delay between bursts',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a burst delay';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid burst delay';
              }
              return null;
            },
            controller: _burstDelayController,
          ),
        ),
      ],
    );
  }

  Row _payloadLengthAndType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Payload Length',
              hintText: 'Length of the payload',
              icon: Icon(
                Icons.featured_play_list_rounded,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a payload length';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid payload length';
              } else if (int.parse(value) > 1500) {
                return 'Payload length cannot be greater than 1500';
              }
              return null;
            },
            controller: _payloadLengthController,
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Type',
              hintText: 'Type of the payload',
            ),
            value: _payloadType,
            items: const [
              DropdownMenuItem(
                value: 0,
                child: Text('Type 0'),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text('Type 1'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Random'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _payloadType = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  TextFormField _generationSeed() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Generation Seed',
        hintText: 'Seed for the generation of packets',
        icon: Icon(MaterialCommunityIcons.seed),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      validator: (value) {
        if (value == null || value.isEmpty || value == '0') {
          if (_payloadType == 2) {
            return 'Please enter a Generation Seed for Random Payload';
          }
          return null;
        } else if (int.tryParse(value) == null) {
          return 'Please enter a valid Seed';
        }
        return null;
      },
      controller: _seedController,
    );
  }

  Row _packetsBroadcastFramesSizes() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Number of Packets',
              hintText: 'Number of Packets to be sent',
              icon: Icon(
                _checkContent
                    ? MaterialCommunityIcons.package_variant
                    : MaterialCommunityIcons.package_variant_closed,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number of packets';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid number of packets';
              }
              return null;
            },
            controller: _packetsController,
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Broadcast Frames Size',
              hintText: 'Frames to be broadcasted',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number of frames';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid number of frames';
              }
              return null;
            },
            controller: _broadcastFramesController,
          ),
        ),
      ],
    );
  }

  Row _nameCheckContentButtonFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Name of the stream',
              icon: Icon(MaterialCommunityIcons.id_card, size: 25),
              isDense: true,
            ),
            controller: _nameController,
          ),
        ),
        const VerticalDivider(),
        IconButton(
          icon: Icon(
            _checkContent ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
            size: 30,
          ),
          color: _checkContent ? Colors.greenAccent.shade700 : Colors.grey,
          tooltip: _checkContent ? 'Check content' : 'Do not check content',
          onPressed: () {
            setState(() {
              _checkContent = !_checkContent;
            });
          },
        ),
        const VerticalDivider(),
      ],
    );
  }

  TextFormField _streamDescriptionField() {
    return TextFormField(
      maxLength: 255,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Description of the stream',
        icon: Icon(Icons.description, size: 25),
        isDense: true,
      ),
      controller: _descriptionController,
    );
  }

  Row _delayTimeToLiveInterFrameGapFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Delay',
              hintText: 'In milliseconds',
              icon: Icon(MaterialCommunityIcons.timer),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a time to live';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid time to live';
              }
              return null;
            },
            controller: _delayController,
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Time to live',
              hintText: 'In milliseconds',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a time to live';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid time to live';
              }
              return null;
            },
            controller: _timeToLiveController,
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Inter frame gap',
              hintText: 'In milliseconds',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an inter frame gap';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid inter frame gap';
              }
              return null;
            },
            controller: _interFrameGapController,
          ),
        ),
      ],
    );
  }

  BottomAppBar _bottomOptionsBar(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blueAccent,
            onPressed: () => _editStream(),
          ),
        ],
      ),
    );
  }
}
