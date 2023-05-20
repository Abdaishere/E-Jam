import 'dart:math';
import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Details_Views/edit_device_view.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/device_status_icon_button.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:timeago/timeago.dart' as timeago;

class DevicesDetailsView extends StatefulWidget {
  const DevicesDetailsView({super.key, required this.device});

  final Device device;
  @override
  State<DevicesDetailsView> createState() => _DevicesDetailsViewState();
}

class _DevicesDetailsViewState extends State<DevicesDetailsView> {
  Device? updateDevice;

  void refresh() async {
    Device? value = await context
        .read<DevicesController>()
        .loadDeviceDetails(widget.device.macAddress);

    updateDevice = value;
    if (mounted) {
      setState(() {});
      context.read<DevicesController>().loadAllDevices(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Device device = updateDevice ?? widget.device;
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape &&
              MediaQuery.of(context).size.width > 800
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.28,
              vertical: 100)
          : const EdgeInsets.all(20),
      child: Hero(
        tag: device.macAddress,
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                device.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              centerTitle: true,
              actions: [
                DevicePinger(mac: device.macAddress),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.pencil),
                  color: Colors.green,
                  tooltip: 'Edit Device',
                  onPressed: () {
                    Navigator.of(context).push(
                      HeroDialogRoute(
                        builder: (BuildContext context) => Center(
                          child: EditDeviceView(
                            mac: device.macAddress,
                            refresh: refresh,
                            device: device,
                          ),
                        ),
                        settings: const RouteSettings(name: 'EditDeviceView'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.trash_can),
                  color: Colors.red,
                  tooltip: 'Delete Device',
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Delete Device?'),
                        content: Text(
                            'Are you sure you want to delete device ${device.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              bool value = await context
                                  .read<DevicesController>()
                                  .deleteDevice(device.macAddress);

                              if (value && mounted) {
                                context
                                    .read<DevicesController>()
                                    .loadAllDevices(true);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: DoughnutChartPackets(packetsState()),
                ),
                Expanded(
                  flex: 3,
                  child: _deviceFieldsDetails(device),
                ),
                const Divider(
                  thickness: 2,
                  indent: 10,
                  endIndent: 10,
                ),
                SpeedMonitor(mac: device.macAddress),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _deviceFieldsDetails(Device device) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProcessesCount(
              genProcesses: device.genProcesses.toString(),
              verProcesses: device.verProcesses.toString(),
            ),
            const SizedBox(height: 5),
            DeviceDetailsSection(
              context: context,
              device: device,
            ),
          ],
        ),
      );
}

class ProcessesCount extends StatelessWidget {
  const ProcessesCount({
    super.key,
    required this.genProcesses,
    required this.verProcesses,
  });

  final String genProcesses;
  final String verProcesses;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: const Icon(MaterialCommunityIcons.progress_upload,
                      semanticLabel: 'Processes', size: 30),
                ),
                color: uploadColor,
                tooltip: 'Generating Processes',
                onPressed: () {},
              ),
              Text(
                genProcesses,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(MaterialCommunityIcons.progress_check,
                    semanticLabel: 'Processes', size: 30),
                color: downloadColor,
                tooltip: 'Verifying Processes',
                onPressed: () {},
              ),
              Text(
                verProcesses,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DeviceDetailsSection extends StatelessWidget {
  const DeviceDetailsSection({
    super.key,
    required this.context,
    required this.device,
  });

  final BuildContext context;
  final Device device;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          horizontalTitleGap: 5,
          minVerticalPadding: 0,
          dense: true,
          child: Column(
            children: [
              NameAndAddress(context: context, device: device),
              MacAddress(macAddress: device.macAddress),
              if (device.location.isNotEmpty) Location(device: device),
              const SizedBox(height: 10),
              Description(device: device),
            ],
          ),
        ),
      ),
    );
  }
}

class Description extends StatelessWidget {
  const Description({
    super.key,
    required this.device,
  });

  final Device device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        textAlign: TextAlign.left,
        ((device.description.isEmpty) ? 'No Description' : device.description),
      ),
    );
  }
}

class Location extends StatelessWidget {
  const Location({
    super.key,
    required this.device,
  });

  final Device device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        MaterialCommunityIcons.map_marker,
      ),
      title: Text(
        device.location,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class NameAndAddress extends StatelessWidget {
  const NameAndAddress({
    super.key,
    required this.context,
    required this.device,
  });

  final BuildContext context;
  final Device device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          getDeviceIcon(device.name),
          color: deviceStatusColorScheme(device.status),
        ),
        tooltip:
            '${deviceStatusToString(device.status)}: ${timeago.format(device.lastUpdated!)}',
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Device is ${deviceStatusToString(device.status)}'),
                content: Text('Last updated: ${device.lastUpdated}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              );
            },
          );
        },
      ),
      title: Text(
        device.name.isNotEmpty ? device.name : device.ipAddress,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${device.ipAddress} : ${device.port}',
      ),
    );
  }
}

class SpeedMonitor extends StatefulWidget {
  const SpeedMonitor({
    required this.mac,
    super.key,
  });

  final String mac;

  @override
  State<SpeedMonitor> createState() => _SpeedMonitorState();
}

class _SpeedMonitorState extends State<SpeedMonitor> {
  @override
  Widget build(BuildContext context) {
    int upload = 0;
    int download = 0;

    VerifierStatisticsInstance? verInfo = context
        .watch<StatisticsController>()
        .getVerifierStatistics
        .lastWhereOrNull((element) => element.macAddress == widget.mac);
    upload = verInfo != null ? verInfo.packetsCorrect : 0;

    GeneratorStatisticsInstance? genInfo = context
        .watch<StatisticsController>()
        .getGeneratorStatistics
        .lastWhereOrNull((element) => element.macAddress == widget.mac);

    download = genInfo != null ? genInfo.packetsSent : 0;

    return getUploadDownload(upload, download);
  }

  Row getUploadDownload(int upload, int download) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              const FaIcon(FontAwesomeIcons.caretUp,
                  color: uploadColor, size: 35.0),
              SizedBox(
                child: Text(
                  '$upload MB/s',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            children: <Widget>[
              const FaIcon(FontAwesomeIcons.caretDown,
                  color: downloadColor, size: 35.0),
              SizedBox(
                child: Text(
                  '$download MB/s',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DevicePinger extends StatefulWidget {
  const DevicePinger({super.key, required this.mac});

  final String mac;
  @override
  State<DevicePinger> createState() => _DevicePingerState();
}

class _DevicePingerState extends State<DevicePinger> {
  bool? _isPinged;
  bool _isPinging = false;
  _pingDevice() async {
    setState(() {
      _isPinging = true;
    });

    bool? success =
        await context.read<DevicesController>().pingDevice(widget.mac);
    _isPinged = success;
    _isPinging = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Visibility(
        visible: !_isPinging,
        replacement: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: LoadingAnimationWidget.beat(
            color: Colors.lightBlueAccent,
            size: 20.0,
          ),
        ),
        child: IconButton(
          icon: const Icon(
            MaterialCommunityIcons.wifi_sync,
            size: 20,
          ),
          onPressed: () => _pingDevice(),
          tooltip: _isPinged == null
              ? 'Ping Device'
              : _isPinged!
                  ? 'Device is Online'
                  : 'Device is Offline',
          color: _isPinged == null
              ? Colors.lightBlueAccent
              : _isPinged!
                  ? deviceStatusColorScheme(DeviceStatus.online)
                  : deviceStatusColorScheme(DeviceStatus.offline),
        ),
      ),
    );
  }
}

class MacAddress extends StatefulWidget {
  const MacAddress({super.key, required this.macAddress});

  final String macAddress;
  @override
  State<MacAddress> createState() => _MacAddressState();
}

class _MacAddressState extends State<MacAddress> {
  bool macIsShown = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        MaterialCommunityIcons.ethernet,
      ),
      title: Visibility(
        visible: macIsShown,
        replacement: IconButton(
          icon: const Icon(
            MaterialCommunityIcons.lock,
          ),
          color: Colors.red,
          tooltip: 'Show MAC Address',
          onPressed: () {
            macIsShown = true;
            setState(() {});
          },
        ),
        child: Text(
          widget.macAddress,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
