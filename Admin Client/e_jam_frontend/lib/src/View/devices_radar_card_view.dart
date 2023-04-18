import 'dart:async';
import 'dart:math';

import 'package:circular_motion/circular_motion.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_device_view.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ripple/flutter_ripple.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class DevicesRadarCardView extends StatefulWidget {
  const DevicesRadarCardView({super.key, required this.loadDevicesListView});

  final Function loadDevicesListView;
  @override
  State<DevicesRadarCardView> createState() => _DevicesRadarCardViewState();
}

class _DevicesRadarCardViewState extends State<DevicesRadarCardView> {
  Set<String> devices = {};
  Timer? timer;
  bool _isPinging = false;

  _radar() {
    setState(() {
      _isPinging = true;
    });
    int port = NetworkController.defaultDevicesPort;
    String systemApiSubnet = NetworkController.defaultSystemApiSubnet;

    // ping all devices in the network in the same port
    final stream = NetworkAnalyzer.discover2(systemApiSubnet, port,
        timeout: const Duration(milliseconds: 2000));
    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        if (DevicesController.devices
                ?.indexWhere((element) => element.ipAddress == addr.ip) !=
            -1) {
          return;
        }
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
        height: MediaQuery.of(context).size.height *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.8),
        width: MediaQuery.of(context).size.width *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.6),
        child: GestureDetector(
          onDoubleTap: () {
            Navigator.of(context).pop();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const FaIcon(FontAwesome.close,
                      size: 40, color: Colors.white70),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.lightBlueAccent.withOpacity(0.4),
                        width: 5,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: CircularMotion.builder(
                        behavior: HitTestBehavior.opaque,
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
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.device_hub_rounded),
                                  iconSize: 50,
                                  tooltip:
                                      'Add ${devices.elementAt(index)}:${NetworkController.defaultDevicesPort}',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (BuildContext context) =>
                                            Center(
                                                child: AddDeviceView(
                                                    refresh: () => widget
                                                        .loadDevicesListView(),
                                                    delete: () => {
                                                          setState(() {
                                                            devices.remove(
                                                                devices
                                                                    .elementAt(
                                                                        index));
                                                          })
                                                        },
                                                    ip: devices
                                                        .elementAt(index))),
                                        settings: const RouteSettings(
                                            name: 'AddDeviceView'),
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
            ),
          ),
        ),
      ),
    );
  }
}
