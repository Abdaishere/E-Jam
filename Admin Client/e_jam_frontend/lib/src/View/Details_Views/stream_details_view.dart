import 'dart:math';

import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Charts/line_chart_stream.dart';
import 'package:e_jam/src/View/Charts/pie_chart_devices_per_stream.dart';
import 'package:e_jam/src/View/Charts/stream_progress_bar.dart';
import 'package:e_jam/src/View/Details_Views/edit_stream_view.dart';
import 'package:e_jam/src/View/Lists/streams_list_view.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StreamDetailsView extends StatefulWidget {
  const StreamDetailsView(
      {super.key, required this.id, required this.loadStreamsListView});
  final String id;
  final Function loadStreamsListView;
  @override
  State<StreamDetailsView> createState() => _StreamDetailsViewState();
}

class _StreamDetailsViewState extends State<StreamDetailsView> {
  get id => widget.id;
  StreamEntry? stream;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    _loadStream();
  }

  _loadStream() {
    isLoading = true;
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
                  tooltip: 'Edit Stream',
                  onPressed: () {
                    Navigator.of(context).push(
                      HeroDialogRoute(
                        builder: (BuildContext context) => Center(
                          child: EditStreamView(
                            stream: stream!,
                            refresh: _loadStream,
                          ),
                        ),
                        settings: const RouteSettings(name: 'EditStreamView'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.trash_can),
                  color: Colors.red,
                  tooltip: 'Delete Stream',
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Delete Stream?'),
                        content: Text(
                            'Are you sure you want to delete Stream ${stream?.streamId}?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              StreamsController.deleteStream(
                                      stream?.streamId ?? '')
                                  .then((success) => {
                                        widget.loadStreamsListView(),
                                        Navigator.of(context).pop(),
                                        Navigator.of(context).pop(),
                                      });
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
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
                  child: Visibility(
                    visible: MediaQuery.of(context).orientation ==
                            Orientation.landscape &&
                        MediaQuery.of(context).size.width > 1000,
                    replacement: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: StreamGraph(id),
                        ),
                        const VerticalDivider(
                          width: 5,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Expanded(
                          flex: 2,
                          child: Visibility(
                            visible: !isLoading,
                            replacement: Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: Colors.grey,
                                size: 40.0,
                              ),
                            ),
                            child: Visibility(
                              visible: stream != null,
                              replacement: const Center(
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                  size: 40,
                                ),
                              ),
                              child: _streamFieldsDetails(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: StreamGraph(id),
                        ),
                        const VerticalDivider(
                          width: 5,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Expanded(
                          flex: 2,
                          child: Visibility(
                            visible: !isLoading,
                            replacement: Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: Colors.grey,
                                size: 40.0,
                              ),
                            ),
                            child: Visibility(
                              visible: stream != null,
                              replacement: const Center(
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                  size: 40,
                                ),
                              ),
                              child: _streamFieldsDetails(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // TODO: Implement Stream Statistics
                StreamProgressBar(
                  status: stream?.streamStatus ?? StreamStatus.error,
                  startTime: stream?.startTime ?? DateTime.now(),
                  endTime: stream?.endTime ?? DateTime.now(),
                ),
                _streamActionButtons(
                    id: id, status: stream?.streamStatus ?? StreamStatus.error),
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
      child: ListTileTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        horizontalTitleGap: 5,
        minVerticalPadding: 0,
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
            const SizedBox(height: 10),
            _description(),
          ],
        ),
      ),
    );
  }

  ListTile _description() {
    return ListTile(
      title: Text(
        textAlign: TextAlign.left,
        '${stream?.description}',
      ),
      dense: true,
    );
  }

  Row _streamDevicesLists() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: const Icon(
              MaterialCommunityIcons.progress_upload,
              semanticLabel: 'Generators',
              color: uploadColor,
              size: 30,
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
            size: 30,
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
        Expanded(
          child: ListTile(
            leading:
                const Icon(MaterialCommunityIcons.transit_connection_variant),
            title: const Text('Flow Type', overflow: TextOverflow.ellipsis),
            subtitle: Text(flowTypeToString(stream?.flowType)),
            dense: true,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('TLP Type', overflow: TextOverflow.ellipsis),
            subtitle: Text(
              transportLayerProtocolToString(stream?.transportLayerProtocol),
            ),
            dense: true,
          ),
        ),
      ],
    );
  }

  Row _burstLengthAndDelay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            leading: const Icon(MaterialCommunityIcons.broadcast),
            title: const Text('Burst Length', overflow: TextOverflow.ellipsis),
            subtitle:
                Text('${stream?.burstLength}', overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Burst Delay', overflow: TextOverflow.ellipsis),
            subtitle:
                Text('${stream?.burstDelay}', overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
      ],
    );
  }

  Row _payloadLengthAndType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            leading: const Icon(
              Icons.featured_play_list_rounded,
            ),
            title:
                const Text('Payload Length', overflow: TextOverflow.ellipsis),
            subtitle: Text('${stream?.payloadLength}',
                overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Payload Type', overflow: TextOverflow.ellipsis),
            subtitle:
                Text('${stream?.payloadType}', overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
      ],
    );
  }

  ListTile _generationSeed() {
    return ListTile(
      leading: const Icon(MaterialCommunityIcons.seed),
      title: const Text('Generation Seed', overflow: TextOverflow.ellipsis),
      subtitle: Text('${stream?.seed}', overflow: TextOverflow.ellipsis),
      dense: true,
    );
  }

  Row _packetsBroadcastFramesSizes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            leading: Icon(
              stream?.checkContent ?? false
                  ? MaterialCommunityIcons.package_variant
                  : MaterialCommunityIcons.package_variant_closed,
            ),
            title: const Text('Packets', overflow: TextOverflow.ellipsis),
            subtitle: Text('${stream?.numberOfPackets}',
                overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Frame Size', overflow: TextOverflow.ellipsis),
            subtitle: Text('${stream?.broadcastFrames}',
                overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
      ],
    );
  }

  ListTile _idCheckContentDetails() {
    return ListTile(
      leading: StatusIconButton(
          status: stream?.streamStatus ?? StreamStatus.error,
          id: stream?.streamId ?? '',
          lastUpdated: stream?.lastUpdated ?? DateTime.now(),
          refresh: () {
            _loadStream();
          },
          isDense: true),
      title: Text(
        '${stream?.name}',
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${stream?.streamId}'),
      trailing: Icon(
        stream?.checkContent ?? false
            ? FontAwesomeIcons.eye
            : FontAwesomeIcons.eyeSlash,
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
        Expanded(
          child: ListTile(
            leading: const Icon(MaterialCommunityIcons.timer),
            title: const Text('Delay', overflow: TextOverflow.ellipsis),
            subtitle: Text('${stream?.delay}', overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Time to Live', overflow: TextOverflow.ellipsis),
            subtitle:
                Text('${stream?.timeToLive}', overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
        Expanded(
          child: ListTile(
            title:
                const Text('Inter Frame Gap', overflow: TextOverflow.ellipsis),
            subtitle: Text('${stream?.interFrameGap}',
                overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
      ],
    );
  }

  Row _streamActionButtons({required String id, required StreamStatus status}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        status != StreamStatus.running
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.play),
                color:
                    status == StreamStatus.running ? streamRunningColor : null,
                tooltip: "Start",
                onPressed: () {
                  StreamsController.startStream(id).then((success) {
                    _loadStream();
                  });
                },
              )
            : IconButton(
                icon: const FaIcon(FontAwesomeIcons.pause),
                color:
                    status == StreamStatus.running ? streamRunningColor : null,
                tooltip: "Pause",
                onPressed: () {
                  StreamsController.pauseStream(id).then((success) {
                    _loadStream();
                  });
                },
              ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.hourglassStart),
          color: status == StreamStatus.queued ? streamQueuedColor : null,
          tooltip: "Delay",
          onPressed: () {
            StreamsController.queueStream(id).then((success) {
              _loadStream();
            });
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.stop),
          color: status == StreamStatus.stopped ? streamStoppedColor : null,
          tooltip: "Stop",
          onPressed: () {
            StreamsController.stopStream(id).then((success) {
              _loadStream();
            });
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
