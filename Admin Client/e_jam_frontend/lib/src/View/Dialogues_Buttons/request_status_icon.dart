import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RequestStatusIcon extends StatelessWidget {
  const RequestStatusIcon({
    super.key,
    required this.response,
  });

  final Message response;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: response.message,
      icon: FaIcon(
        getIcon(response.responseCode),
        color: getColor(response.responseCode),
        size: 20.0,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Status Code ${response.responseCode}'),
              content: Text('Info: ${response.message}'),
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

class Message {
  const Message({
    required this.responseCode,
    required this.message,
  });
  final int responseCode;
  final String message;
}
