import 'dart:math';

import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Lists/devices_list_view.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DevicesCheckListPicker extends StatefulWidget {
  const DevicesCheckListPicker({
    super.key,
    required this.areGenerators,
    required this.saveChanges,
    required this.isStateless,
    required this.devicesReloader,
  });

  final bool areGenerators;
  final Function saveChanges;
  final Function devicesReloader;
  final bool isStateless;
  @override
  State<DevicesCheckListPicker> createState() => _DevicesCheckListPickerState();
}

class _DevicesCheckListPickerState extends State<DevicesCheckListPicker> {
  late Map<String, bool> _devicesMap;
  _syncDevices() {
    widget.devicesReloader();
    setState(
      () {
        if (widget.isStateless) {
          if (widget.areGenerators) {
            _devicesMap =
                Map<String, bool>.from(EditStreamController.pickedGenerators);
          } else {
            _devicesMap =
                Map<String, bool>.from(EditStreamController.pickedVerifiers);
          }
        } else {
          if (widget.areGenerators) {
            _devicesMap =
                Map<String, bool>.from(AddStreamController.pickedGenerators);
          } else {
            _devicesMap =
                Map<String, bool>.from(AddStreamController.pickedVerifiers);
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _syncDevices();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          (MediaQuery.of(context).orientation == Orientation.portrait
              ? 1
              : 0.75),
      width: MediaQuery.of(context).size.width *
          (MediaQuery.of(context).orientation == Orientation.portrait
              ? 1
              : 0.4),
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
                onPressed: () => setState(
                  () {
                    _devicesMap = _devicesMap.map((key, value) {
                      return MapEntry(key, Random().nextBool());
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(MaterialCommunityIcons.check_all,
                    size: 20, semanticLabel: 'Select All'),
                tooltip: 'Select All',
                onPressed: () => setState(
                  () {
                    _devicesMap = _devicesMap.map((key, value) {
                      return MapEntry(key, true);
                    });
                  },
                ),
              ),
              // Deselect all button
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.checkbox_blank_badge_outline,
                  size: 20,
                ),
                tooltip: 'Deselect All',
                onPressed: () => setState(
                  () {
                    _devicesMap = _devicesMap.map((key, value) {
                      return MapEntry(key, false);
                    });
                  },
                ),
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
                tooltip: 'Sync Devices',
                onPressed: () => _syncDevices(),
              ),
            ],
          ),
          body: Visibility(
            visible:
                _devicesMap.isNotEmpty && DevicesController.devices != null,
            replacement: Center(
              child: DevicesController.devices == null
                  ? const Text('Cannot Get Devices')
                  : const Text('No Devices Found'),
            ),
            child: ListView.builder(
              itemCount: _devicesMap.length,
              itemBuilder: (context, index) {
                if (index >= DevicesController.devices!.length) {
                  return CheckboxListTile(
                    title: const Text("Deleted"),
                    subtitle: Text(
                      _getName(index),
                    ),
                    value: false,
                    secondary: const Icon(
                      MaterialCommunityIcons.alert,
                      color: Colors.red,
                    ),
                    onChanged: null,
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
                    setState(() {
                      _devicesMap[_devicesMap.keys.elementAt(index)] = value!;
                    });
                  },
                );
              },
            ),
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
                  EditStreamController.pickedGenerators = _devicesMap;
                } else {
                  EditStreamController.pickedVerifiers = _devicesMap;
                }
              } else {
                if (widget.areGenerators) {
                  AddStreamController.pickedGenerators = _devicesMap;
                } else {
                  AddStreamController.pickedVerifiers = _devicesMap;
                }
              }
              Navigator.pop(context);
              widget.saveChanges();
            },
          ),
        ],
      ),
    );
  }
}
