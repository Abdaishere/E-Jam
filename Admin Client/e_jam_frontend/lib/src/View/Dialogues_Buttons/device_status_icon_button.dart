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

// List of keywords to match with device name to get the icon
const Map<String, IconData> _nameKeywords = {
  'chip': MaterialCommunityIcons.chip,
  'pine64': MaterialCommunityIcons.chip,
  'raspberry': MaterialCommunityIcons.raspberry_pi,
  'pi': MaterialCommunityIcons.raspberry_pi,
  'mac': MaterialCommunityIcons.apple,
  'apple': MaterialCommunityIcons.apple,
  'linux': MaterialCommunityIcons.linux,
  'windows': MaterialCommunityIcons.microsoft_windows,
  'microsoft': MaterialCommunityIcons.microsoft_windows,
  'localhost': MaterialCommunityIcons.home_variant,
  'home': MaterialCommunityIcons.home_variant,
  'pc': MaterialCommunityIcons.desktop_mac,
  'desktop': MaterialCommunityIcons.desktop_mac,
  'laptop': MaterialCommunityIcons.laptop,
  'notebook': MaterialCommunityIcons.laptop,
  'printer': MaterialCommunityIcons.printer,
  'hub': MaterialCommunityIcons.hubspot,
  'router': MaterialCommunityIcons.router_network,
  'switch': MaterialCommunityIcons.router_network,
  'security': MaterialCommunityIcons.security_network,
  'firewall': MaterialCommunityIcons.security_network,
};

IconData getDeviceIcon(String name) {
  name = name.toLowerCase();
  for (String keyword in _nameKeywords.keys) {
    if (name.contains(keyword)) {
      return _nameKeywords[keyword]!;
    }
  }
  return MaterialCommunityIcons.server;
}
