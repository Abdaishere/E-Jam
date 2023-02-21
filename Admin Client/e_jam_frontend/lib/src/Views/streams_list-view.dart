import 'package:e_jam/main.dart';
import 'package:flutter/material.dart';

class StreamsListView extends StatelessWidget {
  const StreamsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streams List Screen'),
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
              child: Text('Stream $index'),
            ),
          );
        },
      ),
    );
  }
}
