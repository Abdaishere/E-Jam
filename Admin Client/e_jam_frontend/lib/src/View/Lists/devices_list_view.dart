import 'dart:math';

import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_device_view.dart';
import 'package:e_jam/src/View/Details_Views/device_details_view.dart';
import 'package:e_jam/src/View/Details_Views/edit_device_view.dart';
import 'package:e_jam/src/controller/devives_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class DevicesListView extends StatefulWidget {
  const DevicesListView({super.key});

  @override
  State<DevicesListView> createState() => _DevicesListViewState();
}

class _DevicesListViewState extends State<DevicesListView> {
  get scaffoldMessenger => ScaffoldMessenger.of(context);
  get controllerDeviceDetails => DevicesController.devices;
  get controllerIsDeviceListLoading => DevicesController.isLoading;

  List<Device>? devices;
  bool isDeviceListLoading = true;

  void loadDevicesListView() async {
    setState(() {
      isDeviceListLoading = true;
    });

    DevicesController.loadAllDevices(scaffoldMessenger).then(
      (value) => {
        setState(() {
          devices = controllerDeviceDetails;
          isDeviceListLoading = controllerIsDeviceListLoading;
        })
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => loadDevicesListView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: devicesListViewAppBar(),
      body: Stack(
        children: [
          Visibility(
            visible: !isDeviceListLoading,
            replacement: Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.grey,
                size: 70.0,
              ),
            ),
            child: Visibility(
              child: Visibility(
                visible: devices != null && devices!.isNotEmpty,
                replacement: Visibility(
                  visible: devices != null && devices!.isEmpty,
                  replacement: Stack(
                    children: const [
                      Center(
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 100.0,
                        ),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.computer,
                          size: 100.0,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'No Devices Found',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  itemCount: devices?.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: max(
                        MediaQuery.of(context).copyWith().size.width ~/ 200.0,
                        1),
                    childAspectRatio: 2 / 3,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 3.0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return DeviceCard(
                        device: devices![index],
                        refresh: () {
                          loadDevicesListView();
                        });
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(right: 35.0, bottom: 30.0),
              child: AddDeviceButton(
                reload: () {
                  loadDevicesListView();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar devicesListViewAppBar() {
    return AppBar(
      title: const Text(
        'Devices',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: const DrawerWidget(),
      actions: <Widget>[
        // refresh icon for refreshing the Devices list view
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 20.0),
          onPressed: () {
            loadDevicesListView();
          },
        ),
        // gear icon for settings and preferences related to the Devices list view (sort by, filter by, etc.)
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.gear, size: 20.0),
          onPressed: () {
            // TODO: Add a dialog box for settings and preferences related to the Devices list view (sort by, filter by, etc.)
          },
        ),
        // Explaination icon for details about how the Device card works and what the icons mean and what the colors mean
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.circleQuestion, size: 20.0),
          onPressed: () {
            // TODO: Add a dialog box for explaining the Device card
          },
        ),
      ],
    );
  }
}

class AddDeviceButton extends StatelessWidget {
  const AddDeviceButton({super.key, required this.reload});

  final Function() reload;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Add Device',
      heroTag: 'addDevice',
      backgroundColor: Colors.deepOrangeAccent,
      mini: true,
      onPressed: () {
        Navigator.of(context).push(
          // Center from here not from the card
          HeroDialogRoute(
            builder: (BuildContext context) =>
                Center(child: AddDeviceView(reload: () => reload())),
            settings: const RouteSettings(name: 'AddDeviceView'),
          ),
        );
      },
      child: const FaIcon(FontAwesomeIcons.plus),
    );
  }
}

class DeviceCard extends StatefulWidget {
  const DeviceCard({super.key, required this.device, required this.refresh});

  final Device device;
  final Function() refresh;

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  Device? updateDevice;

  void reload() {
    DevicesController.loadDeviceDetails(
            ScaffoldMessenger.of(context), widget.device.macAddress)
        .then(
      (value) => {
        setState(() {
          updateDevice = value;
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Device device = updateDevice ?? widget.device;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) =>
                Center(child: DevicesDetailsView(device: device)),
            settings: const RouteSettings(name: 'DevicesDetailsView'),
          ),
        );
      },
      child: Hero(
        tag: device.macAddress,
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusIconButton(
                      status: device.status,
                      mac: device.macAddress,
                      lastUpdated: device.lastUpdated,
                    ),
                    _deviceIcon(status: device.status, name: device.name),
                    _popupMenuList(context, device),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  device.ipAddress,
                ),
                Text(
                  device.location,
                ),
                Text(
                  device.description,
                ),
                _deviceProcesses(device),
                Text(
                  deviceStatusToString(device.status),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _deviceProcesses(Device device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: const Icon(MaterialCommunityIcons.progress_upload,
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
    );
  }

  PopupMenuButton<String> _popupMenuList(BuildContext context, Device device) {
    return PopupMenuButton(
      tooltip: 'More Options',
      icon: const FaIcon(
        Icons.more_vert,
        size: 20.0,
      ),
      onSelected: (dynamic value) {
        if (value == 'View') {
          Navigator.of(context).push(
            HeroDialogRoute(
              builder: (BuildContext context) =>
                  Center(child: DevicesDetailsView(device: device)),
              settings: const RouteSettings(name: 'StreamDetailsView'),
            ),
          );
        } else if (value == 'Delete') {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete Stream'),
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
                    DevicesController.deleteDevice(
                            ScaffoldMessenger.of(context), device.macAddress)
                        .then((success) => {if (success) widget.refresh()});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          );
        } else if (value == 'Edit') {
          Navigator.of(context).push(
            HeroDialogRoute(
              builder: (BuildContext context) => Center(
                  child:
                      EditDeviceView(mac: device.macAddress, refresh: reload)),
              settings: const RouteSettings(name: 'EditDeviceView'),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'View',
            child: Row(
              children: const [
                Icon(MaterialCommunityIcons.view_carousel,
                    color: Colors.blueAccent),
                SizedBox(width: 10.0),
                Text('View'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'Edit',
            child: Row(
              children: const [
                Icon(MaterialCommunityIcons.pencil, color: Colors.green),
                SizedBox(width: 10.0),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'Delete',
            child: Row(
              children: const [
                FaIcon(MaterialCommunityIcons.trash_can, color: Colors.red),
                SizedBox(width: 10.0),
                Text('Delete'),
              ],
            ),
          ),
        ];
      },
    );
  }

  Icon _deviceIcon({required String name, required DeviceStatus status}) {
    return Icon(
      getDeviceIcon(name),
      color: deviceColorScheme(status),
      size: 50.0,
    );
  }

  IconData getDeviceIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('server')) {
      return MaterialCommunityIcons.server;
    } else if (name.contains('raspberry') || name.contains('pi')) {
      return MaterialCommunityIcons.raspberry_pi;
    } else if (name.contains('mac') || name.contains('apple')) {
      return MaterialCommunityIcons.apple;
    } else if (name.contains('linux')) {
      return MaterialCommunityIcons.linux;
    } else if (name.contains('windows')) {
      return MaterialCommunityIcons.microsoft_windows;
    } else if (name.contains('localhost')) {
      return MaterialCommunityIcons.home_variant;
    } else if (name.contains('pc')) {
      return MaterialCommunityIcons.desktop_mac;
    } else if (name.contains('laptop')) {
      return MaterialCommunityIcons.laptop;
    } else if (name.contains('printer')) {
      return MaterialCommunityIcons.printer;
    } else if (name.contains('hub') || name.contains('switch')) {
      return MaterialCommunityIcons.hubspot;
    } else if (name.contains('router')) {
      return MaterialCommunityIcons.router_network;
    } else if (name.contains('security')) {
      return MaterialCommunityIcons.security_network;
    }
    return MaterialCommunityIcons.chip;
  }
}

class StatusIconButton extends StatelessWidget {
  const StatusIconButton({
    super.key,
    required this.status,
    required this.mac,
    required this.lastUpdated,
  });

  final DeviceStatus status;
  final String mac;
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip:
          '${deviceStatusToString(status)}: ${timeago.format(lastUpdated)}',
      icon: FaIcon(
        getIcon(status),
        color: deviceColorScheme(status),
        size: 20.0,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Device is ${deviceStatusToString(status)}'),
              content: Text('Last updated: $lastUpdated'),
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
    );
  }

  IconData getIcon(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return MaterialCommunityIcons.circle_double;
      case DeviceStatus.offline:
        return MaterialCommunityIcons.progress_close;
      case DeviceStatus.idle:
        return MaterialCommunityIcons.progress_question;
      case DeviceStatus.running:
        return MaterialCommunityIcons.progress_star;
      default:
        return MaterialCommunityIcons.progress_close;
    }
  }
}
