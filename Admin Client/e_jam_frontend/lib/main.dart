import 'package:e_jam/src/Views/graphs_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'src/Theme/color_schemes.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/Views/home_view.dart';
import 'package:e_jam/src/Views/streams_list-view.dart';
import 'package:e_jam/src/Views/settings_view.dart';
import 'package:e_jam/src/Views/devices_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer(
        builder: (context, ThemeModel theme, child) {
          return MaterialApp(
            title: 'E-Jam',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
            darkTheme:
                ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
            themeMode: theme.themeMode,
            home: const Home(),
          );
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  Widget mainscreen() {
    switch (currentIndex) {
      case 0:
        return const HomeView();
      case 1:
        return const StreamsListView();
      case 2:
        return const DevicesListView();
      case 3:
        return const GraphsListView();
      case 4:
        return const SettingsView();
      default:
        return const HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorlight = [
      const Color.fromARGB(255, 255, 197, 117),
      const Color.fromARGB(255, 255, 117, 117),
    ];

    final colordark = [
      const Color(0xFF001B3D),
      const Color(0xFF003062),
    ];

    return Consumer(
      builder: (context, ThemeModel theme, child) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.isDark ? colordark : colorlight,
                ),
              ),
              // TODO: main graph canvas in the bottom middle of the screen
              child: Scaffold(
                backgroundColor: Colors.transparent,
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white,
                  items: const [
                    BottomNavigationBarItem(
                      icon: FaIcon(FontAwesomeIcons.houseUser),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
            ZoomDrawer(
              menuScreen: MenuScreen(
                setIndex: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
              mainScreen: mainscreen(),
              showShadow: true,
              shadowLayer1Color: const Color.fromARGB(183, 255, 197, 117),
              angle: 0.0,
              slideWidth: 250.0,
              openCurve: Curves.easeIn,
              closeCurve: Curves.easeOut,
            ),
          ],
        );
      },
    );
  }
}

class MenuScreen extends StatefulWidget {
  final ValueSetter setIndex;
  const MenuScreen({Key? key, required this.setIndex}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ThemeModel theme, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
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
              // TODO: controll panel with icons start and camera icon
              Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: theme.colorScheme.onSurface, width: 1),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.only(
                    top: 1, left: 20, right: 20, bottom: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // start and pause icon button
                    IconButton(
                      onPressed: () {},
                      // make icon color red when hover
                      icon: const FaIcon(
                        FontAwesomeIcons.play,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      // make icon color red when hover

                      icon: const FaIcon(
                        FontAwesomeIcons.camera,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.solidFloppyDisk,
                      ),
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
                  widget.setIndex(0);
                  ZoomDrawer.of(context)!.close();
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                iconColor: Colors.deepOrangeAccent,
                title: const Text('Streams'),
                onTap: () {
                  widget.setIndex(1);
                  ZoomDrawer.of(context)!.close();
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.microchip),
                iconColor: Colors.deepPurpleAccent,
                title: const Text('Devices'),
                onTap: () {
                  widget.setIndex(2);
                  ZoomDrawer.of(context)!.close();
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_graph),
                iconColor: Colors.cyanAccent,
                title: const Text('Graphs'),
                onTap: () {
                  widget.setIndex(3);
                  ZoomDrawer.of(context)!.close();
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.gear),
                iconColor: Colors.lightBlueAccent,
                title: const Text('Settings'),
                onTap: () {
                  widget.setIndex(4);
                  ZoomDrawer.of(context)!.close();
                },
              ),
              AboutListTile(
                icon: const Icon(Icons.info),
                applicationName: "E-Jam",
                applicationVersion: "1.0.0",
                applicationIcon: Image.asset("assets/Icon-logo.ico",
                    width: 100, height: 100),
                applicationLegalese: "© 2023 E-Jam",
                aboutBoxChildren: const <Widget>[
                  Text(
                      'E-Jam is a graducation project for Testing, Monitoring, and Debugging Switches.'),
                ],
                child: const Text('About'),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode),
                onPressed: () {
                  theme.toggleTheme();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
