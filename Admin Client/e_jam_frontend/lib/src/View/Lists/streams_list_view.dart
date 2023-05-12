import 'dart:math';
import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_stream_view.dart';
import 'package:e_jam/src/View/Details_Views/edit_stream_view.dart';
import 'package:e_jam/src/View/Details_Views/stream_details_view.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Dialogues/stream_status_icon_button.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StreamsListView extends StatefulWidget {
  const StreamsListView({super.key});

  @override
  State<StreamsListView> createState() => _StreamsListViewState();
}

class _StreamsListViewState extends State<StreamsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreamsController>().loadAllStreamStatus(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: streamsListViewAppBar(),
      body: Stack(
        children: [
          Visibility(
            visible: !context.watch<StreamsController>().getIsLoading,
            replacement: Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.grey,
                size: 70.0,
              ),
            ),
            child: Visibility(
              visible:
                  context.watch<StreamsController>().getStreamsStatusDetails !=
                          null &&
                      context
                          .watch<StreamsController>()
                          .getStreamsStatusDetails!
                          .isNotEmpty,
              replacement: Visibility(
                visible: context
                            .watch<StreamsController>()
                            .getStreamsStatusDetails !=
                        null &&
                    context
                        .watch<StreamsController>()
                        .getStreamsStatusDetails!
                        .isEmpty,
                replacement: const Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        size: 100.0,
                      ),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.barsStaggered,
                        size: 100.0,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'No streams found',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                shrinkWrap: true,
                itemCount: context
                    .watch<StreamsController>()
                    .getStreamsStatusDetails
                    ?.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      max(MediaQuery.of(context).size.width ~/ 280.0, 1),
                  childAspectRatio: 3 / 2,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 3.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return StreamCard(
                    stream: context
                        .watch<StreamsController>()
                        .getStreamsStatusDetails![index],
                    loadStreamView: () => context
                        .read<StreamsController>()
                        .loadAllStreamStatus(true),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(right: 35.0, bottom: 30.0),
              child: const AddStreamButton(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar streamsListViewAppBar() {
    return AppBar(
      title: const Text(
        'Streams',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: const DrawerWidget(),
      actions: <Widget>[
        // refresh icon for refreshing the streams list view
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 20.0),
          onPressed: () async =>
              context.read<StreamsController>().loadAllStreamStatus(true),
        ),
        // Explanation icon for details about how the stream card works and what the icons mean and what the colors mean
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.circleQuestion, size: 20.0),
          onPressed: () {
            // TODO: add a dialog with the explanation
          },
        ),
      ],
    );
  }
}

class AddStreamButton extends StatelessWidget {
  const AddStreamButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Add Stream',
      heroTag: 'addStream',
      backgroundColor: Colors.blueAccent,
      mini: true,
      onPressed: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) => const Center(
              child: AddStreamView(),
            ),
            settings: const RouteSettings(name: 'AddStreamView'),
          ),
        );
      },
      child: const FaIcon(FontAwesomeIcons.plus),
    );
  }
}

class StreamCard extends StatefulWidget {
  const StreamCard(
      {super.key, required this.stream, required this.loadStreamView});

  final StreamStatusDetails stream;
  final Function() loadStreamView;

  @override
  State<StreamCard> createState() => _StreamCardState();
}

class _StreamCardState extends State<StreamCard> {
  StreamStatusDetails? updatedStream;

  Future<void> refreshCard() async {
    StreamStatusDetails? value = await context
        .read<StreamsController>()
        .loadStreamStatusDetails(widget.stream.streamId);
    if (mounted) {
      updatedStream = value;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    StreamStatusDetails stream = updatedStream ?? widget.stream;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) => Center(
              child: StreamDetailsView(
                id: stream.streamId,
                loadStreamsListView: () => {
                  widget.loadStreamView(),
                },
                refreshCard: () {
                  refreshCard();
                },
              ),
            ),
            settings: const RouteSettings(name: 'StreamDetailsView'),
          ),
        );
      },
      child: Hero(
        tag: stream.streamId,
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 8.0, left: 8.0, right: 8.0, bottom: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // status icon according to stream status
                    StreamStatusIconButton(
                      status: stream.streamStatus,
                      id: stream.streamId,
                      lastUpdated: stream.lastUpdated,
                      refresh: () {
                        refreshCard();
                      },
                      isDense: false,
                    ),
                    // stream ID
                    _nameIdLabel(stream),
                    // menu icon for more options and details
                    _popupMenuList(context, stream),
                  ],
                ),
                // upload and download speed
                SpeedMonitor(stream.streamId),

                // delay, start, stop, delete, edit, progress bar
                // status icons should be the status of the stream (running, error, stopped, queued, finished, ready) and stream name (Alphanumeric 3 letters long names) and menu icon for more options and details
                _streamActionsBar(
                  stream.streamStatus,
                  stream.streamId,
                ),

                // progress bar for the stream (if the stream is running) otherwise show the color of the status
                MiniProgressBar(
                  status: stream.streamStatus,
                  startTime: stream.startTime,
                  endTime: stream.endTime,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _nameIdLabel(StreamStatusDetails stream) {
    return Expanded(
      child: Column(
        children: [
          Text(
            stream.name,
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stream.streamId,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<dynamic> _popupMenuList(
      BuildContext context, StreamStatusDetails stream) {
    return PopupMenuButton(
      tooltip: 'More Options',
      icon: const FaIcon(
        Icons.more_vert,
        size: 20.0,
      ),
      onSelected: (dynamic value) {
        if (value == 'View') {
          Navigator.of(context).push(
            HeroDialogRoute(
              builder: (BuildContext context) => Center(
                child: StreamDetailsView(
                  id: stream.streamId,
                  loadStreamsListView: () => {
                    widget.loadStreamView(),
                  },
                  refreshCard: () {
                    refreshCard();
                  },
                ),
              ),
              settings: const RouteSettings(name: 'StreamDetailsView'),
            ),
          );
        } else if (value == 'Delete') {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete Stream'),
              content: Text(
                  'Are you sure you want to delete stream ${stream.streamId}?'),
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
                        .deleteStream(stream.streamId)
                        .then((success) => {
                              if (success && mounted) {widget.loadStreamView()}
                            });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          );
        } else if (value == 'Edit') {
          context
              .read<StreamsController>()
              .loadStreamDetails(stream.streamId)
              .then(
                (value) => {
                  if (mounted)
                    {
                      if (value != null && mounted)
                        {
                          Navigator.of(context).push(
                            HeroDialogRoute(
                              builder: (BuildContext context) => Center(
                                  child: EditStreamView(
                                      stream: value,
                                      reload: refreshCard,
                                      id: stream.streamId)),
                              settings:
                                  const RouteSettings(name: 'EditStreamView'),
                            ),
                          ),
                        }
                      else
                        {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Error loading stream'),
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
                            ),
                          ),
                        }
                    },
                },
              );
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry>[
          PopupMenuItem(
            value: 'View',
            child: Row(
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: const Icon(MaterialCommunityIcons.view_quilt,
                      color: Colors.blueAccent),
                ),
                const SizedBox(width: 10.0),
                const Text('View'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'Edit',
            child: Row(
              children: [
                Icon(MaterialCommunityIcons.pencil, color: Colors.green),
                SizedBox(width: 10.0),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: Row(
              children: [
                FaIcon(MaterialCommunityIcons.trash_can, color: Colors.red),
                SizedBox(width: 10.0),
                Text('Delete'),
              ],
            ),
          ),
        ];
      },
    );
  }

  Row _streamActionsBar(StreamStatus status, String id) {
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
                onPressed: () async {
                  await context.read<StreamsController>().startStream(id);
                  if (mounted) refreshCard();
                },
              )
            : IconButton(
                icon: const FaIcon(FontAwesomeIcons.pause),
                color:
                    status == StreamStatus.running ? streamRunningColor : null,
                tooltip: "Pause",
                onPressed: () async {
                  await context.read<StreamsController>().pauseStream(id);
                  if (mounted) refreshCard();
                },
              ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.hourglassStart),
          color: status == StreamStatus.queued ? streamQueuedColor : null,
          tooltip: "Delay",
          onPressed: () async {
            await context.read<StreamsController>().queueStream(id);
            if (mounted) refreshCard();
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.stop),
          color: status == StreamStatus.stopped ? streamStoppedColor : null,
          tooltip: "Stop",
          onPressed: () async {
            await context.read<StreamsController>().stopStream(id);
            if (mounted) refreshCard();
          },
        ),
      ],
    );
  }
}

class MiniProgressBar extends StatelessWidget {
  const MiniProgressBar({
    super.key,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  final StreamStatus status;
  final DateTime startTime;
  final DateTime endTime;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: LinearProgressIndicator(
        minHeight: 5.0,
        value: getProgress(status, startTime, endTime),
        backgroundColor: streamColorScheme(status).withAlpha(100),
        valueColor: AlwaysStoppedAnimation<Color>(streamColorScheme(status)),
      ),
    );
  }

  final double accuracy = 0.8;
  double getProgress(
      StreamStatus status, DateTime? startTime, DateTime? endTime) {
    if (status == StreamStatus.running ||
        status == StreamStatus.stopped ||
        status == StreamStatus.error) {
      return startTime == null
          ? 0
          : endTime == null
              ? 0.5
              : (startTime.difference(DateTime.now()).inSeconds /
                      (startTime.difference(endTime).inSeconds == 0
                          ? 1
                          : startTime.difference(DateTime.now()).inSeconds)) *
                  accuracy;
    } else if (status == StreamStatus.finished) {
      return 1;
    } else {
      return 0;
    }
  }
}

// TODO: Bind this to kafka Consumer and update the UI
class SpeedMonitor extends StatelessWidget {
  const SpeedMonitor(
    String id, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              FaIcon(FontAwesomeIcons.caretUp, color: uploadColor, size: 35.0),
              SizedBox(
                child: Text(
                  '0 MB/s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(),
        Expanded(
          child: Column(
            children: <Widget>[
              FaIcon(FontAwesomeIcons.caretDown,
                  color: downloadColor, size: 35.0),
              SizedBox(
                child: Text(
                  '0 MB/s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
