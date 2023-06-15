import 'dart:async';
import 'dart:math';
import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Enums/processes.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Charts/line_chart_stream.dart';
import 'package:e_jam/src/View/Charts/pie_chart_devices_per_stream.dart';
import 'package:e_jam/src/View/extensions/stream_progress_bar.dart';
import 'package:e_jam/src/View/Details_Views/edit_stream_view.dart';
import 'package:e_jam/src/View/Details_Views/stream_devices_list.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/stream_status_icon_button.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreamDetailsView extends StatefulWidget {
  const StreamDetailsView(
      {super.key,
      required this.id,
      required this.loadStreamsListView,
      required this.refreshCard});
  final String id;
  final Function refreshCard;
  final Function loadStreamsListView;
  @override
  State<StreamDetailsView> createState() => _StreamDetailsViewState();
}

class _StreamDetailsViewState extends State<StreamDetailsView> {
  get id => widget.id;
  StreamEntry? stream;
  Timer? timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStream();
    });
    timer =
        Timer.periodic(const Duration(seconds: 20), (Timer t) => _loadStream());
  }

  _loadStream() async {
    isLoading = true;
    setState(() {});
    StreamEntry? value =
        await context.read<StreamsController>().loadStreamDetails(id);
    if (mounted) {
      isLoading = false;
      stream = value;
      setState(() {});
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape &&
              MediaQuery.of(context).size.width > 800
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.08,
              vertical: MediaQuery.of(context).size.height * 0.07)
          : const EdgeInsets.all(20),
      child: Hero(
        tag: id,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
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
              actions: stream != null
                  ? [
                      IconButton(
                        icon: const Icon(MaterialCommunityIcons.chart_arc),
                        color: Colors.orange,
                        tooltip: 'Pin Stream Charts',
                        onPressed: () async {
                          if (SystemSettings.pinnedElements
                              .contains("S${stream?.streamId}")) return;

                          SystemSettings.pinnedElements
                              .add("S${stream?.streamId}");

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setStringList(
                              'pinnedElements', SystemSettings.pinnedElements);
                        },
                      ),
                      IconButton(
                        icon: const Icon(MaterialCommunityIcons.pencil),
                        color: Colors.green,
                        tooltip: 'Edit Stream',
                        onPressed: () {
                          Navigator.of(context).push(
                            HeroDialogRoute(
                              builder: (BuildContext context) => Center(
                                child: EditStreamView(
                                  reload: _loadStream,
                                  id: id,
                                  stream: stream,
                                ),
                              ),
                              settings:
                                  const RouteSettings(name: 'EditStreamView'),
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
                                  'Are you sure you want to delete Stream ${stream?.streamId ?? '___'}?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<StreamsController>()
                                        .deleteStream(stream?.streamId ?? '___')
                                        .then((success) => {
                                              if (mounted)
                                                {
                                                  widget.loadStreamsListView(),
                                                  Navigator.of(context).pop(),
                                                  Navigator.of(context).pop(),
                                                }
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
                    ]
                  : null,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Visibility(
                    visible: MediaQuery.of(context).orientation ==
                            Orientation.landscape &&
                        MediaQuery.of(context).size.width > 1000,
                    replacement: _columView(),
                    child: _rowView(),
                  ),
                ),
                StreamProgressBar(
                  status: stream?.streamStatus,
                  startTime: stream?.startTime,
                  endTime: stream?.endTime,
                  lastUpdated: stream?.lastUpdated,
                ),
                _streamActionButtons(
                    id: id,
                    status: stream?.streamStatus ?? StreamStatus.created),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _rowView() {
    return Row(
      children: [
        Expanded(
          flex: 4,
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
              child: StreamGraph(
                streamId: stream?.streamId ?? ' ',
                runningGenerators:
                    stream?.runningGenerators ?? const Processes.empty(),
                runningVerifiers:
                    stream?.runningVerifiers ?? const Processes.empty(),
              ),
            ),
          ),
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
    );
  }

  Column _columView() {
    return Column(
      children: [
        Expanded(
          flex: 4,
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
              child: StreamGraph(
                streamId: stream?.streamId ?? ' ',
                runningGenerators:
                    stream?.runningGenerators ?? const Processes.empty(),
                runningVerifiers:
                    stream?.runningVerifiers ?? const Processes.empty(),
              ),
            ),
          ),
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
    );
  }

  SingleChildScrollView _streamFieldsDetails() {
    return SingleChildScrollView(
      child: ListTileTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        horizontalTitleGap: 5,
        minVerticalPadding: 0,
        dense: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _idCheckContentDetails(),
            if (stream?.seed != 0) _generationSeed(),
            _delayTimeToLiveInterFrameGapDetails(),
            _packetsBroadcastFramesSizes(),
            _payloadLengthAndType(),
            _burstLengthAndDelay(),
            _flowAndTLPTypes(),
            const SizedBox(height: 10),
            _streamDevicesLists(),
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
        ((stream?.description.isEmpty ?? true)
                ? 'No Description'
                : stream?.description) ??
            'No Description',
      ),
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
          tooltip: stream?.runningGenerators?.processesMap == null ||
                  stream!.runningGenerators!.processesMap.isEmpty
              ? 'No Generators'
              : stream?.runningGenerators!.processesMap.length == 1
                  ? '1 Generator'
                  : '${stream?.runningGenerators!.processesMap.length} Generators',
          onPressed: () {
            Navigator.of(context).push(
              DialogRoute(
                context: context,
                builder: (BuildContext context) => Center(
                  child: StreamDevicesList(
                    areGenerators: true,
                    process: stream?.runningGenerators,
                    reloadStream: () => _loadStream(),
                  ),
                ),
                settings: const RouteSettings(name: 'Generators'),
              ),
            );
          },
        ),
        const VerticalDivider(),
        IconButton(
          icon: const Icon(
            MaterialCommunityIcons.progress_check,
            semanticLabel: 'Verifiers',
            color: downloadColor,
            size: 30,
          ),
          tooltip: stream?.runningVerifiers?.processesMap == null ||
                  stream!.runningVerifiers!.processesMap.isEmpty
              ? 'No Verifiers'
              : stream?.runningVerifiers!.processesMap.length == 1
                  ? '1 Verifier'
                  : '${stream?.runningVerifiers!.processesMap.length} Verifiers',
          onPressed: () {
            Navigator.of(context).push(
              DialogRoute(
                context: context,
                builder: (BuildContext context) => Center(
                  child: StreamDevicesList(
                    areGenerators: false,
                    process: stream?.runningVerifiers,
                    reloadStream: () => _loadStream(),
                  ),
                ),
                settings: const RouteSettings(name: 'Verifiers'),
              ),
            );
          },
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
            title: const Text(
              'Flow Type',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(flowTypeToString(stream?.flowType)),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text(
              'TLP Type',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              transportLayerProtocolToString(stream?.transportLayerProtocol),
            ),
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
            title: const Text(
              'Burst Length',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.burstLength.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text(
              'Burst Delay',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.burstDelay.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
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
            title: const Text(
              'Payload Length',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.payloadLength.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text(
              'Payload Type',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(payloadTypeToString(stream?.payloadType ?? -1),
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  String payloadTypeToString(int payloadType) {
    switch (payloadType) {
      case 0:
        return 'Ipv4';
      case 1:
        return 'Ipv6';
      case 2:
        return 'Random';
      default:
        return 'Unknown';
    }
  }

  ListTile _generationSeed() {
    return ListTile(
      leading: const Icon(MaterialCommunityIcons.seed),
      title: const Text(
        'Generation Seed',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(stream?.seed.toString() ?? 'Unknown',
          overflow: TextOverflow.ellipsis),
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
            title: const Text(
              'Packets',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.numberOfPackets.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text(
              'Frame Size',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.broadcastFrames.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  ListTile _idCheckContentDetails() {
    return ListTile(
      leading: StreamStatusIconButton(
          status: stream?.streamStatus ?? StreamStatus.error,
          id: stream?.streamId ?? '___',
          lastUpdated: stream?.lastUpdated ?? DateTime.now(),
          refresh: () {
            _loadStream();
          },
          isDense: true),
      title: Text(
        ((stream?.name.isEmpty ?? true) ? 'Unnamed' : stream?.name) ??
            'Unknown',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(stream?.streamId ?? '___'),
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
            title: const Text(
              'Delay',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.delay.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text(
              'Duration',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.duration.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text(
              'Inter Frame Gap',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(stream?.interFrameGap.toString() ?? 'Unknown',
                overflow: TextOverflow.ellipsis),
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
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.play),
          color: status == StreamStatus.running
              ? streamColorScheme(StreamStatus.running)
              : null,
          tooltip: "Start",
          onPressed: () {
            context.read<StreamsController>().startStream(id).then((success) {
              if (mounted) {
                _loadStream();
                widget.refreshCard();
              }
            });
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.pause),
          color:
              (status == StreamStatus.error || status == StreamStatus.stopped)
                  ? streamColorScheme(status)
                  : null,
          tooltip: "Pause",
          onPressed: () {
            context.read<StreamsController>().stopStream(id).then((success) {
              if (mounted) {
                _loadStream();
                widget.refreshCard();
              }
            });
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.hourglassStart),
          color: status == StreamStatus.queued
              ? streamColorScheme(StreamStatus.queued)
              : null,
          tooltip: "Delay",
          onPressed: () {
            context.read<StreamsController>().queueStream(id).then((success) {
              if (mounted) {
                _loadStream();
                widget.refreshCard();
              }
            });
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.stop),
          color: status == StreamStatus.stopped
              ? streamColorScheme(StreamStatus.stopped)
              : null,
          tooltip: "Stop",
          onPressed: () {
            context.read<StreamsController>().stopStream(id).then((success) {
              if (mounted) {
                _loadStream();
              }
            });
          },
        ),
      ],
    );
  }
}

class StreamGraph extends StatefulWidget {
  const StreamGraph({
    super.key,
    required this.streamId,
    required this.runningGenerators,
    required this.runningVerifiers,
  });

  final String streamId;
  final Processes runningGenerators;
  final Processes runningVerifiers;
  @override
  State<StreamGraph> createState() => _StreamGraphState();
}

class _StreamGraphState extends State<StreamGraph> {
  // first item will be exploded in the chart if enabled
  final Map<ProcessStatus, int> _processesCounterMap = {
    ProcessStatus.failed: 0,
    ProcessStatus.running: 0,
    ProcessStatus.completed: 0,
    ProcessStatus.queued: 0,
    ProcessStatus.stopped: 0,
  };
  final Map<PacketStatus, num> _totalPacketsStatusMap = {
    PacketStatus.error: 0,
    PacketStatus.sent: 0,
    PacketStatus.received: 0,
    PacketStatus.dropped: 0,
  };
  Processes get runningGenerators => widget.runningGenerators;
  Processes get runningVerifiers => widget.runningVerifiers;
  String get streamId => widget.streamId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _countProcesses();
    });
  }

  _countProcesses() {
    runningGenerators.processesMap.forEach((key, value) {
      _processesCounterMap[value] = _processesCounterMap[value]! + 1;
    });

    runningVerifiers.processesMap.forEach((key, value) {
      _processesCounterMap[value] = _processesCounterMap[value]! + 1;
    });

    setState(() {});
  }

  _countPackets(List<VerifierStatisticsInstance> streamVerifiers,
      List<GeneratorStatisticsInstance> streamGenerators) {
    for (var element in streamVerifiers) {
      _addVerifierPacketsCount(element);
    }

    for (var element in streamGenerators) {
      _addGeneratorPacketsCount(element);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<VerifierStatisticsInstance> streamVerifiers = [];
    streamVerifiers = context
        .watch<StatisticsController>()
        .getVerifierStatistics
        .where((element) => element.streamId == streamId)
        .toList();

    List<GeneratorStatisticsInstance> streamGenerators = [];
    streamGenerators = context
        .watch<StatisticsController>()
        .getGeneratorStatistics
        .where((element) => element.streamId == streamId)
        .toList();
    _countPackets(streamVerifiers, streamGenerators);

    return _showChart(streamVerifiers, streamGenerators);
  }

  Column _showChart(List<VerifierStatisticsInstance> streamVerifiers,
      List<GeneratorStatisticsInstance> streamGenerators) {
    bool showProcessesPieChart = runningGenerators.processesMap.isNotEmpty ||
        runningVerifiers.processesMap.isNotEmpty;

    num totalPackets = _totalPacketsStatusMap.values.reduce((a, b) => a + b);

    if (totalPackets <= 0 && !showProcessesPieChart) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MaterialCommunityIcons.chart_arc,
            color: Colors.grey,
            size: 50.0,
          ),
          SizedBox(height: 8.0),
          Text(
            'No Data Here',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (totalPackets > 0)
          Expanded(
            child: LineChartStream(
                id: streamId,
                verChartData: streamVerifiers,
                genChartData: streamGenerators),
          ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (totalPackets > 0)
                Expanded(
                  child: DoughnutChartPackets(
                    packetsCountMapToList(_totalPacketsStatusMap),
                  ),
                ),

              // hide if no processes are provided
              if (showProcessesPieChart)
                Expanded(
                  child: PieDevices(
                    runningProcessesToList(_processesCounterMap),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  _addGeneratorPacketsCount(GeneratorStatisticsInstance generator) {
    _totalPacketsStatusMap[PacketStatus.sent] =
        _totalPacketsStatusMap[PacketStatus.sent]! + generator.packetsSent;

    _totalPacketsStatusMap[PacketStatus.error] =
        _totalPacketsStatusMap[PacketStatus.error]! + generator.packetsErrors;
  }

  _addVerifierPacketsCount(VerifierStatisticsInstance verifier) {
    _totalPacketsStatusMap[PacketStatus.received] =
        _totalPacketsStatusMap[PacketStatus.received]! +
            verifier.packetsCorrect +
            verifier.packetsOutOfOrder;

    _totalPacketsStatusMap[PacketStatus.dropped] =
        _totalPacketsStatusMap[PacketStatus.dropped]! + verifier.packetsDropped;

    _totalPacketsStatusMap[PacketStatus.error] =
        _totalPacketsStatusMap[PacketStatus.error]! +
            verifier.packetsErrors +
            verifier.packetsOutOfOrder;
  }
}
