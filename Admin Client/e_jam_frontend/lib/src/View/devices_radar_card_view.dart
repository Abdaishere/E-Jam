import 'dart:async';
import 'dart:math';

import 'package:circular_motion/circular_motion.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_device_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ripple/flutter_ripple.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class DevicesRadarCardView extends StatefulWidget {
  const DevicesRadarCardView({super.key, required this.loadDevicesListView});

  final Function loadDevicesListView;
  @override
  State<DevicesRadarCardView> createState() => _DevicesRadarCardViewState();
}

class _DevicesRadarCardViewState extends State<DevicesRadarCardView> {
  Set<String> devices = {'127.0.0.1'};
  Timer? timer;
  bool _isPinging = false;

  _radar() {
    setState(() {
      _isPinging = true;
    });
    // NetworkController.defaultDevicesPort as int;
    int port = NetworkController.defaultDevicesPort;
    String systemApiSubnet = NetworkController.defaultSystemApiSubnet;
    try {
      // ping all devices in the network in the same port
      final stream = NetworkAnalyzer.discover2(systemApiSubnet, port,
          timeout: const Duration(milliseconds: 1000));

      stream.listen((NetworkAddress addr) {
        if (addr.exists) {
          setState(
            () {
              devices.add(addr.ip);
            },
          );
        }
      });
      setState(() {
        _isPinging = false;
      });
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _radar();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => _radar());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'radar',
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: SizedBox(
        height: (MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : min(MediaQuery.of(context).size.height, 400)),
        width: (MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : min(MediaQuery.of(context).size.width, 400)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Devices Radar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularMotion.builder(
                centerWidget: FlutterRipple(
                  onTap: () {
                    _radar();
                  },
                  child: Visibility(
                    visible: !_isPinging,
                    replacement: LoadingAnimationWidget.beat(
                      size: 60,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.refresh,
                      size: 50,
                    ),
                  ),
                ),
                itemCount: devices.length,
                builder: (context, index) {
                  return SizedBox(
                    height: 100,
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.device_hub),
                          iconSize: 50,
                          tooltip:
                              'Add ${devices.elementAt(index)}:${NetworkController.defaultDevicesPort}',
                          onPressed: () {
                            Navigator.of(context).push(
                              HeroDialogRoute(
                                builder: (BuildContext context) => Center(
                                    child: AddDeviceView(
                                        refresh: () =>
                                            widget.loadDevicesListView(),
                                        ip: devices.elementAt(index))),
                                settings:
                                    const RouteSettings(name: 'AddDeviceView'),
                              ),
                            );
                          },
                        ),
                        Text(
                          devices.elementAt(index),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
