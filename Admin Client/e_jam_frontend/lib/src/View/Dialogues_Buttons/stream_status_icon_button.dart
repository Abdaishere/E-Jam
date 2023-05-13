import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class StreamStatusIconButton extends StatelessWidget {
  const StreamStatusIconButton(
      {super.key,
      required this.status,
      required this.id,
      required this.lastUpdated,
      required this.refresh,
      required this.isDense});

  final StreamStatus status;
  final String id;
  final DateTime lastUpdated;
  final Function refresh;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    if (status == StreamStatus.created) {
      return IconButton(
        padding: isDense ? EdgeInsets.zero : null,
        constraints: isDense ? const BoxConstraints() : null,
        tooltip: 'New Stream',
        icon: FaIcon(
          Icons.new_releases,
          color: streamColorScheme(status),
          size: 20.0,
        ),
        onPressed: () {
          _newStreamDialog(context);
        },
      );
    } else {
      return IconButton(
        padding: isDense ? EdgeInsets.zero : null,
        constraints: isDense ? const BoxConstraints() : null,
        tooltip:
            '${streamStatusToString(status)}: ${timeago.format(lastUpdated)}',
        icon: FaIcon(
          getIcon(status),
          color: streamColorScheme(status),
          size: 20.0,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Stream is ${streamStatusToString(status)}'),
              content: Text('Last updated: $lastUpdated'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          );
        },
      );
    }
  }

  Future<dynamic> _newStreamDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('This stream is new!'),
        content: const Text(
            'This stream is new and has not been started yet. Would you like to start it now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StreamsController>().startStream(id).then((success) {
                refresh();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Start'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }

  IconData getIcon(StreamStatus status) {
    switch (status) {
      case StreamStatus.sent:
        return Icons.arrow_upward;
      case StreamStatus.running:
        return MaterialCommunityIcons.star_four_points;
      case StreamStatus.stopped:
        return MaterialCommunityIcons.stop_circle_outline;
      case StreamStatus.queued:
        return MaterialCommunityIcons.timer_sand;
      case StreamStatus.finished:
        return MaterialCommunityIcons.check_bold;
      case StreamStatus.error:
        return MaterialCommunityIcons.alert_circle;
      default:
        return Icons.new_releases;
    }
  }
}
