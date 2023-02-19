import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'src/Theme/color_schemes.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Jam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const ZoomDrawer(
      menuScreen: MenuScreen(),
      mainScreen: MainScreen(),
      showShadow: true,
      shadowLayer1Color: Color.fromARGB(183, 255, 197, 117),
      angle: 0.0,
      slideWidth: 250.0,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.easeIn,
      menuBackgroundColor:
          Color(0x00000000), // TODO: add global graph behind menu
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // back button to close drawer menu
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: IconButton(
              onPressed: () {
                ZoomDrawer.of(context)!.close();
              },
              icon: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ),
          const SizedBox(height: 40),
          // controll panel with icons start and camera icon
          Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // start and pause icon button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.save),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.home),
            iconColor: Colors.white,
            title: const Text('Home'),
            onTap: () {
              ZoomDrawer.of(context)!.close();
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            iconColor: Colors.deepOrangeAccent,
            title: const Text('Streams'),
            onTap: () {
              ZoomDrawer.of(context)!.close();
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            iconColor: Colors.purpleAccent,
            title: const Text('Devices'),
            onTap: () {
              ZoomDrawer.of(context)!.close();
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph),
            iconColor: Colors.cyanAccent,
            title: const Text('Graphs'),
            onTap: () {
              ZoomDrawer.of(context)!.close();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            iconColor: Colors.grey,
            title: const Text('Settings'),
            onTap: () {
              ZoomDrawer.of(context)!.close();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            iconColor: Colors.orangeAccent,
            title: const Text('About'),
            onTap: () {
              ZoomDrawer.of(context)!.close();
            },
          ),
          // change drack mode
          const SizedBox(height: 100),
          ListTile(
            leading: const Icon(Icons.nightlight_round),
            title: const Text('Dark Mode'),
            onTap: () {
              ZoomDrawer.of(context)!.close();
            },
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

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

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        ZoomDrawer.of(context)!.toggle();
      },
      icon: const Icon(Icons.menu),
    );
  }
}
