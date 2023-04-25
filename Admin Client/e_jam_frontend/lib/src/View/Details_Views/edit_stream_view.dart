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

  @override
  void initState() {
    super.initState();
    EditStreamController.updateAllFields(stream);
    _numberOfVerifiers = stream.verifiersIds.length;
    _numberOfGenerators = stream.generatorsIds.length;
  }

  @override
  void dispose() {
    super.dispose();
    EditStreamController.clearAllFields();
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
    _numberOfGenerators = counter1;
    _numberOfVerifiers = counter2;
    if (mounted) {
      setState(() {});
    }
  }

  _editStream() async {
    bool success =
        await EditStreamController.updateStream(formKey, widget.id) ?? false;
    if (success && mounted) {
      widget.reload();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? const EdgeInsets.symmetric(horizontal: 200, vertical: 100)
          : const EdgeInsets.all(20),
      child: Hero(
        tag: widget.id,
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Stream'),
              centerTitle: true,
            ),
            body: Form(
              key: formKey,
              child: _editStreamFields(),
            ),
            bottomNavigationBar: _bottomOptionsBar(context),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _editStreamFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _nameCheckContentButtonFields(),
          const StreamDescriptionField(),
          const DelayTimeToLiveInterFrameGapFields(),
          const SizedBox(height: 20),
          _streamDevicesLists(),
          PacketsBroadcastFramesSizes(
            checkContent: EditStreamController.checkContent,
          ),
          const GenerationSeed(),
          const PayloadLengthAndType(),
          const BurstLengthAndDelay(),
          const FlowAndTLPTypes(),
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
                            stream.generatorsIds, false),
                        _updateDevicesCounter(),
                      },
                      isStateless: true,
                    ),
                  ),
                  settings: const RouteSettings(name: 'EditGenerators'),
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
                            stream.verifiersIds, false),
                        _updateDevicesCounter(),
                      },
                      isStateless: true,
                    ),
                  ),
                  settings: const RouteSettings(name: 'EditVerifiers'),
                ),
              );
            },
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
            controller: EditStreamController.nameController,
          ),
        ),
        const VerticalDivider(),
        IconButton(
          icon: Icon(
            EditStreamController.checkContent
                ? FontAwesomeIcons.eye
                : FontAwesomeIcons.eyeSlash,
            size: 30,
          ),
          color: EditStreamController.checkContent
              ? Colors.greenAccent.shade700
              : Colors.grey,
          tooltip: EditStreamController.checkContent
              ? 'Check content'
              : 'Do not check content',
          onPressed: () {
            EditStreamController.checkContent =
                !EditStreamController.checkContent;
            setState(() {});
          },
        ),
        const VerticalDivider(),
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

class PacketsBroadcastFramesSizes extends StatefulWidget {
  const PacketsBroadcastFramesSizes({super.key, required this.checkContent});

  final bool checkContent;
  @override
  State<PacketsBroadcastFramesSizes> createState() =>
      _PacketsBroadcastFramesSizesState();
}

class _PacketsBroadcastFramesSizesState
    extends State<PacketsBroadcastFramesSizes> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Number of Packets',
              hintText: 'Number of Packets to be sent',
              icon: Icon(
                widget.checkContent
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
            controller: EditStreamController.packetsController,
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
            controller: EditStreamController.broadcastFramesController,
          ),
        ),
      ],
    );
  }
}

class PayloadLengthAndType extends StatelessWidget {
  const PayloadLengthAndType({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            controller: EditStreamController.payloadLengthController,
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
            value: EditStreamController.payloadType,
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
              EditStreamController.payloadType = value!;
            },
          ),
        ),
      ],
    );
  }
}

class FlowAndTLPTypes extends StatelessWidget {
  const FlowAndTLPTypes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            value: EditStreamController.flowType,
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
              EditStreamController.flowType = value!;
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
            value: EditStreamController.transportLayerProtocol,
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
              EditStreamController.transportLayerProtocol = value!;
            },
          ),
        ),
      ],
    );
  }
}

class BurstLengthAndDelay extends StatelessWidget {
  const BurstLengthAndDelay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            controller: EditStreamController.burstLengthController,
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
            controller: EditStreamController.burstDelayController,
          ),
        ),
      ],
    );
  }
}

class GenerationSeed extends StatelessWidget {
  const GenerationSeed({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
          if (EditStreamController.payloadType == 2) {
            return 'Please enter a Generation Seed for Random Payload';
          }
          return null;
        } else if (int.tryParse(value) == null) {
          return 'Please enter a valid Seed';
        }
        return null;
      },
      controller: EditStreamController.seedController,
    );
  }
}

class DelayTimeToLiveInterFrameGapFields extends StatelessWidget {
  const DelayTimeToLiveInterFrameGapFields({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            controller: EditStreamController.delayController,
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
            controller: EditStreamController.timeToLiveController,
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
            controller: EditStreamController.interFrameGapController,
          ),
        ),
      ],
    );
  }
}

class StreamDescriptionField extends StatelessWidget {
  const StreamDescriptionField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 255,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Description of the stream',
        icon: Icon(Icons.description, size: 25),
        isDense: true,
      ),
      controller: EditStreamController.descriptionController,
    );
  }
}
