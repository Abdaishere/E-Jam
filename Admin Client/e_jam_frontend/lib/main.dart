import 'dart:ui';

import 'package:e_jam/src/View/Animation/background_bouncing_ball.dart';
import 'package:e_jam/src/View/Charts/bottom_line_chart.dart';
import 'package:e_jam/src/View/Lists/graphs_list_view.dart';
import 'package:e_jam/src/View/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/View/home_view.dart';
import 'package:e_jam/src/View/Lists/streams_list_view.dart';
import 'package:e_jam/src/View/settings_view.dart';
import 'package:e_jam/src/View/Lists/devices_list_view.dart';

void main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Text(
          'Error: ${details.exception}',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  };
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
            title: 'E Jam',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
            darkTheme:
                ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
            themeMode: theme.themeMode,
            home: const Home(),
            // TODO: Add routes
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

  Widget mainScreen() {
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
    return Consumer(
      builder: (context, ThemeModel theme, child) {
        return Stack(
          children: [
            gradientBackground(theme, context),
            BouncingBall(
                color: (theme.isDark ? gradientColorDark : gradientColorLight)),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Container(color: Colors.transparent),
            ),
            bottomLineChartScaffold(context),
            frontBody(),
          ],
        );
      },
    );
  }

  ZoomDrawer frontBody() {
    return ZoomDrawer(
      menuScreen: MenuScreen(
        setIndex: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      mainScreen: mainScreen(),
      androidCloseOnBackTap: true,
      showShadow: true,
      mainScreenTapClose: true,
      shadowLayer1Color: const Color.fromARGB(183, 255, 197, 117),
      angle: 0.0,
      slideWidth: 250.0,
      openCurve: Curves.easeIn,
      closeCurve: Curves.easeOut,
    );
  }

  Scaffold bottomLineChartScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        padding: const EdgeInsets.only(left: 200),
        height: MediaQuery.of(context).size.height * 0.14,
        child: const BottomLineChart(),
      ),
    );
  }

  Container gradientBackground(ThemeModel theme, BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.isDark ? gradientColorDark : gradientColorLight,
          transform: const GradientRotation(0.5),
        ),
        backgroundBlendMode: BlendMode.darken,
      ),
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
  bool isSwitched = true;
  bool isFrozen = false;
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
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: IconButton(
                  onPressed: () {
                    ZoomDrawer.of(context)!.close();
                  },
                  color: theme.colorScheme.secondary,
                  icon: const Icon(Icons.arrow_forward_ios_outlined),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              // TODO: control panel with icons start and camera icon and save icon
              Container(
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: theme.colorScheme.secondary, width: 1),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.only(
                    top: 1, left: 20, right: 20, bottom: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // start and pause icon button
                    IconButton(
                      tooltip: isSwitched ? 'Pause' : 'Start',
                      onPressed: () {
                        setState(() {
                          isSwitched = !isSwitched;
                        });
                      },
                      color: !isSwitched
                          ? theme.colorScheme.error
                          : theme.colorScheme.secondary,
                      icon: FaIcon(
                        isSwitched
                            ? FontAwesomeIcons.play
                            : FontAwesomeIcons.pause,
                        size: 21,
                      ),
                    ),
                    IconButton(
                      tooltip: isFrozen ? 'Unfreeze Graphs' : 'Freeze Graphs',
                      onPressed: () {
                        setState(() {
                          isFrozen = !isFrozen;
                        });
                      },
                      color: isFrozen
                          ? theme.colorScheme.surfaceTint
                          : theme.colorScheme.secondary,
                      icon: FaIcon(
                          isFrozen
                              ? FontAwesomeIcons.solidSnowflake
                              : FontAwesomeIcons.camera,
                          size: 21),
                    ),
                    IconButton(
                      tooltip: 'Save as CSV or PDF',
                      onPressed: () {},
                      color: theme.colorScheme.secondary,
                      icon: const FaIcon(
                        FontAwesomeIcons.solidFloppyDisk,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.035),
              ListTile(
                leading: const Icon(MaterialCommunityIcons.home),
                iconColor: Colors.white,
                title: const Text('Home'),
                onTap: () {
                  widget.setIndex(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                iconColor: Colors.blueAccent,
                title: const Text('Streams'),
                onTap: () {
                  widget.setIndex(1);
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.microchip, size: 21),
                iconColor: Colors.deepOrangeAccent,
                title: const Text('Devices'),
                onTap: () {
                  widget.setIndex(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_graph_outlined),
                iconColor: Colors.deepPurpleAccent,
                title: const Text('Charts'),
                onTap: () {
                  widget.setIndex(3);
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.gears, size: 21),
                iconColor: Colors.blueGrey.shade500,
                title: const Text('Settings'),
                onTap: () {
                  widget.setIndex(4);
                },
              ),
              AboutListTile(
                icon: const Icon(MaterialCommunityIcons.information, size: 21),
                applicationName: "E-Jam",
                applicationVersion: "1.0.0",
                applicationIcon: Image.asset("assets/Icon-logo.ico",
                    width: 100, height: 100),
                applicationLegalese: "© 2023 E-Jam",
                aboutBoxChildren: const <Widget>[
                  Text(
                      'E-Jam is a System Environment for Testing, Monitoring, and Debugging Switches.\n',
                      style: TextStyle(fontSize: 15)),
                  Text('Developed by:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('\tAbdullah Elbelkasy'),
                  Text('\tMohamed Elhagery'),
                  Text('\tKhaled Waleed'),
                  Text('\tIslam Wagih'),
                  Text('\tMostafa Abdullah'),
                ],
                child: const Text('About'),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(right: 50),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Change Switch',
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 25),
                    IconButton(
                      icon: Icon(
                          theme.isDark ? Icons.dark_mode : Icons.light_mode),
                      onPressed: () {
                        theme.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
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
      icon: const Icon(MaterialCommunityIcons.menu),
    );
  }
}
