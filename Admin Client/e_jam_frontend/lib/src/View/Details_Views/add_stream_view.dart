import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/devices_checklist_picker.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:e_jam/src/services/stream_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';

// TODO: Make the AddStreamView a CardView
class AddStreamView extends StatefulWidget {
  const AddStreamView({super.key});

  @override
  State<AddStreamView> createState() => _AddStreamViewState();
}

class _AddStreamViewState extends State<AddStreamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _delayController = TextEditingController();
  final TextEditingController _timeToLiveController = TextEditingController();
  final TextEditingController _interFrameGapController =
      TextEditingController();
  final TextEditingController _payloadLengthController =
      TextEditingController();
  final TextEditingController _burstLengthController = TextEditingController();
  final TextEditingController _burstDelayController = TextEditingController();
  final TextEditingController __broadcastFramesController =
      TextEditingController();
  final TextEditingController __packetsController = TextEditingController();
  final TextEditingController __seedController = TextEditingController();
  late FlowType __flowType = FlowType.bursts;
  late int __payloadType = 0;
  late TransportLayerProtocol __transportLayerProtocol =
      TransportLayerProtocol.tcp;
  bool __checkContent = false;

  List<String> _generators = [];
  List<String> _verifiers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  _addStream() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      StreamsController.createNewStream(
        ScaffoldMessenger.of(context),
        StreamEntry(
          name: _nameController.text,
          description: _descriptionController.text,
          delay: int.parse(_delayController.text),
          streamId: _idController.text,
          generatorsIds: _generators,
          verifiersIds: _verifiers,
          payloadType: __payloadType,
          burstLength: int.parse(_burstLengthController.text),
          burstDelay: int.parse(_burstDelayController.text),
          numberOfPackets: int.parse(__packetsController.text),
          payloadLength: int.parse(_payloadLengthController.text),
          seed: int.parse(__seedController.text),
          broadcastFrames: int.parse(__broadcastFramesController.text),
          interFrameGap: int.parse(_interFrameGapController.text),
          timeToLive: int.parse(_timeToLiveController.text),
          transportLayerProtocol: __transportLayerProtocol,
          flowType: __flowType,
          checkContent: __checkContent,
          runningGenerators: const Process.empty(),
          runningVerifiers: const Process.empty(),
          streamStatus: StreamStatus.created,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'addStream',
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
                : 0.5),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Scaffold(
            appBar: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 0,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
                color: Colors.blueAccent,
              ),
              labelColor: Colors.white,
              labelStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
              dividerColor: Colors.transparent,
              unselectedLabelColor: Colors.grey,
              controller: _tabController,
              tabs: const <Widget>[
                Tab(
                  height: 42.0,
                  text: 'Stream Details',
                ),
                Tab(
                  height: 42.0,
                  text: 'Pre sets',
                ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Form(
                  key: formKey,
                  child: _addStreamFields(),
                ),
                const AddPresetStream(),
              ],
            ),
            bottomNavigationBar: _bottomAddStreamOptions(context),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _addStreamFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _iDNameFields(),
          _streamDescriptionField(),
          _delayTimeToLiveInterFrameGapFields(),
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

  // TODO: change to dropdown menu
  Row _flowAndTLPTypes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Icon(FontAwesomeIcons.barsStaggered),
        const VerticalDivider(),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<FlowType>(
            decoration: const InputDecoration(
              labelText: 'Flow Type',
              hintText: 'Flow Type',
            ),
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
              __flowType = value!;
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<TransportLayerProtocol>(
            decoration: const InputDecoration(
              labelText: 'Transport Layer Protocol',
              hintText: 'TLP Type',
            ),
            value: TransportLayerProtocol.tcp,
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
              __transportLayerProtocol = value!;
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: IconButton(
              icon: Icon(
                __checkContent
                    ? FontAwesomeIcons.eye
                    : FontAwesomeIcons.eyeSlash,
                size: 30,
              ),
              tooltip:
                  __checkContent ? 'Check content' : 'Do not check content',
              onPressed: () {
                setState(() {
                  __checkContent = !__checkContent;
                });
              },
            ),
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
              icon: Icon(Icons.graphic_eq),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value is UnsignedLong) {
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
              if (value is UnsignedLong) {
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
              icon: Icon(Icons.featured_play_list_rounded),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value is UnsignedLong) {
                return 'Please enter a valid payload length';
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
            value: 0,
            items: const [
              DropdownMenuItem(
                value: 0,
                child: Text('Random'),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text('Incremental'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Decremental'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                __payloadType = value!;
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
        if (value is UnsignedLong) {
          return 'Please enter a valid number of packets';
        }
        return null;
      },
      controller: __seedController,
    );
  }

  Row _packetsBroadcastFramesSizes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Number of Packets',
              hintText: 'Number of Packets to be sent',
              icon: Icon(Icons.filter_frames_rounded),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value is UnsignedLong) {
                return 'Please enter a valid number of packets';
              }
              return null;
            },
            controller: __packetsController,
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
              if (value is UnsignedLong) {
                return 'Please enter a valid number of frames';
              }
              return null;
            },
            controller: __broadcastFramesController,
          ),
        ),
      ],
    );
  }

  // TODO: change to dropdown add get devices and checked devices
  Padding _streamDevicesLists() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: const Icon(
                  MaterialCommunityIcons.progress_upload,
                  semanticLabel: 'Devices',
                  color: uploadColor,
                  size: 40,
                ),
              ),
              tooltip: 'Generating Devices',
              onPressed: () {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (BuildContext context) => Center(
                      child: DevicesCheckListPicker(
                        areGenerators: true,
                        onDevicesSelected: (value) {
                          // find the value in the list and remove it otherwise add it
                          if (!_generators.remove(value)) {
                            _generators.add(value);
                          }
                        },
                      ),
                    ),
                    settings:
                        const RouteSettings(name: 'GeneratingDevicesView'),
                  ),
                );
                print(_generators);
              },
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(
                MaterialCommunityIcons.progress_check,
                semanticLabel: 'Devices',
                color: downloadColor,
                size: 40,
              ),
              tooltip: 'Verifying Devices',
              onPressed: () {
                _verifiers = Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (BuildContext context) => Center(
                      child: DevicesCheckListPicker(
                        areGenerators: false,
                        onDevicesSelected: (value) {
                          // find the value in the list and remove it otherwise add it
                          if (!_verifiers.remove(value)) {
                            _verifiers.add(value);
                          }
                        },
                      ),
                    ),
                    settings: const RouteSettings(name: 'VerifyingDevicesView'),
                  ),
                ) as List<String>;
                print(_verifiers);
              },
            ),
          ),
        ],
      ),
    );
  }

  Row _iDNameFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            enableIMEPersonalizedLearning: false,
            maxLength: 3,
            decoration: const InputDecoration(
              labelText: 'ID',
              hintText: '3 characters',
              icon: Icon(Icons.qr_code),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'\w')),
            ],
            validator: (value) {
              if (!RegExp(r'^\w{3}$').hasMatch(value!)) {
                return 'Please enter a valid ID';
              }
              return null;
            },
            controller: _idController,
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 2,
          child: TextFormField(
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Name of the stream',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name for the stream';
              }
              return null;
            },
            controller: _nameController,
          ),
        ),
      ],
    );
  }

  TextFormField _streamDescriptionField() {
    return TextFormField(
      maxLength: 255,
      maxLines: 1,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Description of the stream',
        icon: Icon(Icons.description),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description for the stream';
        }
        return null;
      },
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
            enableIMEPersonalizedLearning: false,
            decoration: const InputDecoration(
              labelText: 'Delay',
              hintText: 'In milliseconds',
              icon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value is! UnsignedLong) {
                return 'Please enter a valid delay time';
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
            enableIMEPersonalizedLearning: false,
            decoration: const InputDecoration(
              labelText: 'Time to live',
              hintText: 'In milliseconds',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value is! UnsignedLong) {
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
            enableIMEPersonalizedLearning: false,
            decoration: const InputDecoration(
              labelText: 'Inter frame gap',
              hintText: 'In milliseconds',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value is! UnsignedLong) {
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

  BottomAppBar _bottomAddStreamOptions(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            color: Colors.redAccent,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blueAccent,
            onPressed: () {
              _addStream();
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            color: Colors.greenAccent,
            onPressed: () {
              _addStream();
            },
          ),
        ],
      ),
    );
  }
}

class AddPresetStream extends StatefulWidget {
  const AddPresetStream({super.key});

  @override
  State<AddPresetStream> createState() => _AddPresetStreamState();
}

class _AddPresetStreamState extends State<AddPresetStream> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Preset Stream'));
  }
}
