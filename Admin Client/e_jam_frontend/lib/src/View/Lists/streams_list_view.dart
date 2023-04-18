import 'dart:math';
import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_stream_view.dart';
import 'package:e_jam/src/View/Details_Views/edit_stream_view.dart';
import 'package:e_jam/src/View/Details_Views/stream_details_view.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class StreamsListView extends StatefulWidget {
  const StreamsListView({super.key});

  @override
  State<StreamsListView> createState() => _StreamsListViewState();
}

class _StreamsListViewState extends State<StreamsListView> {
  get scaffoldMessenger => ScaffoldMessenger.of(context);
  get controllerStreamsStatusDetails => StreamsController.streamsStatusDetails;
  get controllerIsStreamListLoading => StreamsController.isLoading;

  List<StreamStatusDetails>? streams;
  bool isStreamListLoading = true;

  // load the status of all streams from the server and update the UI with the list of streams status accordingly
  void loadStreamView() async {
    setState(() {
      isStreamListLoading = true;
    });

    StreamsController.loadAllStreamStatus(scaffoldMessenger).then(
      (value) => {
        setState(() {
          streams = controllerStreamsStatusDetails;
          isStreamListLoading = controllerIsStreamListLoading;
        })
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => loadStreamView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: streamsListViewAppBar(),
      body: Stack(
        children: [
          Visibility(
            visible: !isStreamListLoading,
            replacement: Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.grey,
                size: 70.0,
              ),
            ),
            child: Visibility(
              visible: streams != null && streams!.isNotEmpty,
              replacement: Visibility(
                visible: streams != null && streams!.isEmpty,
                replacement: Stack(
                  children: const [
                    Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        size: 100.0,
                      ),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
                itemCount: streams?.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: max(
                      MediaQuery.of(context).copyWith().size.width ~/ 342.0, 1),
                  childAspectRatio: 3 / 2,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 3.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return StreamCard(
                      stream: streams![index],
                      refresh: () {
                        loadStreamView();
                      });
                },
              ),
            ),
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(right: 35.0, bottom: 30.0),
              child: AddStreamButton(
                loadStreamView: () {
                  loadStreamView();
                },
              ),
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
          onPressed: () {
            loadStreamView();
          },
        ),
        // gear icon for settings and preferences related to the streams list view (sort by, filter by, etc.)
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.gear, size: 20.0),
          onPressed: () {
            // TODO: go to the settings page or add a dialog with the settings and preferences for the streams list view only
          },
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
  const AddStreamButton({Key? key, required this.loadStreamView})
      : super(key: key);

  final Function() loadStreamView;
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
            builder: (BuildContext context) => Center(
              child: AddStreamView(reload: () => loadStreamView()),
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
  const StreamCard({super.key, required this.stream, required this.refresh});

  final StreamStatusDetails stream;
  final Function() refresh;

  @override
  State<StreamCard> createState() => _StreamCardState();
}

class _StreamCardState extends State<StreamCard> {
  StreamStatusDetails? updatedStream;

  void reload() {
    StreamsController.loadStreamStatusDetails(
            ScaffoldMessenger.of(context), widget.stream.id)
        .then(
      (value) => {
        setState(() {
          updatedStream = value;
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    StreamStatusDetails stream = updatedStream ?? widget.stream;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) =>
                Center(child: StreamDetailsView(id: stream.id)),
            settings: const RouteSettings(name: 'StreamDetailsView'),
          ),
        );
      },
      child: Hero(
        tag: 'stream${stream.id}',
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
                    StatusIconButton(
                        status: stream.status,
                        id: stream.id,
                        lastUpdated: stream.lastUpdated,
                        refresh: () {
                          reload();
                        }),
                    // stream ID
                    _nameIdLabel(stream),
                    // menu icon for more options and details
                    _popupMenuList(context, stream),
                  ],
                ),
                // upload and download speed
                SpeedMonitor(stream.id),

                // delay, start, stop, delete, edit, progress bar
                // status icons should be the status of the stream (running, error, stopped, queued, finished, ready) and stream name (Alphanumeric 3 letters long names) and menu icon for more options and details
                _streamActionsBar(
                  stream.status,
                  stream.id,
                ),

                // progress bar for the stream (if the stream is running) otherwise show the color of the status
                MiniProgressBar(
                  status: stream.status,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stream.id,
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
              builder: (BuildContext context) =>
                  Center(child: StreamDetailsView(id: stream.id)),
              settings: const RouteSettings(name: 'StreamDetailsView'),
            ),
          );
        } else if (value == 'Delete') {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete Stream'),
              content:
                  Text('Are you sure you want to delete stream ${stream.id}?'),
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
                            ScaffoldMessenger.of(context), stream.id)
                        .then((success) => {if (success) widget.refresh()});
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
          Navigator.of(context).push(
            HeroDialogRoute(
              builder: (BuildContext context) =>
                  Center(child: EditStreamView(id: stream.id, refresh: reload)),
              settings: const RouteSettings(name: 'EditStreamView'),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry>[
          PopupMenuItem(
            value: 'View',
            child: Row(
              children: const [
                Icon(MaterialCommunityIcons.view_quilt,
                    color: Colors.blueAccent),
                SizedBox(width: 10.0),
                Text('View'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'Edit',
            child: Row(
              children: const [
                Icon(MaterialCommunityIcons.pencil, color: Colors.green),
                SizedBox(width: 10.0),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'Delete',
            child: Row(
              children: const [
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
        IconButton(
          icon: FaIcon(status == StreamStatus.running
              ? FontAwesomeIcons.pause
              : FontAwesomeIcons.play),
          color: status == StreamStatus.running ? streamRunningColor : null,
          tooltip: "Start",
          onPressed: () {
            StreamsController.startStream(ScaffoldMessenger.of(context), id)
                .then((success) {
              if (success) {
                reload();
              }
            });
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.hourglassStart),
          color: status == StreamStatus.queued ? streamQueuedColor : null,
          tooltip: "Delay",
          onPressed: () {
            StreamsController.queueStream(ScaffoldMessenger.of(context), id)
                .then((success) {
              if (success) {
                reload();
              }
            });
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.stop),
          color: status == StreamStatus.stopped ? streamStoppedColor : null,
          tooltip: "Stop",
          onPressed: () {
            StreamsController.stopStream(ScaffoldMessenger.of(context), id)
                .then((success) {
              if (success) {
                reload();
              }
            });
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
        value: getStreamProgress(),
        backgroundColor: streamColorScheme(status).withAlpha(100),
        valueColor: AlwaysStoppedAnimation<Color>(streamColorScheme(status)),
      ),
    );
  }

  double getStreamProgress() {
    if (status == StreamStatus.running) {
      final Duration duration = endTime.difference(startTime);
      final Duration elapsed = DateTime.now().difference(startTime);
      return elapsed.inSeconds / duration.inSeconds;
    } else {
      return 0.0;
    }
  }
}

class StatusIconButton extends StatelessWidget {
  const StatusIconButton(
      {super.key,
      required this.status,
      required this.id,
      required this.lastUpdated,
      required this.refresh});

  final StreamStatus status;
  final String id;
  final DateTime lastUpdated;
  final Function refresh;

  @override
  Widget build(BuildContext context) {
    if (status == StreamStatus.created) {
      return IconButton(
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
              StreamsController.startStream(ScaffoldMessenger.of(context), id)
                  .then((success) {
                if (success) {
                  refresh();
                }
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

// TODO: Bind this to kafka Consumer and update the UI
class SpeedMonitor extends StatelessWidget {
  const SpeedMonitor(
    String id, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            children: const <Widget>[
              FaIcon(FontAwesomeIcons.caretUp, color: uploadColor, size: 35.0),
              SizedBox(
                child: Text(
                  '987654321MB/s',
                  style: TextStyle(
                    fontSize: 16,
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
        const VerticalDivider(),
        Expanded(
          child: Column(
            children: const <Widget>[
              FaIcon(FontAwesomeIcons.caretDown,
                  color: downloadColor, size: 35.0),
              SizedBox(
                child: Text(
                  '987654321MB/s',
                  style: TextStyle(
                    fontSize: 16,
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
