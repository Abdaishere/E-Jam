import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Charts/line_chart_stream.dart';
import 'package:e_jam/src/View/Charts/pie_chart_devices_per_stream.dart';
import 'package:e_jam/src/View/Charts/stream_progress_bar.dart';
import 'package:e_jam/src/View/Lists/streams_list_view.dart';
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

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'stream$id',
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: SizedBox(
        // Should fit all the input fields of the Stream Details
        // When clicking on generators or verifiers the screen should open the Devices list view in a card view and the user should be able to select devices from the list view and add them to the stream details
        // Try to make the card view as a drawer that slides in from the right side of the screen or from the left side of the screen (drawer approach)
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
                        child: StreamFieldsDetails(id),
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
            StreamsController.startStream(ScaffoldMessenger.of(context), id);
            // reload();
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.hourglassStart),
          color: status == StreamStatus.queued ? streamQueuedColor : null,
          tooltip: "Delay",
          onPressed: () {
            StreamsController.queueStream(ScaffoldMessenger.of(context), id);
            // reload();
          },
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.stop),
          color: status == StreamStatus.stopped ? streamStoppedColor : null,
          tooltip: "Stop",
          onPressed: () {
            StreamsController.stopStream(ScaffoldMessenger.of(context), id);
            // reload();
          },
        ),
      ],
    );
  }
}

class StreamFieldsDetails extends StatefulWidget {
  const StreamFieldsDetails(this.id, {super.key});

  final String id;
  @override
  State<StreamFieldsDetails> createState() => _StreamFieldsDetailsState();
}

class _StreamFieldsDetailsState extends State<StreamFieldsDetails> {
  get id => widget.id;
  @override
  Widget build(BuildContext context) {
    return const Text(loremIpsum);
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
