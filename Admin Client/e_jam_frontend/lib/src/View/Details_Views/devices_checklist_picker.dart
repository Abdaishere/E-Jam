import 'dart:math';

import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
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
  });

  final bool areGenerators;
  final Function saveChanges;

  @override
  State<DevicesCheckListPicker> createState() => _DevicesCheckListPickerState();
}

class _DevicesCheckListPickerState extends State<DevicesCheckListPicker> {
  _syncDevices() {
    setState(() {
      DevicesController.loadAllDevices();
      widget.saveChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          (MediaQuery.of(context).orientation == Orientation.portrait
              ? 1
              : 0.8),
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
                    if (widget.areGenerators) {
                      AddStreamController.pickedGenerators = AddStreamController
                          .pickedGenerators
                          .map((key, value) {
                        return MapEntry(key, Random().nextBool());
                      });
                    } else {
                      AddStreamController.pickedVerifiers =
                          AddStreamController.pickedVerifiers.map((key, value) {
                        return MapEntry(key, Random().nextBool());
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(MaterialCommunityIcons.check_all,
                    size: 20, semanticLabel: 'Select All'),
                tooltip: 'Select All',
                onPressed: () => setState(
                  () {
                    if (widget.areGenerators) {
                      AddStreamController.pickedGenerators = AddStreamController
                          .pickedGenerators
                          .map((key, value) {
                        return MapEntry(key, true);
                      });
                    } else {
                      AddStreamController.pickedVerifiers =
                          AddStreamController.pickedVerifiers.map((key, value) {
                        return MapEntry(key, true);
                      });
                    }
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
                    if (widget.areGenerators) {
                      AddStreamController.pickedGenerators = AddStreamController
                          .pickedGenerators
                          .map((key, value) {
                        return MapEntry(key, false);
                      });
                    } else {
                      AddStreamController.pickedVerifiers =
                          AddStreamController.pickedVerifiers.map((key, value) {
                        return MapEntry(key, false);
                      });
                    }
                  },
                ),
              ),
              // Sync button
              IconButton(
                icon: DevicesController.devices == null
                    ? const Icon(
                        MaterialCommunityIcons.sync_alert,
                        size: 20,
                        color: Colors.yellow,
                      )
                    : const Icon(
                        MaterialCommunityIcons.sync_icon,
                        size: 20,
                      ),
                tooltip: 'Sync Devices',
                onPressed: () async {
                  _syncDevices();
                },
              ),
            ],
          ),
          body: Visibility(
            visible: (widget.areGenerators
                    ? AddStreamController.pickedGenerators.length
                    : AddStreamController.pickedVerifiers.length) !=
                0,
            replacement: Center(
              child: DevicesController.devices == null
                  ? const Text('Cannot Get Devices')
                  : const Text('No Devices Found'),
            ),
            child: ListView.builder(
              itemCount: (widget.areGenerators
                  ? AddStreamController.pickedGenerators.length
                  : AddStreamController.pickedVerifiers.length),
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(DevicesController.devices![index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${DevicesController.devices![index].ipAddress}:${DevicesController.devices![index].port}'),
                  value: widget.areGenerators
                      ? AddStreamController.pickedGenerators[
                          DevicesController.devices![index].macAddress]
                      : AddStreamController.pickedVerifiers[
                          DevicesController.devices![index].macAddress],
                  secondary: Icon(
                    getDeviceIcon(DevicesController.devices![index].name),
                    color: deviceStatusColorScheme(
                        DevicesController.devices![index].status),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (widget.areGenerators) {
                        AddStreamController.pickedGenerators[DevicesController
                            .devices![index].macAddress] = value ?? false;
                      } else {
                        AddStreamController.pickedVerifiers[DevicesController
                            .devices![index].macAddress] = value ?? false;
                      }
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
            onPressed: () async {
              widget.saveChanges();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
