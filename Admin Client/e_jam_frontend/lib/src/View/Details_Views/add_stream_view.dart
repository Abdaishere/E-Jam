import 'dart:math';

import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Details_Views/devices_checklist_picker.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';

class AddStreamView extends StatefulWidget {
  const AddStreamView({super.key, required this.reload});

  final Function() reload;
  @override
  State<AddStreamView> createState() => _AddStreamViewState();
}

class _AddStreamViewState extends State<AddStreamView>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late TabController _tabController;
  int _numberOfGenerators = 0;
  int _numberOfVerifiers = 0;
  Color _tabBarColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateDevicesCounter();
  }

  _updateDevicesCounter() {
    int counter1 = 0;
    AddStreamController.pickedGenerators.forEach((key, value) {
      if (value) counter1++;
    });

    int counter2 = 0;
    AddStreamController.pickedVerifiers.forEach((key, value) {
      if (value) counter2++;
    });

    if (mounted &&
        (counter1 != _numberOfGenerators || counter2 != _numberOfVerifiers)) {
      setState(() {
        _numberOfVerifiers = counter2;
        _numberOfGenerators = counter1;
      });
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
                : 0.6),
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
                color: _tabBarColor,
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
                  text: 'Stream Details',
                ),
                Tab(
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
          _checkContentButton(),
          _iDNameFields(),
          _streamDescriptionField(),
          _delayTimeToLiveInterFrameGapFields(),
          const SizedBox(height: 20),
          _streamDevicesLists(),
          _packetsBroadcastFramesSizes(),
          _generationSeed(),
          const PayloadLengthAndType(),
          _burstLengthAndDelay(),
          _flowAndTLPTypes(),
        ],
      ),
    );
  }

  Row _checkContentButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, right: 20),
          child: IconButton(
            icon: Icon(
              AddStreamController.checkContent
                  ? FontAwesomeIcons.eye
                  : FontAwesomeIcons.eyeSlash,
              size: 30,
            ),
            color: AddStreamController.checkContent
                ? Colors.greenAccent.shade700
                : Colors.grey,
            tooltip: AddStreamController.checkContent
                ? 'Check content'
                : 'Do not check content',
            onPressed: () {
              setState(() {
                AddStreamController.checkContent =
                    !AddStreamController.checkContent;
              });
            },
          ),
        ),
      ],
    );
  }

  Row _flowAndTLPTypes() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<FlowType>(
            decoration: const InputDecoration(
              labelText: 'Flow Type',
              hintText: 'Flow Type',
              icon: Icon(MaterialCommunityIcons.transit_connection_variant),
            ),
            value: AddStreamController.flowType,
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
              AddStreamController.flowType = value!;
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
            value: AddStreamController.transportLayerProtocol,
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
              AddStreamController.transportLayerProtocol = value!;
            },
          ),
        ),
      ],
    );
  }

  Row _burstLengthAndDelay() {
    return Row(
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
            controller: AddStreamController.burstLengthController,
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
            controller: AddStreamController.burstDelayController,
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
          if (AddStreamController.payloadType == 2) {
            return 'Please enter a Generation Seed for Random Payload';
          }
          return null;
        } else if (int.tryParse(value) == null) {
          return 'Please enter a valid Seed';
        }
        return null;
      },
      controller: AddStreamController.seedController,
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
                AddStreamController.checkContent
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
            controller: AddStreamController.packetsController,
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
            controller: AddStreamController.broadcastFramesController,
          ),
        ),
      ],
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
                    size: 26,
                  ),
                ),
                const VerticalDivider(),
                const Text(
                  'Generators',
                  overflow: TextOverflow.clip,
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
                        DevicesController.loadAllDevices(),
                      },
                      isStateless: false,
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
                  size: 26,
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
                        DevicesController.loadAllDevices(),
                      },
                      isStateless: false,
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

  Row _iDNameFields() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            enableIMEPersonalizedLearning: false,
            maxLength: 3,
            decoration: const InputDecoration(
              labelText: 'ID',
              hintText: '3 characters',
              icon: Icon(MaterialCommunityIcons.id_card, size: 25),
              isDense: true,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'\w')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an ID';
              } else if (!RegExp(r'^\w{3}$').hasMatch(value)) {
                return 'Please enter a valid ID';
              }
              return null;
            },
            controller: AddStreamController.idController,
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
              isDense: true,
            ),
            controller: AddStreamController.nameController,
          ),
        ),
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
      controller: AddStreamController.descriptionController,
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
                return 'Please enter a delay';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid delay';
              }
              return null;
            },
            controller: AddStreamController.delayController,
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
            controller: AddStreamController.timeToLiveController,
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
                return 'Please enter a inter frame gap';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid inter frame gap';
              }
              return null;
            },
            controller: AddStreamController.interFrameGapController,
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
            icon: const Icon(MaterialCommunityIcons.delete_empty),
            tooltip: 'Clear all fields',
            color: Colors.redAccent,
            onPressed: () {
              setState(() {
                _tabBarColor = Colors.blueAccent;
                formKey.currentState!.reset();
                _numberOfGenerators = _numberOfVerifiers = 0;
                AddStreamController.clearAllFields();
              });
            },
          ),
          const Divider(),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blueAccent,
            onPressed: () async {
              bool? success = await AddStreamController.addStream(formKey);

              if (success != null) {
                if (success) {
                  widget.reload();
                  if (mounted) Navigator.pop(context);
                }
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            color: Colors.greenAccent.shade700,
            onPressed: () async {
              bool? success = await AddStreamController.addStream(formKey);
              if (success != null) {
                setState(() {
                  if (success) {
                    _tabBarColor = Colors.greenAccent.shade700;
                    widget.reload();
                  } else {
                    _tabBarColor = Colors.redAccent;
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

class PayloadLengthAndType extends StatefulWidget {
  const PayloadLengthAndType({super.key});

  @override
  State<PayloadLengthAndType> createState() => _PayloadLengthAndTypeState();
}

class _PayloadLengthAndTypeState extends State<PayloadLengthAndType> {
  @override
  Widget build(BuildContext context) {
    return Row(
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
            controller: AddStreamController.payloadLengthController,
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
            value: AddStreamController.payloadType,
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
                AddStreamController.payloadType = value!;
              });
            },
          ),
        ),
      ],
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
