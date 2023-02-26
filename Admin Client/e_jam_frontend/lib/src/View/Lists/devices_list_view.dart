import 'dart:math';

import 'package:e_jam/main.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_device_view.dart';
import 'package:e_jam/src/View/Details_Views/device_details_view.dart';
import 'package:e_jam/src/View/Lists/streams_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DevicesListView extends StatelessWidget {
  const DevicesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devices',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const DrawerWidget(),
        actions: <Widget>[
          // refresh icon for refreshing the Devices list view
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onPressed: () {},
          ),
          // gear icon for settings and preferences related to the Devices list view (sort by, filter by, etc.)
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear),
            onPressed: () {},
          ),
          // Explaination icon for details about how the Device card works and what the icons mean and what the colors mean
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleQuestion),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8.0),
            shrinkWrap: true,
            itemCount: 10,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  max(MediaQuery.of(context).copyWith().size.width ~/ 200.0, 1),
              childAspectRatio: 2 / 3,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 3.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return DeviceCard(index);
            },
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
}

class AddDeviceButton extends StatefulWidget {
  const AddDeviceButton({super.key});

  @override
  State<AddDeviceButton> createState() => _AddDeviceButtonState();
}

class _AddDeviceButtonState extends State<AddDeviceButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Add Device',
      heroTag: 'addDevice',
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
      backgroundColor: Colors.deepOrangeAccent,
      mini: true,
      child: const FaIcon(FontAwesomeIcons.plus),
    );
  }
}

class DeviceCard extends StatefulWidget {
  const DeviceCard(this.index, {super.key});

  final int index;
  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) =>
                Center(child: DevicesDetailsView(index)),
            settings: const RouteSettings(name: 'DevicesDetailsView'),
          ),
        );
      },
      child: Hero(
        tag: 'device$index',
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'New Device',
                      icon: const FaIcon(
                        Icons.new_releases,
                        color: Colors.blueAccent,
                        size: 20.0,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('This is a new device!'),
                              content: const Text(
                                  'This is a new device, you can add it to a Stream in System\'s Streams list.'),
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
                    const FaIcon(
                      // should be a device icon (like a server icon) but for now it's a server icon
                      FontAwesomeIcons.server,
                      // should be the color of the devices status (red for offline, orange for ideal)
                      color: Colors.deepOrangeAccent,
                      size: 35.0,
                    ),
                    PopupMenuButton(
                      tooltip: 'More Options',
                      icon: const FaIcon(
                        Icons.more_vert,
                        size: 20.0,
                      ),
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
                                Icon(MaterialCommunityIcons.pencil,
                                    color: Colors.green),
                                SizedBox(width: 10.0),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Delete',
                            child: Row(
                              children: const [
                                FaIcon(MaterialCommunityIcons.trash_can,
                                    color: Colors.red),
                                SizedBox(width: 10.0),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Device Name',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Device Status',
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Device Location',
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Device Description',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
