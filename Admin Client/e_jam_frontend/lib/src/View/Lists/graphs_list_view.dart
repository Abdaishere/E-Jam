import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Details_Views/device_details_view.dart';
import 'package:e_jam/src/View/Details_Views/stream_details_view.dart';
import 'package:e_jam/src/View/Lists/streams_list_view.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

// the User can attach a graph of a stream or a device or any other data source (Staggered Grid View)
class GraphsListView extends StatefulWidget {
  const GraphsListView({super.key});

  @override
  State<GraphsListView> createState() => _GraphsListViewState();
}

class _GraphsListViewState extends State<GraphsListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pinned Charts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const DrawerWidget(),
      ),
      body: Visibility(
        visible: SystemSettings.pinnedElements.isNotEmpty,
        replacement: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                MaterialCommunityIcons.chart_arc,
                size: 100.0,
                color: Colors.grey,
              ),
              SizedBox(height: 10.0),
              Text(
                'No Pinned Charts Selected',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          itemCount: SystemSettings.pinnedElements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 3.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            Widget graph;
            if (SystemSettings.pinnedElements[index].startsWith("D")) {
              String macAddress =
                  SystemSettings.pinnedElements[index].substring(1);
              graph = Column(
                children: [
                  Text(
                    "Device $macAddress",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Expanded(
                    child: DevicePacketsCounterDoughnut(
                      mac: macAddress,
                    ),
                  ),
                  const Divider(),
                  DeviceSpeedMonitor(mac: macAddress),
                ],
              );
            } else if (SystemSettings.pinnedElements[index].startsWith("S")) {
              String streamId =
                  SystemSettings.pinnedElements[index].substring(1);
              List<StreamEntry> streams =
                  context.read<StreamsController>().getStreams ?? [];

              StreamEntry? stream = streams
                  .lastWhereOrNull((element) => element.streamId == streamId);

              late Process runningGenerators;
              late Process runningVerifiers;

              runningGenerators =
                  stream?.runningGenerators ?? const Process.empty();
              runningVerifiers =
                  stream?.runningVerifiers ?? const Process.empty();
              graph = Column(
                children: [
                  Text(
                    "Stream $streamId",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Expanded(
                    child: StreamGraph(
                      streamId: streamId,
                      runningGenerators: runningGenerators,
                      runningVerifiers: runningVerifiers,
                    ),
                  ),
                  const Divider(),
                  StreamSpeedMonitor(id: streamId),
                ],
              );
            } else {
              graph = const Text("Error");
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
                child: graph,
              ),
            );
          },
        ),
      ),
    );
  }
}
