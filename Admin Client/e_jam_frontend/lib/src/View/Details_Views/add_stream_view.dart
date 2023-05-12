import 'dart:math';

import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Details_Views/devices_checklist_picker.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';
import 'package:e_jam/src/controller/Streams/add_stream_controller.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:provider/provider.dart';

final formKey = GlobalKey<FormState>();

class AddStreamView extends StatefulWidget {
  const AddStreamView({super.key});

  @override
  State<AddStreamView> createState() => _AddStreamViewState();
}

class _AddStreamViewState extends State<AddStreamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddStreamController>().syncDevicesList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape &&
              MediaQuery.of(context).size.width > 900
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2,
              vertical: 100)
          : const EdgeInsets.all(20),
      child: Hero(
        tag: 'addStream',
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Scaffold(
            appBar: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 0,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  16.0,
                ),
                color: Colors.blueAccent.shade700,
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
            bottomNavigationBar: const BottomOptionsBar(),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _addStreamFields() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckContentButton(),
          IDNameFields(),
          StreamDescriptionField(),
          DelayTimeToLiveInterFrameGapFields(),
          SizedBox(height: 20),
          StreamDevicesLists(),
          PacketsBroadcastFramesSizes(),
          GenerationSeed(),
          PayloadLengthAndType(),
          BurstLengthAndDelay(),
          FlowAndTLPTypes(),
        ],
      ),
    );
  }
}

class BottomOptionsBar extends StatefulWidget {
  const BottomOptionsBar({
    super.key,
  });

  @override
  State<BottomOptionsBar> createState() => _BottomOptionsBarState();
}

class _BottomOptionsBarState extends State<BottomOptionsBar> {
  int? _status;

  String _statusToMessage(int? status) {
    switch (status) {
      case 200:
        return 'OK';
      case 201:
        return 'Created Successfully';
      case 400:
        return 'Bad Request: Please fill all the required fields correctly';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 408:
        return 'Request Timeout';
      case 409:
        return 'Conflict: Stream with id already exists';
      case 500:
        return 'Internal Server Error';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Unknown State';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(MaterialCommunityIcons.delete_empty),
            tooltip: 'Clear',
            color: Colors.redAccent,
            onPressed: () {
              if (formKey.currentState != null) formKey.currentState!.reset();
              context.read<AddStreamController>().clearAllFields();
            },
          ),
          _status != null && _status! >= 300
              ? RequestStatusIcon(
                  status: _status!,
                  message: _statusToMessage(_status),
                )
              : const SizedBox(
                  width: 40,
                ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blueAccent,
            tooltip: 'OK',
            onPressed: () async {
              int? status = await context
                  .read<AddStreamController>()
                  .addStream(formKey, context);
              if (status != null && context.mounted) {
                if (status < 300) {
                  context.read<StreamsController>().loadAllStreamStatus(true);
                  if (context.mounted) Navigator.pop(context);
                } else {
                  _status = status;
                  setState(() {});
                }
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            color: Colors.red,
            tooltip: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            color: Colors.greenAccent.shade700,
            tooltip: 'Apply',
            onPressed: () async {
              int? status = await context
                  .read<AddStreamController>()
                  .addStream(formKey, context);
              if (status != null) {
                _status = status;
                setState(() {});
                if (status < 300 && context.mounted) {
                  context.read<StreamsController>().loadAllStreamStatus(true);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class CheckContentButton extends StatelessWidget {
  const CheckContentButton({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, right: 20),
          child: IconButton(
            icon: Icon(
              context.watch<AddStreamController>().getCheckContent
                  ? FontAwesomeIcons.eye
                  : FontAwesomeIcons.eyeSlash,
              size: 30,
            ),
            color: context.watch<AddStreamController>().getCheckContent
                ? Colors.greenAccent.shade700
                : Colors.grey,
            tooltip: context.watch<AddStreamController>().getCheckContent
                ? 'Check content'
                : 'Do not check content',
            onPressed: () =>
                context.read<AddStreamController>().checkContentSwitch(),
          ),
        ),
      ],
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
                return 'Please enter a delay';
              } else if (int.tryParse(value) == null) {
                return 'Please enter a valid delay';
              }
              return null;
            },
            controller: context.read<AddStreamController>().getDelayController,
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
            controller:
                context.read<AddStreamController>().getTimeToLiveController,
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
            controller:
                context.read<AddStreamController>().getInterFrameGapController,
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
          if (context.read<AddStreamController>().getPayloadType == 2) {
            return 'Please enter a Generation Seed for Random Payload';
          }
          return null;
        } else if (int.tryParse(value) == null) {
          return 'Please enter a valid Seed';
        }
        return null;
      },
      controller: context.read<AddStreamController>().getSeedController,
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
            controller:
                context.read<AddStreamController>().getBurstLengthController,
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
            controller:
                context.read<AddStreamController>().getBurstDelayController,
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
      children: [
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<FlowType>(
            decoration: const InputDecoration(
              labelText: 'Flow Type',
              hintText: 'Flow Type',
              icon: Icon(MaterialCommunityIcons.transit_connection_variant),
            ),
            value: context.watch<AddStreamController>().getFlowType,
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
            onChanged: (value) =>
                context.read<AddStreamController>().setFlowType(value!),
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
            value:
                context.watch<AddStreamController>().getTransportLayerProtocol,
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
            onChanged: (value) => context
                .read<AddStreamController>()
                .setTransportLayerProtocol(value!),
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
      controller: context.read<AddStreamController>().getDescriptionController,
    );
  }
}

class IDNameFields extends StatelessWidget {
  const IDNameFields({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                return null;
              } else if (!RegExp(r'^\w{3}$').hasMatch(value)) {
                return 'Please enter a valid ID';
              }
              return null;
            },
            controller: context.read<AddStreamController>().getIdController,
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
            controller: context.read<AddStreamController>().getNameController,
          ),
        ),
      ],
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
            controller:
                context.read<AddStreamController>().getPayloadLengthController,
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
            value: context.watch<AddStreamController>().getPayloadType,
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
            onChanged: (value) =>
                context.read<AddStreamController>().setPayloadType(value!),
          ),
        ),
      ],
    );
  }
}

class PacketsBroadcastFramesSizes extends StatefulWidget {
  const PacketsBroadcastFramesSizes({super.key});

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
                context.watch<AddStreamController>().getCheckContent
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
            controller:
                context.read<AddStreamController>().getPacketsController,
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
            controller: context
                .read<AddStreamController>()
                .getBroadcastFramesController,
          ),
        ),
      ],
    );
  }
}

class StreamDevicesLists extends StatefulWidget {
  const StreamDevicesLists({
    super.key,
  });

  @override
  State<StreamDevicesLists> createState() => _StreamDevicesListsState();
}

class _StreamDevicesListsState extends State<StreamDevicesLists> {
  @override
  Widget build(BuildContext context) {
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
              context
                  .watch<AddStreamController>()
                  .getNumberOfGenerators
                  .toString(),
              style: TextStyle(
                color: context
                            .watch<AddStreamController>()
                            .getNumberOfGenerators ==
                        0
                    ? Colors.red
                    : null,
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
                      devicesReloader: () async {
                        await context
                            .read<DevicesController>()
                            .loadAllDevices(true);
                        if (mounted) {
                          await context
                              .read<AddStreamController>()
                              .syncDevicesList();
                        }
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
            title: const Row(
              children: [
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
              context
                  .watch<AddStreamController>()
                  .getNumberOfVerifiers
                  .toString(),
              style: TextStyle(
                  color: context
                              .watch<AddStreamController>()
                              .getNumberOfVerifiers ==
                          0
                      ? Colors.red
                      : null,
                  fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).push(
                DialogRoute(
                  context: context,
                  builder: (BuildContext context) => Center(
                    child: DevicesCheckListPicker(
                      areGenerators: false,
                      devicesReloader: () async {
                        await context
                            .read<DevicesController>()
                            .loadAllDevices(true);
                        if (mounted) {
                          context.read<AddStreamController>().syncDevicesList();
                        }
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
