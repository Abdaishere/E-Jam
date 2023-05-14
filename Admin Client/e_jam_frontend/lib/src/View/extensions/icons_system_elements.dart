import 'dart:async';
import 'dart:math';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class IconsElementsSystem extends StatefulWidget {
  const IconsElementsSystem({super.key});

  @override
  State<IconsElementsSystem> createState() => _IconsElementsSystemState();
}

class _IconsElementsSystemState extends State<IconsElementsSystem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width > 450
              ? 340
              : MediaQuery.of(context).size.width
          : 340,
      height: 280,
      child: const Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(8),
        )),
        child: Elements(),
      ),
    );
  }
}

class Elements extends StatelessWidget {
  const Elements({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 5),
        Text(
          'Elements',
        ),
        SizedBox(height: 10),
        Expanded(
          child: DevicesRow(),
        ),
        Expanded(
          child: StreamsRow(),
        ),
      ],
    );
  }
}

class StreamsRow extends StatefulWidget {
  const StreamsRow({
    super.key,
  });

  @override
  State<StreamsRow> createState() => _StreamsRowState();
}

class _StreamsRowState extends State<StreamsRow> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreamsController>().loadAllStreamStatus(false);
    });
    timer = Timer.periodic(
        const Duration(seconds: 10),
        (Timer t) =>
            context.read<StreamsController>().loadAllStreamStatus(true));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int total =
        context.watch<StreamsController>().getStreamsStatusDetails?.length ?? 0;
    int running = context
            .watch<StreamsController>()
            .getStreamsStatusDetails
            ?.where((element) => element.streamStatus == StreamStatus.running)
            .length ??
        0;
    int error = context
            .watch<StreamsController>()
            .getStreamsStatusDetails
            ?.where((element) => element.streamStatus == StreamStatus.error)
            .length ??
        0;
    int done = context
            .watch<StreamsController>()
            .getStreamsStatusDetails
            ?.where((element) => element.streamStatus == StreamStatus.finished)
            .length ??
        0;
    int queued = context
            .watch<StreamsController>()
            .getStreamsStatusDetails
            ?.where((element) => element.streamStatus == StreamStatus.queued)
            .length ??
        0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.view_dashboard,
                  semanticLabel: 'Streams',
                  size: 28,
                ),
                color: Colors.blueAccent,
                tooltip: 'System Streams',
                onPressed: () {},
              ),
              Text(
                total.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of Streams',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.lan_connect,
                  semanticLabel: 'Streams',
                  size: 28,
                ),
                color: streamRunningColor,
                tooltip: 'Running Streams',
                onPressed: () {},
              ),
              Text(
                running.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of Streams',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.lan_disconnect,
                  semanticLabel: 'Streams',
                  size: 28,
                ),
                color: streamErrorColor,
                tooltip: 'Error Streams',
                onPressed: () {},
              ),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of Streams',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.lan_check,
                  semanticLabel: 'Streams',
                  size: 28,
                ),
                color: streamFinishedColor,
                tooltip: 'Finished Streams',
                onPressed: () {},
              ),
              Text(
                done.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of Streams',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.lan_pending,
                  semanticLabel: 'Streams',
                  size: 28,
                ),
                color: streamQueuedColor,
                tooltip: 'Queued Streams',
                onPressed: () {},
              ),
              Text(
                queued.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of Streams',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DevicesRow extends StatefulWidget {
  const DevicesRow({
    super.key,
  });

  @override
  State<DevicesRow> createState() => _DevicesRowState();
}

class _DevicesRowState extends State<DevicesRow> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevicesController>().loadAllDevices(false);
    });
    timer = Timer.periodic(const Duration(seconds: 10),
        (Timer t) => context.read<DevicesController>().loadAllDevices(true));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int total = context.watch<DevicesController>().getDevices?.length ?? 0;
    int running = context
            .watch<DevicesController>()
            .getDevices
            ?.where((element) => element.status == DeviceStatus.running)
            .length ??
        0;
    int offline = context
            .watch<DevicesController>()
            .getDevices
            ?.where((element) => element.status == DeviceStatus.offline)
            .length ??
        0;
    int gens = 0;
    context.watch<DevicesController>().getDevices?.forEach(
          (element) => gens += element.genProcesses ?? 0,
        );
    int vers = 0;
    context.watch<DevicesController>().getDevices?.forEach(
          (element) => vers += element.verProcesses ?? 0,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.microchip,
                  semanticLabel: 'Devices',
                  size: 28,
                ),
                color: Colors.deepOrangeAccent,
                tooltip: 'System Devices',
                onPressed: () {},
              ),
              Text(
                total.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of System Devices',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.connection,
                  semanticLabel: 'Devices',
                  size: 28,
                ),
                color: deviceRunningOrOnlineColor,
                tooltip: 'Running Devices',
                onPressed: () {},
              ),
              Text(
                running.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of System Devices',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.connection,
                  semanticLabel: 'Devices',
                  size: 28,
                ),
                color: deviceOfflineOrErrorColor,
                tooltip: 'Offline Devices',
                onPressed: () {},
              ),
              Text(
                offline.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of System Devices',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: const Icon(
                    MaterialCommunityIcons.progress_upload,
                    semanticLabel: 'Processes',
                    size: 28,
                  ),
                ),
                color: uploadColor,
                tooltip: 'System Generators',
                onPressed: () {},
              ),
              Text(
                gens.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of Processes',
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.progress_check,
                  semanticLabel: 'Processes',
                  size: 28,
                ),
                color: downloadColor,
                tooltip: 'System Verifiers',
                onPressed: () {},
              ),
              Text(
                vers.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                semanticsLabel: 'Number of Processes',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
