import 'dart:math';

import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Charts/line_chart_stream.dart';
import 'package:e_jam/src/View/Charts/pie_chart_devices_per_stream.dart';
import 'package:e_jam/src/View/Charts/stream_progress_bar.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StreamDetailsView extends StatefulWidget {
  const StreamDetailsView({super.key, required this.id});
  final String id;

  @override
  State<StreamDetailsView> createState() => _StreamDetailsViewState();
}

class _StreamDetailsViewState extends State<StreamDetailsView> {
  get id => widget.id;
  StreamEntry? stream;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    StreamsController.loadStreamDetails(id).then((value) {
      setState(() {
        isLoading = false;
        stream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'stream$id',
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.8),
        width: MediaQuery.of(context).size.width *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Stream $id',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.pencil),
                  color: Colors.green,
                  onPressed: () {
                    // TODO: Implement Edit Stream
                  },
                ),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.trash_can),
                  color: Colors.red,
                  onPressed: () {
                    // TODO: Implement Delete Stream
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Stream'),
                        content: const Text(
                            'Are you sure you want to delete this stream?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: StreamGraph(id),
                      ),
                      Expanded(
                        flex: 2,
                        child: Visibility(
                            visible: !isLoading,
                            replacement: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            child: Visibility(
                                visible: stream != null,
                                replacement: const Center(
                                  child: Icon(MaterialCommunityIcons.alert),
                                ),
                                child: _streamFieldsDetails())),
                      ),
                    ],
                  ),
                ),
                StreamProgressBar(id),
                _streamActionButtons(id: id, status: StreamStatus.created),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _streamFieldsDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _idCheckContentDetails(),
          _generationSeed(),
          _delayTimeToLiveInterFrameGapDetails(),
          _packetsBroadcastFramesSizes(),
          _payloadLengthAndType(),
          _burstLengthAndDelay(),
          _flowAndTLPTypes(),
          _streamDevicesLists(),
          Text('${stream?.description}'),
        ],
      ),
    );
  }

  Row _streamDevicesLists() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: const Icon(
              MaterialCommunityIcons.progress_upload,
              semanticLabel: 'Generators',
              color: uploadColor,
            ),
          ),
          onPressed: () {},
        ),
        const VerticalDivider(),
        IconButton(
          icon: const Icon(
            MaterialCommunityIcons.progress_check,
            semanticLabel: 'Verifiers',
            color: downloadColor,
          ),
          onPressed: () {},
        )
      ],
    );
  }

  Row _flowAndTLPTypes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text('Flow Type'),
            Text(
              '${stream?.flowType}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text('TLP Type'),
            Text(
              '${stream?.transportLayerProtocol}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row _burstLengthAndDelay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text('Burst Length'),
            Text(
              '${stream?.burstLength}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text('Burst Delay'),
            Text(
              '${stream?.burstDelay}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row _payloadLengthAndType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text('Payload Length'),
            Text(
              '${stream?.payloadLength}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text('Payload Type'),
            Text(
              '${stream?.payloadType}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListTile _generationSeed() {
    return ListTile(
      leading: const Icon(MaterialCommunityIcons.seed),
      title: const Text('Generation Seed'),
      subtitle: Text('${stream?.seed}'),
    );
  }

  Row _packetsBroadcastFramesSizes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text('Packets'),
            Text(
              '${stream?.numberOfPackets}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text('Broadcast'),
            Text(
              '${stream?.broadcastFrames}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListTile _idCheckContentDetails() {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(
        '${stream?.name}',
      ),
      subtitle: Text('${stream?.streamId}'),
      trailing: Icon(
        stream?.checkContent ?? false
            ? FontAwesomeIcons.eye
            : FontAwesomeIcons.eyeSlash,
        size: 30,
        color: stream?.checkContent ?? false
            ? Colors.greenAccent.shade700
            : Colors.grey,
      ),
    );
  }

  Row _delayTimeToLiveInterFrameGapDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text('Delay'),
            Text(
              '${stream?.delay}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text('Time to Live'),
            Text(
              '${stream?.timeToLive}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text('Inter Frame Gap'),
            Text(
              '${stream?.interFrameGap}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row _streamActionButtons({required String id, required StreamStatus status}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: FaIcon(status == StreamStatus.running
              ? FontAwesomeIcons.pause
              : FontAwesomeIcons.play),
          color: status == StreamStatus.running ? streamRunningColor : null,
          tooltip: "Start",
          onPressed: () {
            StreamsController.startStream(id);
            // reload();
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.hourglassStart),
          color: status == StreamStatus.queued ? streamQueuedColor : null,
          tooltip: "Delay",
          onPressed: () {
            StreamsController.queueStream(id);
            // reload();
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.stop),
          color: status == StreamStatus.stopped ? streamStoppedColor : null,
          tooltip: "Stop",
          onPressed: () {
            StreamsController.stopStream(id);
            // reload();
          },
        ),
      ],
    );
  }
}

class StreamGraph extends StatefulWidget {
  const StreamGraph(this.id, {super.key});

  final String id;
  @override
  State<StreamGraph> createState() => _StreamGraphState();
}

class _StreamGraphState extends State<StreamGraph> {
  get id => widget.id;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: LineChartStream(id),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: PieDevices(runningDevices)),
              Expanded(child: DoughnutChartPackets(packetsState)),
            ],
          ),
        ),
      ],
    );
  }
}
