import 'package:e_jam/main.dart';
import 'package:flutter/material.dart';

// the User can attach a graph of a stream or a device or any other data
class GraphsListView extends StatelessWidget {
  const GraphsListView({super.key});

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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Center(
              child: Text('Graph $index'),
            ),
          );
        },
      ),
    );
  }
}
