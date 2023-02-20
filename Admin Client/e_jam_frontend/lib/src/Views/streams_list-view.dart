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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Streams Screen',
            ),
          ],
        ),
      ),
    );
  }
}
