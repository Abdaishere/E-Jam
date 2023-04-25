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
    return SizedBox(
      width: 350,
      height: 280,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(8),
        )),
        child: Column(
          children: [
            const SizedBox(height: 5),
            const Text(
              'Elements',
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
                          icon: const FaIcon(FontAwesomeIcons.microchip,
                              semanticLabel: 'Devices'),
                          color: Colors.deepOrangeAccent,
                          tooltip: 'System Devices',
                          onPressed: () {},
                        ),
                        const Text(
                          '7',
                          style: TextStyle(
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
                          icon: const Icon(MaterialCommunityIcons.connection,
                              semanticLabel: 'Devices'),
                          color: deviceRunningOrOnlineColor,
                          tooltip: 'Running Devices',
                          onPressed: () {},
                        ),
                        const Text(
                          '4',
                          style: TextStyle(
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
                          icon: const Icon(MaterialCommunityIcons.connection,
                              semanticLabel: 'Devices'),
                          color: deviceOfflineOrErrorColor,
                          tooltip: 'Offline Devices',
                          onPressed: () {},
                        ),
                        const Text(
                          '1',
                          style: TextStyle(
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
                                semanticLabel: 'Processes'),
                          ),
                          color: uploadColor,
                          tooltip: 'System Generators',
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
                          icon: const Icon(
                              MaterialCommunityIcons.progress_check,
                              semanticLabel: 'Processes'),
                          color: downloadColor,
                          tooltip: 'System Verifiers',
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
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(
                              MaterialCommunityIcons.view_dashboard,
                              semanticLabel: 'Streams'),
                          color: Colors.blueAccent,
                          tooltip: 'System Streams',
                          onPressed: () {},
                        ),
                        const Text(
                          '26',
                          style: TextStyle(
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
                          icon: const Icon(MaterialCommunityIcons.lan_connect,
                              semanticLabel: 'Streams'),
                          color: streamRunningColor,
                          tooltip: 'Running Streams',
                          onPressed: () {},
                        ),
                        const Text(
                          '12',
                          style: TextStyle(
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
                              semanticLabel: 'Streams'),
                          color: streamErrorColor,
                          tooltip: 'Error Streams',
                          onPressed: () {},
                        ),
                        const Text(
                          '2',
                          style: TextStyle(
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
                          icon: const Icon(MaterialCommunityIcons.lan_check,
                              semanticLabel: 'Streams'),
                          color: streamFinishedColor,
                          tooltip: 'Finished Streams',
                          onPressed: () {},
                        ),
                        const Text(
                          '5',
                          style: TextStyle(
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
                          icon: const Icon(MaterialCommunityIcons.lan_pending,
                              semanticLabel: 'Streams'),
                          color: streamQueuedColor,
                          tooltip: 'Queued Streams',
                          onPressed: () {},
                        ),
                        const Text(
                          '5',
                          style: TextStyle(
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
        ),
      ),
    );
  }
}
