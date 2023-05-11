import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RequestStatusIcon extends StatelessWidget {
  const RequestStatusIcon({
    super.key,
    required this.status,
    required this.message,
  });

  final int status;
  final String message;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: message,
      icon: FaIcon(
        getIcon(status),
        color: getColor(status),
        size: 20.0,
      ),
      onPressed: () {},
    );
  }

  IconData getIcon(int status) {
    if (status < 300) {
      return FontAwesomeIcons.circleCheck;
    }
    if (status < 400) {
      return FontAwesomeIcons.circleInfo;
    }
    if (status < 500) {
      return FontAwesomeIcons.circleExclamation;
    }
    return FontAwesomeIcons.circleXmark;
  }

  Color getColor(int status) {
    if (status < 300) {
      return Colors.green;
    }
    if (status < 400) {
      return Colors.blue;
    }
    if (status < 500) {
      return Colors.orange;
    }
    return Colors.red;
  }
}
