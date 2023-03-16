import 'dart:math';

import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_stream_view.dart';
import 'package:e_jam/src/View/Details_Views/stream_details_view.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StreamsListView extends StatefulWidget {
  const StreamsListView({super.key});

  @override
  State<StreamsListView> createState() => _StreamsListViewState();
}

class _StreamsListViewState extends State<StreamsListView> {
  get scaffoldMessenger => ScaffoldMessenger.of(context);
  get controllerStreams => StreamsController.streams;
  get controllerIsStreamListLoading => StreamsController.isStreamListLoading;

  List<StreamEntry>? streams;
  bool isStreamListLoading = true;
  void loadStreamView() async {
    // change the state of the widget
    StreamsController.loadStreams(scaffoldMessenger).then(
      (value) => {
        if (mounted)
          setState(() {
            streams = controllerStreams;
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
      appBar: streamListViewAppBar(),
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
              visible: streams?.isNotEmpty ?? false,
              replacement: Visibility(
                visible: streams != null,
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
                  return StreamCard(index: index);
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

  AppBar streamListViewAppBar() {
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
          onPressed: () {},
        ),
        // gear icon for settings and preferences related to the streams list view (sort by, filter by, etc.)
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.gear, size: 20.0),
          onPressed: () {},
        ),
        // Explanation icon for details about how the stream card works and what the icons mean and what the colors mean
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.circleQuestion, size: 20.0),
          onPressed: () {},
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
            builder: (BuildContext context) =>
                const Center(child: AddStreamView()),
            settings: const RouteSettings(name: 'AddStreamView'),
          ),
        );
      },
      child: const FaIcon(FontAwesomeIcons.plus),
    );
  }
}

class StreamCard extends StatefulWidget {
  const StreamCard({super.key, required this.index});

  final int index;

  @override
  State<StreamCard> createState() => _StreamCardState();
}

class _StreamCardState extends State<StreamCard> {
  get index => widget.index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) =>
                Center(child: StreamDetailsView(index)),
            settings: const RouteSettings(name: 'StreamDetailsView'),
          ),
        );
      },
      child: Hero(
        tag: 'stream$index',
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 15.0, left: 8.0, right: 8.0, bottom: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // new icon for new streams (not yet started)
                    IconButton(
                      tooltip: 'New Stream',
                      icon: const FaIcon(
                        Icons.new_releases,
                        color: Colors.blueAccent,
                        size: 20.0,
                      ),
                      onPressed: () {
                        showDialog(
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
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Start'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // stream ID
                    Text(
                      'Stream $index',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // menu icon for more options and details (delete, edit, details, etc.) for the stream card (should be in a popup menu button)
                    // on click should show a card with the details of the stream with edit and delete options for the stream and the graphs of the stream
                    // see if you need to add a new icon for a task for quick access to the stream task
                    PopupMenuButton(
                      tooltip: 'More Options',
                      icon: const FaIcon(
                        Icons.more_vert,
                        size: 20.0,
                      ),
                      onSelected: (dynamic value) {
                        if (value == 'Details') {
                          Navigator.of(context).push(
                            HeroDialogRoute(
                              builder: (BuildContext context) =>
                                  Center(child: StreamDetailsView(index)),
                              settings: const RouteSettings(
                                  name: 'StreamDetailsView'),
                            ),
                          );
                        } else if (value == 'Delete') {
                          // delete the stream
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Delete Stream'),
                              content: Text(
                                  'Are you sure you want to delete stream $index?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        } else if (value == 'Edit') {
                          // edit the stream
                          // Navigator.of(context).push(
                          //   HeroDialogRoute(
                          //     builder: (BuildContext context) =>
                          //         EditStreamView(index), TODO: add edit stream view
                          //     settings:
                          //         const RouteSettings(name: 'EditStreamView'),
                          //   ),
                          // );
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
                                Icon(MaterialCommunityIcons.pencil,
                                    color: Colors.green),
                                SizedBox(width: 10.0),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Delete',
                            child: Row(
                              children: const [
                                FaIcon(MaterialCommunityIcons.trash_can,
                                    color: Colors.red),
                                SizedBox(width: 10.0),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                // upload and download speed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: const <Widget>[
                          FaIcon(FontAwesomeIcons.caretUp,
                              color: uploadColor, size: 35.0),
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
                ),
                // delay, start, stop, delete, edit, progress bar
                // status icons should be the status of the stream (running, error, stopped, queued, finished, ready) and stream name (Alphanumeric 3 letters long names) and menu icon for more options and details
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.play),
                      tooltip: "Start",
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.hourglassStart),
                      tooltip: "Delay",
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.stop),
                      tooltip: "Stop",
                      onPressed: () {},
                    ),
                  ],
                ),
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    valueColor:
                        // harmonize the color with the color and status of the stream (blue (running), red (error, stopped), orange (queued), green (finished, ready))
                        AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
