import 'dart:math';

import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_device_view.dart';
import 'package:e_jam/src/View/Details_Views/device_details_view.dart';
import 'package:e_jam/src/View/Details_Views/edit_device_view.dart';
import 'package:e_jam/src/View/Dialogues/device_status_icon_button.dart';
import 'package:e_jam/src/View/devices_radar_card_view.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class DevicesListView extends StatefulWidget {
  const DevicesListView({super.key});

  @override
  State<DevicesListView> createState() => _DevicesListViewState();
}

class _DevicesListViewState extends State<DevicesListView> {
  bool _isPinging = false;
  bool? _isPinged;

  void _pingAll() async {
    _isPinging = true;
    setState(() {});
    await context.read<DevicesController>().pingAllDevices().then(
          (value) => {
            if (mounted)
              {
                _isPinging = false,
                _isPinged = value,
                context.read<DevicesController>().loadAllDevices(),
              }
          },
        );
  }

  @override
  void initState() {
    super.initState();
    context.read<DevicesController>().loadAllDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: devicesListViewAppBar(),
      body: Stack(
        children: [
          Visibility(
            visible: !context.watch<DevicesController>().getIsLoading,
            replacement: Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.grey,
                size: 70.0,
              ),
            ),
            child: Visibility(
              child: Visibility(
                visible: context.watch<DevicesController>().getDevices !=
                        null &&
                    context.watch<DevicesController>().getDevices!.isNotEmpty,
                replacement: Visibility(
                  visible: context.watch<DevicesController>().getDevices !=
                          null &&
                      context.watch<DevicesController>().getDevices!.isEmpty,
                  replacement: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 100.0,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                  itemCount:
                      context.watch<DevicesController>().getDevices?.length,
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
                      device:
                          context.watch<DevicesController>().getDevices![index],
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(right: 35.0, bottom: 30.0),
              child: const AddDeviceButton(),
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
        Hero(
          tag: 'radar',
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: IconButton(
            icon: const Icon(
              MaterialCommunityIcons.radar,
              size: 20,
            ),
            color: Colors.lime.shade500,
            tooltip: 'Radar',
            onPressed: () {
              Navigator.of(context).push(
                HeroDialogRoute(
                  builder: (BuildContext context) => const Center(
                    child: DevicesRadarCardView(),
                  ),
                  settings: const RouteSettings(name: 'radar'),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Visibility(
            visible: !_isPinging,
            replacement: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LoadingAnimationWidget.beat(
                color: Colors.lightBlue.shade300,
                size: 20.0,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                MaterialCommunityIcons.wifi_sync,
                size: 20,
              ),
              onPressed: _pingAll,
              tooltip: _isPinged == null
                  ? 'Ping devices'
                  : _isPinged!
                      ? 'some Devices are online'
                      : 'All Devices offline',
              color: _isPinged == null
                  ? Colors.lightBlue.shade300
                  : _isPinged!
                      ? deviceRunningOrOnlineColor
                      : deviceOfflineOrErrorColor,
            ),
          ),
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowsRotate,
            size: 20.0,
          ),
          tooltip: 'Refresh',
          onPressed: () => context.read<DevicesController>().loadAllDevices(),
        ),
        // Explanation icon for details about how the Device card works and what the icons mean and what the colors mean
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.circleQuestion, size: 20.0),
          tooltip: 'Help',
          onPressed: () {
            // TODO: Add a dialog box for explaining the Device card
          },
        ),
      ],
    );
  }
}

class AddDeviceButton extends StatelessWidget {
  const AddDeviceButton({super.key});

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
                const Center(child: AddDeviceView()),
            settings: const RouteSettings(name: 'AddDeviceView'),
          ),
        );
      },
      child: const FaIcon(FontAwesomeIcons.plus),
    );
  }
}

class DeviceCard extends StatefulWidget {
  const DeviceCard({super.key, required this.device});

  final Device device;

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  Device? updateDevice;

  void refresh() {
    context
        .read<DevicesController>()
        .loadDeviceDetails(widget.device.macAddress)
        .then(
          (value) => {
            if (mounted) {updateDevice = value, setState(() {})}
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
            builder: (BuildContext context) => Center(
                child: DevicesDetailsView(
              device: device,
            )),
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
                    DeviceStatusIconButton(
                      status: device.status ?? DeviceStatus.offline,
                      mac: device.macAddress,
                      lastUpdated: device.lastUpdated ?? DateTime.now(),
                      isDense: false,
                    ),
                    _deviceIcon(
                        status: device.status ?? DeviceStatus.offline,
                        name: device.name),
                    _popupMenuList(context, device),
                  ],
                ),
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  device.ipAddress,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  device.location,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  device.description,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(),
                _deviceProcesses(device),
                Text(
                  deviceStatusToString(device.status ?? DeviceStatus.offline),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
              builder: (BuildContext context) => Center(
                child: DevicesDetailsView(
                  device: device,
                ),
              ),
              settings: const RouteSettings(name: 'DevicesDetailsView'),
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
                    context
                        .read<DevicesController>()
                        .deleteDevice(device.macAddress)
                        .then((success) => {
                              if (success && mounted)
                                context
                                    .read<DevicesController>()
                                    .loadAllDevices()
                            });
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
                child: EditDeviceView(
                  mac: device.macAddress,
                  refresh: refresh,
                  device: device,
                ),
              ),
              settings: const RouteSettings(name: 'EditDeviceView'),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: 'View',
            child: Row(
              children: [
                Icon(MaterialCommunityIcons.view_carousel,
                    color: Colors.blueAccent),
                SizedBox(width: 10.0),
                Text('View'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'Edit',
            child: Row(
              children: [
                Icon(MaterialCommunityIcons.pencil, color: Colors.green),
                SizedBox(width: 10.0),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: Row(
              children: [
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
      color: deviceStatusColorScheme(status),
      size: 50.0,
    );
  }
}
