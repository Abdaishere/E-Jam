import 'dart:async';
import 'dart:math';

import 'package:circular_motion/circular_motion.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_device_view.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
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
  Set<String> devices = {};
  Timer? timer;
  bool _isPinging = false;

  _radar() {
    setState(() {
      _isPinging = true;
    });
    int port = SystemSettings.defaultDevicesPort;
    String systemApiSubnet = SystemSettings.defaultSystemApiSubnet;

    try {
      // ping all devices in the network in the same port
      final stream = NetworkAnalyzer.discover2(systemApiSubnet, port,
          timeout: const Duration(milliseconds: 2000));
      stream.listen((NetworkAddress addr) {
        if (addr.exists && mounted) {
          if (DevicesController.devices
                  ?.indexWhere((element) => element.ipAddress == addr.ip) !=
              -1) {
            return;
          }

          devices.add(addr.ip);
          setState(() {});
        }
      });
    } catch (e) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Error while scanning devices: $e')));
    }
    if (mounted) {
      setState(() {
        _isPinging = false;
      });
    }
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
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? const EdgeInsets.all(100)
          : const EdgeInsets.all(20),
      child: Hero(
        tag: 'radar',
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: GestureDetector(
          onDoubleTap: () {
            Navigator.of(context).pop();
          },
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
                    return _deviceIcon(index);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _deviceIcon(int index) {
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
            color: deviceIdleColor,
            tooltip:
                'Add ${devices.elementAt(index)}:${SystemSettings.defaultDevicesPort}',
            onPressed: () {
              Navigator.of(context).push(
                HeroDialogRoute(
                  builder: (BuildContext context) => Center(
                    child: AddDeviceView(
                      refresh: () => widget.loadDevicesListView(),
                      ip: devices.elementAt(index),
                      delete: () => {
                        if (mounted)
                          {
                            devices.remove(devices.elementAt(index)),
                            setState(() {})
                          }
                      },
                    ),
                  ),
                  settings: const RouteSettings(name: 'AddDeviceView'),
                ),
              );
            },
          ),
          Text(
            devices.elementAt(index),
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
