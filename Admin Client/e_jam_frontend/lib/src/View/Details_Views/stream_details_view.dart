import 'package:e_jam/src/Model/fake_chart_data.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Charts/line_chart_stream.dart';
import 'package:e_jam/src/View/Charts/pie_chart_devices_per_stream.dart';
import 'package:e_jam/src/View/Charts/stream_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StreamDetailsView extends StatefulWidget {
  const StreamDetailsView(this.index, {super.key});
  final int index;

  @override
  State<StreamDetailsView> createState() => _StreamDetailsViewState();
}

class _StreamDetailsViewState extends State<StreamDetailsView> {
  get index => widget.index;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'stream$index',
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: SizedBox(
        // Should fit all the input fields of the Stream Details
        // When clicking on generators or verifiers the screen should open the Devices list view in a card view and the user should be able to select devices from the list view and add them to the stream details
        // Try to make the card view as a drawer that slides in from the right side of the screen or from the left side of the screen (drawer approach)
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Stream $index',
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.trash_can),
                  color: Colors.red,
                  onPressed: () {},
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
                        child: StreamGraph(index),
                      ),
                      Expanded(
                        flex: 2,
                        child: StreamFieldsDetails(index),
                      ),
                    ],
                  ),
                ),
                ProgressStreamDetails(index),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StreamFieldsDetails extends StatefulWidget {
  const StreamFieldsDetails(this.index, {super.key});

  final int index;
  @override
  State<StreamFieldsDetails> createState() => _StreamFieldsDetailsState();
}

class _StreamFieldsDetailsState extends State<StreamFieldsDetails> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return const Text(loremIpsum);
  }
}

class StreamGraph extends StatefulWidget {
  const StreamGraph(this.index, {super.key});

  final int index;
  @override
  State<StreamGraph> createState() => _StreamGraphState();
}

class _StreamGraphState extends State<StreamGraph> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: LineChartStream(index),
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

class ProgressStreamDetails extends StatefulWidget {
  const ProgressStreamDetails(this.index, {super.key});
  final int index;

  @override
  State<ProgressStreamDetails> createState() => _ProgressStreamDetailsState();
}

class _ProgressStreamDetailsState extends State<ProgressStreamDetails> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StreamProgressBar(index),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
        )
      ],
    );
  }
}
