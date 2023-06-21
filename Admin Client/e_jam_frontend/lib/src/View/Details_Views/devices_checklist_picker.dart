import 'dart:developer';
import 'dart:math';

import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/device_status_icon_button.dart';
import 'package:e_jam/src/controller/Streams/add_stream_controller.dart';
import 'package:e_jam/src/controller/Streams/edit_stream_controller.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DevicesCheckListPicker extends StatefulWidget {
  const DevicesCheckListPicker({
    super.key,
    required this.areGenerators,
    required this.isStateless,
    required this.devicesReloader,
  });

  final bool areGenerators;
  final TimelineAsyncFunction devicesReloader;
  final bool isStateless;
  @override
  State<DevicesCheckListPicker> createState() => _DevicesCheckListPickerState();
}

class _DevicesCheckListPickerState extends State<DevicesCheckListPicker> {
  Map<String, bool> _devicesMap = {};

  _syncDevices() async {
    if (widget.isStateless) {
      if (widget.areGenerators) {
        _devicesMap = Map<String, bool>.from(
            context.read<EditStreamController>().getPickedGenerators);
      } else {
        _devicesMap = Map<String, bool>.from(
            context.read<EditStreamController>().getPickedVerifiers);
      }
    } else {
      await widget.devicesReloader();
      if (!mounted) return;
      if (widget.areGenerators) {
        _devicesMap = Map<String, bool>.from(
            context.read<AddStreamController>().getPickedGenerators);
      } else {
        _devicesMap = Map<String, bool>.from(
            context.read<AddStreamController>().getPickedVerifiers);
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape &&
              MediaQuery.of(context).size.width > 800
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.3,
              vertical: MediaQuery.of(context).size.height * 0.08)
          : const EdgeInsets.all(100),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                  widget.areGenerators
                      ? MaterialCommunityIcons.progress_upload
                      : MaterialCommunityIcons.progress_check,
                  semanticLabel: 'Devices'),
              color: widget.areGenerators ? uploadColor : downloadColor,
              tooltip: widget.areGenerators
                  ? 'Select Generating Devices'
                  : 'Select Verifying Devices',
              onPressed: () {},
            ),
            actions: [
              IconButton(
                  icon: const Icon(MaterialCommunityIcons.shuffle_variant,
                      size: 20, semanticLabel: 'Randomize'),
                  tooltip: 'Randomize',
                  onPressed: () => {
                        _devicesMap = _devicesMap.map((key, value) {
                          return MapEntry(key, Random().nextBool());
                        }),
                        setState(() {}),
                      }),
              IconButton(
                icon: const Icon(MaterialCommunityIcons.check_all,
                    size: 20, semanticLabel: 'Select All'),
                tooltip: 'Select All',
                onPressed: () => {
                  _devicesMap = _devicesMap.map((key, value) {
                    return MapEntry(key, true);
                  }),
                  setState(() {}),
                },
              ),
              // Deselect all button
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.checkbox_blank_badge_outline,
                  size: 20,
                ),
                tooltip: 'Deselect All',
                onPressed: () => {
                  _devicesMap = _devicesMap.map((key, value) {
                    return MapEntry(key, false);
                  }),
                  setState(() {}),
                },
              ),
              // Sync button
              IconButton(
                icon: _devicesMap.isEmpty || DevicesController.devices == null
                    ? Icon(
                        DevicesController.devices == null
                            ? Icons.warning_amber_rounded
                            : MaterialCommunityIcons.sync_alert,
                        color: DevicesController.devices == null
                            ? Colors.red
                            : _devicesMap.isNotEmpty
                                ? Colors.orange
                                : null,
                      )
                    : const Icon(
                        MaterialCommunityIcons.sync_icon,
                        size: 20,
                      ),
                tooltip:
                    _devicesMap.isEmpty || DevicesController.devices == null
                        ? 'Sync Devices'
                        : 'Undo Changes',
                onPressed: () => _syncDevices(),
              ),
            ],
          ),
          body: DevicesController.devices == null || _devicesMap.isEmpty
              ? Center(
                  child: DevicesController.devices == null
                      ? const Text('Cannot Get Devices')
                      : const Text('No Devices Found'),
                )
              : ListView.builder(
                  itemCount: _devicesMap.length,
                  itemBuilder: (context, index) {
                    if (index >= DevicesController.devices!.length) {
                      return CheckboxListTile(
                        title: const Text("Unknown Device"),
                        subtitle: Text(
                          _getName(index),
                        ),
                        value: true,
                        secondary: const Icon(
                          MaterialCommunityIcons.alert_box_outline,
                          color: Colors.red,
                        ),
                        onChanged: (value) {
                          _devicesMap.remove(_devicesMap.keys.elementAt(index));
                          setState(() {});
                        },
                      );
                    }
                    return CheckboxListTile(
                      title: Text(
                        _getName(index),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${DevicesController.devices![index].ipAddress}:${DevicesController.devices![index].port}'),
                      value: _devicesMap.values.elementAt(index),
                      secondary: Icon(
                        getDeviceIcon(DevicesController.devices![index].name),
                        color: deviceStatusColorScheme(
                            DevicesController.devices![index].status),
                      ),
                      checkboxShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      activeColor:
                          widget.areGenerators ? uploadColor : downloadColor,
                      onChanged: (value) {
                        _devicesMap[_devicesMap.keys.elementAt(index)] = value!;
                        setState(() {});
                      },
                    );
                  },
                ),
          bottomNavigationBar: _bottomOptionsBar(),
        ),
      ),
    );
  }

  String _getName(int index) {
    if (index < DevicesController.devices!.length) {
      return DevicesController.devices![index].name.isNotEmpty
          ? DevicesController.devices![index].name
          : DevicesController.devices![index].ipAddress;
    } else {
      return _devicesMap.keys.elementAt(index);
    }
  }

  BottomAppBar _bottomOptionsBar() {
    return BottomAppBar(
      elevation: 0,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            color: Colors.red,
            tooltip: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blue,
            tooltip: 'Save',
            onPressed: () {
              if (widget.isStateless) {
                if (widget.areGenerators) {
                  context
                      .read<EditStreamController>()
                      .setPickedGenerators(_devicesMap);
                } else {
                  context
                      .read<EditStreamController>()
                      .setPickedVerifiers(_devicesMap);
                }
              } else {
                if (widget.areGenerators) {
                  context
                      .read<AddStreamController>()
                      .setPickedGenerators(_devicesMap);
                } else {
                  context
                      .read<AddStreamController>()
                      .setPickedVerifiers(_devicesMap);
                }
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
