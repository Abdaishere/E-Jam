import 'dart:math';

import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/View/Charts/Dynamic%20Charts/dynamic_doughnut_chart_packets.dart';
import 'package:e_jam/src/View/Charts/Dynamic%20Charts/dynamic_line_chart_stream.dart';
import 'package:e_jam/src/View/Charts/Dynamic%20Charts/dynamic_pie_chart_devices_per_stream.dart';
import 'package:e_jam/src/View/Charts/pie_chart_devices_per_stream.dart';
import 'package:flutter/material.dart';

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
      body: GridView.builder(
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 2
                  : 3,
        ),
        itemBuilder: (BuildContext context, int index) {
          Widget randomWidget = [
            DynamicDoughnutChartPackets(packetsState()),
            DynamicLineChartStream(index.toString()),
            DynamicPieDevices(initRunningProcesses(
                completed: 1, failed: 1, queued: 1, running: 1, stopped: 1)),
          ][Random().nextInt(3)];
          return Card(
            child: Center(child: randomWidget),
          );
        },
      ),
    );
  }
}
