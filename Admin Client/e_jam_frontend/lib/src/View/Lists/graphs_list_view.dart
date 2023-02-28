import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/fake_chart_data.dart';
import 'package:e_jam/src/View/Charts/doughnut_chart_packets.dart';
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
        title: const Text('Graphs List Screen'),
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
          return Card(
            child: Center(
              child: DoughnutChartPackets(packetsState),
            ),
          );
        },
      ),
    );
  }
}
