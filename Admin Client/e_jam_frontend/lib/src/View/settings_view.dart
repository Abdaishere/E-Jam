import 'package:e_jam/main.dart';
import 'package:flutter/material.dart';

// should not be scrollable
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Screen'),
        centerTitle: true,
        leading: const DrawerWidget(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Settings Screen',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
