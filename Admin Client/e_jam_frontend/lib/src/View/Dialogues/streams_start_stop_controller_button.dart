import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreamsStartStopControllerButton extends StatefulWidget {
  const StreamsStartStopControllerButton({super.key});

  @override
  State<StreamsStartStopControllerButton> createState() =>
      _StreamsStartStopControllerButtonState();
}

class _StreamsStartStopControllerButtonState
    extends State<StreamsStartStopControllerButton> {
  bool _success = true;

  void _toggleStreams() async {
    if (SystemSettings.streamsAreRunning ?? false) {
      SystemSettings.streamsAreRunning = null;
      setState(() {});
      context.read<StreamsController>().stopAllStreams().then(
        (value) async {
          if (mounted) {
            _success = value;
            setState(() {});
          }
          final pref = await SharedPreferences.getInstance();
          pref.setBool(
              'streamsAreRunning', SystemSettings.streamsAreRunning ?? false);
        },
      );
    } else {
      SystemSettings.streamsAreRunning = null;
      setState(() {});
      context.read<StreamsController>().startAllStreams().then(
        (value) async {
          if (mounted) {
            _success = value;
            setState(() {});
          }

          // yes i am lazy and i know it :P
          final pref = await SharedPreferences.getInstance();
          pref.setBool(
              'streamsAreRunning', SystemSettings.streamsAreRunning ?? false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: SystemSettings.streamsAreRunning != null,
      replacement: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: LoadingAnimationWidget.fallingDot(
          color: context.watch<ThemeModel>().colorScheme.onSecondaryContainer,
          size: 28,
        ),
      ),
      child: IconButton(
        tooltip:
            (SystemSettings.streamsAreRunning ?? false) ? 'Pause' : 'Start',
        onPressed: () => {
          // show warning dialog for starting/stopping streams
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                (SystemSettings.streamsAreRunning ?? false)
                    ? 'Pause Streams'
                    : 'Start Streams',
              ),
              content: Text(
                (SystemSettings.streamsAreRunning ?? false)
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
                    (SystemSettings.streamsAreRunning ?? false)
                        ? 'Pause'
                        : 'Start',
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
        },
        color: !_success || SystemSettings.streamsAreRunning == null
            ? Colors.red
            : SystemSettings.streamsAreRunning ?? false
                ? Colors.green
                : context.watch<ThemeModel>().colorScheme.secondary,
        icon: FaIcon(
          !_success || SystemSettings.streamsAreRunning == null
              ? FontAwesomeIcons.question
              : SystemSettings.streamsAreRunning ?? false
                  ? FontAwesomeIcons.play
                  : FontAwesomeIcons.pause,
          size: 21,
        ),
      ),
    );
  }
}
