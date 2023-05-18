import 'dart:async';

import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/processes.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

// should include all the devices and their streams and the total packets (uploaded and downloaded) of each stream in the device
// gives error for index (IDK yet)
class TreeMapDrillDownDevicesLoad extends StatefulWidget {
  const TreeMapDrillDownDevicesLoad({super.key});

  @override
  State<TreeMapDrillDownDevicesLoad> createState() =>
      _TreeMapDrillDownDevicesLoadState();
}

class _TreeMapDrillDownDevicesLoadState
    extends State<TreeMapDrillDownDevicesLoad> {
  List<ProcessInfo> _source = [];
  bool _isLoading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => taskGetter());
    timer =
        Timer.periodic(const Duration(seconds: 30), (Timer t) => taskGetter());
  }

  taskGetter() async {
    await context.read<DevicesController>().loadAllDevices(false);
    if (mounted) await context.read<StreamsController>().loadAllStreams(false);
    if (mounted) {
      final List<Device>? devices =
          context.read<DevicesController>().getDevices;

      final List<StreamEntry>? streams =
          context.read<StreamsController>().getStreams;
      getSources(devices ?? [], streams ?? []);
    }
  }

  getSources(List<Device> devices, List<StreamEntry> streams) {
    List<ProcessInfo> source = [];
    for (final StreamEntry stream in streams) {
      for (final Device device in devices) {
        Map<ProcessStatus, ProcessInfo> deviceProcesses = {};
        if (stream.runningGenerators?.processes
                .containsKey(device.macAddress) ??
            false) {
          ProcessStatus? processStatus =
              stream.runningGenerators?.processes[device.macAddress]!;

          if (processStatus != null) {
            deviceProcesses[processStatus] = ProcessInfo(
              deviceName: "${device.name} \n${device.macAddress} ",
              streamOnDevice:
                  "${stream.name} \nID: ${stream.streamId} \nType: Generator ",
              deviceStatus: device.status ?? DeviceStatus.offline,
              totalProcesses:
                  (deviceProcesses[processStatus]?.totalProcesses ?? 0) + 1,
              processStatus: processStatus,
            );
          }
        }

        if (stream.runningVerifiers?.processes.containsKey(device.macAddress) ??
            false) {
          ProcessStatus? processStatus =
              stream.runningVerifiers?.processes[device.macAddress]!;
          if (processStatus != null) {
            deviceProcesses[processStatus] = ProcessInfo(
              deviceName: "${device.name} \n${device.macAddress} ",
              streamOnDevice:
                  "${stream.name} \nID: ${stream.streamId} \nType: Verifier",
              deviceStatus: device.status ?? DeviceStatus.offline,
              totalProcesses:
                  (deviceProcesses[processStatus]?.totalProcesses ?? 0) + 1,
              processStatus: processStatus,
            );
          }
        }

        List values = deviceProcesses.values.toList();
        for (int i = 0; i < values.length; i++) {
          source.add(values[i]);
        }
      }
    }
    if (source.isNotEmpty) {
      _source.clear();
      _source = source;
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _source.clear();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Center(
          child: LoadingAnimationWidget.dotsTriangle(
            color: Colors.grey,
            size: 70.0,
          ),
        ),
      );
    } else if (_source.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: const Center(
          child: Icon(
            Icons.stream_sharp,
            color: Colors.redAccent,
            size: 100.0,
          ),
        ),
      );
    }

    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: _getTreemap());
  }

  Card _getTreemap() {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 10, right: 10),
        child: SfTreemap(
          legend: SystemSettings.fullTreeMap && _source.length < 50
              ? const TreemapLegend(
                  position: TreemapLegendPosition.top,
                  title: Text('Devices Load'),
                )
              : null,
          dataCount: _source.length,
          // for each device, the total number of processes on it is displayed for the first level
          // on the second level, the processes are displayed for each stream on the device
          weightValueMapper: (int index) {
            return _source[index].totalProcesses;
          },
          enableDrilldown: true,
          breadcrumbs: TreemapBreadcrumbs(
            builder: (BuildContext context, TreemapTile tile, bool isCurrent) {
              if (tile.group == 'Home') {
                return const Icon(MaterialCommunityIcons.home, size: 20);
              } else {
                return Text(
                  tile.group.substring(0, tile.group.indexOf('\n')),
                );
              }
            },
            divider: const Icon(Icons.chevron_right),
            position: TreemapBreadcrumbPosition.top,
          ),
          levels: [
            // Displays the device name in the first level.
            TreemapLevel(
              border: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
              ),
              padding: const EdgeInsets.all(1.0),
              // map the groups using the device name in the first level
              groupMapper: (int index) {
                String deviceGroup = _source[index].deviceName;
                return deviceGroup;
              },
              labelBuilder: (BuildContext context, TreemapTile tile) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                  child: Text(
                    tile.group.substring(0, tile.group.indexOf('\n')),
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              // map the color using the device status in the first level
              colorValueMapper: (TreemapTile tile) {
                return deviceStatusColorScheme(
                    _source[tile.indices[0]].deviceStatus);
              },
              tooltipBuilder: (BuildContext context, TreemapTile tile) {
                double totalDeviceProcesses = 0;
                for (int i = 0; i < _source.length; i++) {
                  if (_source[i].deviceName ==
                      _source[tile.indices[0]].deviceName) {
                    totalDeviceProcesses += _source[i].totalProcesses;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Device: ${tile.group.substring(0, tile.group.indexOf('\n'))} \nProcesses: ${(totalDeviceProcesses).floor()}',
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            ),

            // Displays the stream name in the second level.
            TreemapLevel(
              border: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
              ),
              padding: const EdgeInsets.all(1.0),
              // map the groups using the stream name in the second level and process status
              groupMapper: (int index) {
                String statusType =
                    processStatusToString(_source[index].processStatus);
                String deviceStreamGroup = _source[index].streamOnDevice;

                return "$deviceStreamGroup\n$statusType";
              },
              // map the color using the device status in the second level
              colorValueMapper: (TreemapTile tile) {
                return processStatusColorScheme(
                    _source[tile.indices[0]].processStatus);
              },
              labelBuilder: (BuildContext context, TreemapTile tile) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                  child: Text(
                    tile.group.substring(0, tile.group.indexOf('\n')),
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              tooltipBuilder: (BuildContext context, TreemapTile tile) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Stream: ${tile.group} \nProcesses: ${(_source[tile.indices[0]].totalProcesses).floor()}',
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProcessInfo {
  const ProcessInfo({
    required this.deviceName,
    required this.streamOnDevice,
    required this.deviceStatus,
    required this.totalProcesses,
    required this.processStatus,
  });
  final String deviceName;
  final String streamOnDevice;
  final DeviceStatus deviceStatus;
  final ProcessStatus processStatus;
  final double totalProcesses;
}
