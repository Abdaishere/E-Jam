import 'package:e_jam/main.dart';
import 'package:flutter/material.dart';

// should not be scrollable
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
        leading: const DrawerWidget(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Home Screen',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
