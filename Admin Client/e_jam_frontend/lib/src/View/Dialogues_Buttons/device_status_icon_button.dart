import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class DeviceStatusIconButton extends StatelessWidget {
  const DeviceStatusIconButton(
      {super.key,
      required this.status,
      required this.lastUpdated,
      required this.mac,
      required this.isDense});

  final DeviceStatus status;
  final DateTime lastUpdated;
  final bool isDense;
  final String mac;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: isDense ? EdgeInsets.zero : null,
      constraints: isDense ? const BoxConstraints() : null,
      tooltip:
          '${deviceStatusToString(status)}: ${timeago.format(lastUpdated)}',
      icon: FaIcon(
        getIcon(status),
        color: deviceStatusColorScheme(status),
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

IconData getDeviceIcon(String name) {
  name = name.toLowerCase();
  if (name.contains('chip') || name.contains('pine64')) {
    return MaterialCommunityIcons.chip;
  } else if (name.contains('raspberry') || name.contains('pi')) {
    return MaterialCommunityIcons.raspberry_pi;
  } else if (name.contains('mac') || name.contains('apple')) {
    return MaterialCommunityIcons.apple;
  } else if (name.contains('linux')) {
    return MaterialCommunityIcons.linux;
  } else if (name.contains('windows') || name.contains('microsoft')) {
    return MaterialCommunityIcons.microsoft_windows;
  } else if (name.contains('localhost') || name.contains('home')) {
    return MaterialCommunityIcons.home_variant;
  } else if (name.contains('pc') || name.contains('desktop')) {
    return MaterialCommunityIcons.desktop_mac;
  } else if (name.contains('laptop') || name.contains('notebook')) {
    return MaterialCommunityIcons.laptop;
  } else if (name.contains('printer')) {
    return MaterialCommunityIcons.printer;
  } else if (name.contains('hub')) {
    return MaterialCommunityIcons.hubspot;
  } else if (name.contains('router') || name.contains('switch')) {
    return MaterialCommunityIcons.router_network;
  } else if (name.contains('security') || name.contains('firewall')) {
    return MaterialCommunityIcons.security_network;
  }
  return MaterialCommunityIcons.server;
}
