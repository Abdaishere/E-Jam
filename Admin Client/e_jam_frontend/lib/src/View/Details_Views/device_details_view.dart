import 'dart:math';
import 'dart:ui';

import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Details_Views/edit_device_view.dart';
import 'package:e_jam/src/View/Lists/devices_list_view.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class DevicesDetailsView extends StatefulWidget {
  const DevicesDetailsView(
      {super.key, required this.device, required this.loadDevicesListView});

  final Device device;
  final Function loadDevicesListView;
  @override
  State<DevicesDetailsView> createState() => _DevicesDetailsViewState();
}

class _DevicesDetailsViewState extends State<DevicesDetailsView> {
  Device? updateDevice;
  bool macIsShown = false;
  bool? _isPinged;
  bool _isPinging = false;

  _pingDevice() async {
    setState(() {
      _isPinging = true;
    });
    DevicesController.pingDevice(widget.device.macAddress).then(
      (value) => setState(
        () {
          _isPinged = value;
          _isPinging = false;
        },
      ),
    );
  }

  void refresh() {
    DevicesController.loadDeviceDetails(widget.device.macAddress).then(
      (value) => {
        widget.loadDevicesListView(),
        setState(() {
          updateDevice = value;
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Device device = updateDevice ?? widget.device;
    return Hero(
      tag: device.macAddress,
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
                : 0.4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Device ${device.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
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
                              ? deviceRunningOrOnlineColor
                              : deviceOfflineOrErrorColor,
                    ),
                  ),
                ),
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
                            onPressed: () {
                              DevicesController.deleteDevice(device.macAddress)
                                  .then(
                                (value) {
                                  if (value) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    widget.loadDevicesListView();
                                  }
                                },
                              );
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 3,
                  child: DoughnutChartPackets(packetsState),
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
                _progressDeviceDetails(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        icon: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(pi),
                          child: const Icon(
                              MaterialCommunityIcons.progress_upload,
                              semanticLabel: 'Processes'),
                        ),
                        color: uploadColor,
                        tooltip: 'Generating Processes',
                        onPressed: () {},
                      ),
                      Text(
                        device.genProcesses.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        semanticsLabel: 'Number of Processes',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(MaterialCommunityIcons.progress_check,
                            semanticLabel: 'Processes'),
                        color: downloadColor,
                        tooltip: 'Verifying Processes',
                        onPressed: () {},
                      ),
                      Text(
                        device.verProcesses.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        semanticsLabel: 'Number of Processes',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _deviceDetailsSection(device),
          ],
        ),
      );

  Expanded _deviceDetailsSection(Device device) {
    return Expanded(
      child: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          horizontalTitleGap: 5,
          minVerticalPadding: 0,
          child: Column(
            children: [
              ListTile(
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
                          title: Text(
                              'Device is ${deviceStatusToString(device.status)}'),
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
                  device.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  '${device.ipAddress} : ${device.port}',
                ),
              ),
              ListTile(
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
                      setState(() {
                        macIsShown = true;
                      });
                    },
                  ),
                  child: Text(
                    device.macAddress,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
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
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  textAlign: TextAlign.left,
                  device.description,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _progressDeviceDetails() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Column(
              children: const <Widget>[
                FaIcon(FontAwesomeIcons.caretUp, color: uploadColor),
                Text(
                  '987654321MB/s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: const <Widget>[
                FaIcon(FontAwesomeIcons.caretDown, color: downloadColor),
                Text(
                  '987654321MB/s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    letterSpacing: 1.0,
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
