import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StreamsStartStopControllerButtons extends StatefulWidget {
  const StreamsStartStopControllerButtons(
      {super.key, required this.isStopping});

  final bool isStopping;
  @override
  State<StreamsStartStopControllerButtons> createState() =>
      _StreamsStartStopControllerButtonsState();
}

class _StreamsStartStopControllerButtonsState
    extends State<StreamsStartStopControllerButtons> {
  bool _success = true;

  void _toggleStreams() async {
    if (widget.isStopping) {
      setState(() {});
      context.read<StreamsController>().stopAllStreams().then(
        (value) async {
          if (mounted) {
            _success = value;
            setState(() {});
          }
        },
      );
    } else {
      setState(() {});
      context.read<StreamsController>().startAllStreams().then(
        (value) async {
          if (mounted) {
            _success = value;
            setState(() {});
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: (widget.isStopping) ? 'Pause' : 'Start',
      onPressed: () => {
        // show warning dialog for starting/stopping streams
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              (widget.isStopping) ? 'Pause Streams' : 'Start Streams',
            ),
            content: Text(
              (widget.isStopping)
                  ? 'This action will stop ALL streams including queued ones. Some services may not be available during the process. \nAre you sure you want to pause all streams?'
                  : 'This action is performance INTENSIVE. Some services may not be available during the process. \nAre you sure you want to start all streams?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                ),
              ),
              TextButton(
                onPressed: () => {
                  Navigator.pop(context),
                  _toggleStreams(),
                },
                child: Text(
                  (widget.isStopping) ? 'Pause' : 'Start',
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
      },
      color: !_success
          ? Colors.red
          : widget.isStopping
              ? Colors.redAccent
              : Colors.green,
      icon: FaIcon(
        !_success
            ? FontAwesomeIcons.question
            : widget.isStopping
                ? FontAwesomeIcons.pause
                : FontAwesomeIcons.play,
        size: 21,
      ),
    );
  }
}
