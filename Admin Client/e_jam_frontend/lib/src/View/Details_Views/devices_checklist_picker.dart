import 'dart:math';

import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DevicesCheckListPicker extends StatefulWidget {
  const DevicesCheckListPicker({
    super.key,
    required this.areGenerators,
    required this.onDevicesSelected,
  });

  final bool areGenerators;
  final Function(String) onDevicesSelected;

  @override
  State<DevicesCheckListPicker> createState() => _DevicesCheckListPickerState();
}

class _DevicesCheckListPickerState extends State<DevicesCheckListPicker> {
  bool isDevicesListLoading = false;
  final List<bool> _devices = List.filled(10, false);

  // load the status of all streams from the server and update the UI with the list of streams status accordingly
  // void loadStreamView() async {
  //   setState(() {
  //     isDevicesListLoading = true;
  //   });
  // TODO: finish after the device list is implemented in the server
  // TODO: finish after the device list is implemented in the server
  // TODO: finish after the device list is implemented in the server
  // TODO: finish after the device list is implemented in the server
  // TODO: finish after the device list is implemented in the server
  // TODO: finish after the device list is implemented in the server
  // TODO: finish after the device list is implemented in the server
  // TODO: finish after the device list is implemented in the server

  //   StreamsController.loadAllStreamStatus(scaffoldMessenger).then(
  //     (value) => {
  //       if (mounted)
  //         setState(() {
  //           streams = controllerStreamsStatusDetails;
  //           isStreamListLoading = controllerIsStreamListLoading;
  //         })
  //     },
  //   );
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(Duration.zero, () => loadStreamView());
  // }

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
      child: Drawer(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.25,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
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
                icon: const FaIcon(FontAwesomeIcons.shuffle,
                    size: 20, semanticLabel: 'Randomize'),
                tooltip: 'Randomize',
                onPressed: () {
                  setState(() {
                    _devices.shuffle(Random());
                  });
                },
              ),
              IconButton(
                icon: const Icon(MaterialCommunityIcons.check_all,
                    size: 20, semanticLabel: 'Select All'),
                tooltip: 'Select All',
                onPressed: () {
                  setState(() {
                    _devices.fillRange(0, _devices.length, true);
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                    MaterialCommunityIcons.checkbox_blank_badge_outline,
                    size: 20,
                    semanticLabel: 'Deselect All'),
                tooltip: 'Deselect All',
                onPressed: () {
                  setState(() {
                    _devices.fillRange(0, _devices.length, true);
                  });
                },
              ),
            ],
          ),
          // each device should be a card view with a checkbox to select the device as a generator or a verifier or both (if the device is a generator and a verifier)
          body: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text('Device $index'),
                value: false,
                onChanged: (value) {
                  setState(() {
                    _devices[index] = value!;
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
