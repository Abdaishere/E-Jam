import 'dart:developer';

import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/processes.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/device_status_icon_button.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class StreamDevicesList extends StatefulWidget {
  const StreamDevicesList(
      {super.key,
      required this.areGenerators,
      this.process,
      required this.reloadStream});

  final bool areGenerators;
  final Processes? process;
  final TimelineAsyncFunction reloadStream;

  @override
  State<StreamDevicesList> createState() => _StreamDevicesListState();
}

class _StreamDevicesListState extends State<StreamDevicesList> {
  _syncDevices() async {
    widget.reloadStream();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape &&
              MediaQuery.of(context).size.width > 800
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.3,
              vertical: MediaQuery.of(context).size.height * 0.09)
          : const EdgeInsets.all(100),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                widget.areGenerators ? 'Generating status' : 'Verifying status',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            centerTitle: true,
            actions: [
              // Sync button
              IconButton(
                icon: widget.process == null
                    ? const Icon(
                        MaterialCommunityIcons.alert,
                        size: 20,
                      )
                    : const Icon(
                        MaterialCommunityIcons.sync_icon,
                        size: 20,
                      ),
                tooltip: 'Sync Devices',
                onPressed: () => _syncDevices,
              ),
            ],
          ),
          body: Visibility(
            visible: widget.process != null &&
                widget.process!.processesMap.isNotEmpty &&
                DevicesController.devices != null,
            replacement: Center(
              child: DevicesController.devices == null
                  ? const Text('Cannot Get Devices List')
                  : const Text('No Devices Running'),
            ),
            child: ListView.builder(
              itemCount: widget.process?.processesMap.length ?? 0,
              itemBuilder: (context, index) {
                String macAddress =
                    widget.process!.processesMap.keys.elementAt(index);
                index = DevicesController.devices!
                    .indexWhere((element) => element.macAddress == macAddress);
                if (index == -1) {
                  return ListTile(
                    title: Text(
                      macAddress,
                    ),
                    subtitle: const Text(
                      'Unknown Device',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    leading: const Icon(
                      MaterialCommunityIcons.help_network,
                    ),
                    trailing: RotationTransition(
                      turns: const AlwaysStoppedAnimation(320 / 360),
                      child: Text(
                        processStatusToString(
                            widget.process!.processesMap[macAddress]),
                        style: TextStyle(
                          color: processStatusColorScheme(
                              widget.process!.processesMap[macAddress]),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }
                return ListTile(
                  title: Text(
                    DevicesController.devices![index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(macAddress),
                  leading: Icon(
                    getDeviceIcon(DevicesController.devices![index].name),
                    color: deviceStatusColorScheme(
                        DevicesController.devices![index].status),
                  ),
                  trailing: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      child: Text(
                        processStatusToString(
                            widget.process!.processesMap[macAddress]),
                        style: TextStyle(
                          color: processStatusColorScheme(
                              widget.process!.processesMap[macAddress]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
