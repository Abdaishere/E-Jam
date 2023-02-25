import 'dart:math';

import 'package:e_jam/main.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Details_Views/add_stream_view.dart';
import 'package:e_jam/src/View/Details_Views/stream_details_view.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';

class StreamsListView extends StatelessWidget {
  const StreamsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streams',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const DrawerWidget(),
        actions: <Widget>[
          // refresh icon for refreshing the streams list view
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onPressed: () {},
          ),
          // gear icon for settings and preferences related to the streams list view (sort by, filter by, etc.)
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear),
            onPressed: () {},
          ),
          // Explaination icon for details about how the stream card works and what the icons mean and what the colors mean
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleQuestion),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8.0),
            shrinkWrap: true,
            itemCount: 120,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  max(MediaQuery.of(context).copyWith().size.width ~/ 342.0, 1),
              childAspectRatio: 1.6,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 3.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return StreamCard(index: index);
            },
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
}

class AddStreamButton extends StatelessWidget {
  const AddStreamButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'add-stream-button',
      tooltip: 'Add Stream',
      backgroundColor: Colors.blueAccent,
      splashColor: Colors.blueAccent.shade100,
      hoverColor: Colors.blueAccent.shade100,
      focusColor: Colors.blueAccent.shade100,
      mini: true,
      onPressed: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) => const AddStreamView(),
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
            builder: (BuildContext context) => StreamDetailsView(index: index),
            settings: const RouteSettings(name: 'StreamDetailsView'),
          ),
        );
      },
      child: Hero(
        tag: 'stream$index',
        child: Card(
          // should be the color status of the stream (blue (running), red (error, stopped), orange (queued), green (finished, ready))
          surfaceTintColor: Colors.blueAccent,
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 10.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // new icon for new streams (not yet started)
                    // should be another icon for other states streams (running, queued, finished, etc.)
                    // should be a different color for each state
                    // click on the icon to show a card for description of the current state of the stream
                    IconButton(
                      icon: const FaIcon(
                        Icons.new_releases,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {},
                    ),
                    // stream ID
                    Text(
                      'Stream $index',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // menu icon for more options and details (delete, edit, details, etc.)
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.ellipsis),
                      onPressed: () {},
                    ),
                  ],
                ),
                // upload and download speed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: const <Widget>[
                        FaIcon(FontAwesomeIcons.caretUp,
                            color: uploadColor, size: 35.0),
                        SizedBox(
                          width: 155,
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
                    Column(
                      children: const <Widget>[
                        FaIcon(FontAwesomeIcons.caretDown,
                            color: downloadColor, size: 35.0),
                        SizedBox(
                          width: 155,
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.hourglassStart),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.stop),
                      onPressed: () {},
                    ),
                    // TODO: the following should be in a more details view of the stream (not in the list view) and should be accessible from the menu icon
                    // IconButton(
                    //   icon: const FaIcon(FontAwesomeIcons.chartLine),
                    //   onPressed: () {},
                    // ),
                    // IconButton(
                    //   icon: const FaIcon(FontAwesomeIcons.trashCan),
                    //   onPressed: () {},
                    // ),
                    // IconButton(
                    //   icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: 0.7,
                    valueColor:
                        // hormonize the color with the color and status of the stream (blue (running), red (error, stopped), orange (queued), green (finished, ready))
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
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
