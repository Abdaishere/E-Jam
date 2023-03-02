import 'dart:math';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconsElementsSystem extends StatefulWidget {
  const IconsElementsSystem({super.key});

  @override
  State<IconsElementsSystem> createState() => _IconsElementsSystemState();
}

class _IconsElementsSystemState extends State<IconsElementsSystem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'System Elements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.microchip,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Devices'),
                      color: Colors.deepOrangeAccent,
                      tooltip: 'System Devices',
                      onPressed: () {},
                    ),
                    Text(
                      '7',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                      icon: Icon(MaterialCommunityIcons.connection,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Devices'),
                      color: deviceRunningOrOnlineColor,
                      tooltip: 'Running Devices',
                      onPressed: () {},
                    ),
                    Text(
                      '4',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                      icon: Icon(MaterialCommunityIcons.connection,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Devices'),
                      color: deviceOfflineOrErrorColor,
                      tooltip: 'Offline Devices',
                      onPressed: () {},
                    ),
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                        child: Icon(MaterialCommunityIcons.progress_upload,
                            size: MediaQuery.of(context).size.width * 0.023,
                            semanticLabel: 'Processes'),
                      ),
                      color: uploadColor,
                      tooltip: 'System Generators',
                      onPressed: () {},
                    ),
                    Text(
                      '7',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                      icon: Icon(MaterialCommunityIcons.progress_check,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Processes'),
                      color: downloadColor,
                      tooltip: 'System Verifiers',
                      onPressed: () {},
                    ),
                    Text(
                      '742',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(MaterialCommunityIcons.view_dashboard,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Streams'),
                      color: Colors.blueAccent,
                      tooltip: 'System Streams',
                      onPressed: () {},
                    ),
                    Text(
                      '26',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                      icon: Icon(MaterialCommunityIcons.lan_connect,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Streams'),
                      color: streamRunningColor,
                      tooltip: 'Running Streams',
                      onPressed: () {},
                    ),
                    Text(
                      '12',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                      icon: Icon(MaterialCommunityIcons.lan_disconnect,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Streams'),
                      color: streamErrorColor,
                      tooltip: 'Error Streams',
                      onPressed: () {},
                    ),
                    Text(
                      '2',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                      icon: Icon(MaterialCommunityIcons.lan_check,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Streams'),
                      color: streamFinishedColor,
                      tooltip: 'Finished Streams',
                      onPressed: () {},
                    ),
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
                      icon: Icon(MaterialCommunityIcons.lan_pending,
                          size: MediaQuery.of(context).size.width * 0.023,
                          semanticLabel: 'Streams'),
                      color: streamQueuedColor,
                      tooltip: 'Queued Streams',
                      onPressed: () {},
                    ),
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
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
          ),
        ),
      ],
    );
  }
}
