import 'package:e_jam/main.dart';
import 'package:flutter/material.dart';

// should include but not limited to:
// TODO: Disable animation for system button
// TODO: Change Line charts curve to smooth
// TODO: Change Order and types of extensions in main screen
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
