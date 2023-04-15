import 'dart:math';

import 'package:circular_motion/circular_motion.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class DevicesRadarCardView extends StatefulWidget {
  const DevicesRadarCardView({super.key, required this.loadDevicesListView});

  final Function loadDevicesListView;
  @override
  State<DevicesRadarCardView> createState() => _DevicesRadarCardViewState();
}

class _DevicesRadarCardViewState extends State<DevicesRadarCardView> {
  Set<String> devices = {'1.1.1.1'};

  _radar() {
    // NetworkController.defaultDevicesPort as int;
    int port = 8080;
    String systemApiSubnet = NetworkController.defaultSystemApiSubnet;
    // ping all devices in the network in the same port
    final stream = NetworkAnalyzer.discover2(systemApiSubnet, port,
        timeout: const Duration(milliseconds: 500));

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}:$port');
        setState(
          () {
            devices.add(addr.ip);
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'radar',
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
                : 0.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Devices Radar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularMotion(
                centerWidget: IconButton(
                  icon: const Icon(MaterialCommunityIcons.radar,
                      size: 50, color: Colors.blue),
                  onPressed: () {
                    _radar();
                  },
                ),
                children: [
                  for (int i = 0; i < devices.length; i++)
                    Transform.rotate(
                      angle: i * pi / 2,
                      child: IconButton(
                        icon: const Icon(MaterialCommunityIcons.help_network,
                            size: 50),
                        onPressed: () {
                          widget.loadDevicesListView();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
