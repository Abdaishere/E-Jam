import 'dart:math';

import 'package:e_jam/src/Model/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DevicesDetailsView extends StatefulWidget {
  const DevicesDetailsView(this.index, {super.key});

  final int index;
  @override
  State<DevicesDetailsView> createState() => _DevicesDetailsViewState();
}

class _DevicesDetailsViewState extends State<DevicesDetailsView> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'device$index',
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Device $index',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    MaterialCommunityIcons.wifi_sync,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Ping Device',
                  color: Colors.lightBlueAccent,
                ),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.pencil),
                  color: Colors.green,
                  tooltip: 'Edit Device',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.trash_can),
                  color: Colors.red,
                  tooltip: 'Delete Device',
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: DeviceGraph(index),
                ),
                Expanded(
                  flex: 3,
                  child: DeviceFieldsDetails(index),
                ),
                const Divider(
                  thickness: 2,
                  indent: 10,
                  endIndent: 10,
                ),
                ProgressDeviceDetails(index),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceGraph extends StatefulWidget {
  const DeviceGraph(this.index, {super.key});

  final int index;
  @override
  State<DeviceGraph> createState() => _DeviceGraphState();
}

class _DeviceGraphState extends State<DeviceGraph> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 4, child: DoughnutChartPackets(packetsState)),
      ],
    );
  }
}

class DeviceFieldsDetails extends StatefulWidget {
  const DeviceFieldsDetails(this.index, {super.key});

  final int index;
  @override
  State<DeviceFieldsDetails> createState() => _DeviceFieldsDetailsState();
}

class _DeviceFieldsDetailsState extends State<DeviceFieldsDetails> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: const Icon(
                            MaterialCommunityIcons.progress_upload,
                            semanticLabel: 'Processes'),
                      ),
                      color: uploadColor,
                      tooltip: 'Generating Processes',
                      onPressed: () {},
                    ),
                    const Text(
                      '7',
                      style: TextStyle(
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
                      icon: const Icon(MaterialCommunityIcons.progress_check,
                          semanticLabel: 'Processes'),
                      color: downloadColor,
                      tooltip: 'Verifying Processes',
                      onPressed: () {},
                    ),
                    const Text(
                      '742',
                      style: TextStyle(
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
          ),
          const SizedBox(height: 10),
          const Expanded(child: Text(loremIpsum)),
        ],
      ),
    );
  }
}

class ProgressDeviceDetails extends StatefulWidget {
  const ProgressDeviceDetails(this.index, {super.key});

  final int index;
  @override
  State<ProgressDeviceDetails> createState() => _ProgressDeviceDetailsState();
}

class _ProgressDeviceDetailsState extends State<ProgressDeviceDetails> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            children: const <Widget>[
              FaIcon(FontAwesomeIcons.caretUp, color: uploadColor),
              Text(
                '987654321MB/s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: const <Widget>[
              FaIcon(FontAwesomeIcons.caretDown, color: downloadColor),
              Text(
                '987654321MB/s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
