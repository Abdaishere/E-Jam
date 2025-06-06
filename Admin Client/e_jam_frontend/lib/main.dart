import 'dart:async';

import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Animation/background_bouncing_ball.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/export_button.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/streams_start_stop_controller_buttons.dart';
import 'package:e_jam/src/View/extensions/bottom_line_chart.dart';
import 'package:e_jam/src/View/Lists/graphs_list_view.dart';
import 'package:e_jam/src/View/change_server_ip_screen.dart';
import 'package:e_jam/src/controller/Devices/add_device_controller.dart';
import 'package:e_jam/src/controller/Devices/edit_device_controller.dart';
import 'package:e_jam/src/controller/Streams/add_stream_controller.dart';
import 'package:e_jam/src/controller/Streams/edit_stream_controller.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

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
  // init shared preferences
  SystemSettings.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => BackgroundBallNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => BottomLineChartNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => DevicesController(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddDeviceController(),
        ),
        ChangeNotifierProvider(
          create: (_) => EditDeviceController(),
        ),
        ChangeNotifierProvider(
          create: (_) => StreamsController(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddStreamController(),
        ),
        ChangeNotifierProvider(
          create: (_) => EditStreamController(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsController(),
        ),
      ],
      child: Consumer(
        builder: (context, ThemeModel themeModel, child) => MaterialApp(
          title: 'E-Jam',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme:
              ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          themeMode: themeModel.themeMode,
          home: const Home(),
        ),
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
  Timer? _timer;
  Timer? _timer2;
  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) async {
      if (SystemSettings.chartsAreRunning) {
        await context.read<StatisticsController>().loadAllVerifierStatistics();
      }
    });
    _timer2 = Timer.periodic(const Duration(seconds: 8), (timer) async {
      if (SystemSettings.chartsAreRunning) {
        await context.read<StatisticsController>().loadAllGeneratorStatistics();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer2?.cancel();
    super.dispose();
  }

  int currentIndex = 0;

  Widget mainScreen() {
    switch (currentIndex) {
      case 0:
        return const DashBoardView();
      case 1:
        return const StreamsListView();
      case 2:
        return const DevicesListView();
      case 3:
        return const GraphsListView();
      case 4:
        return const SettingsView();
      default:
        return const DashBoardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const GradientBackground(),
        if (context.watch<BackgroundBallNotifier>().showBackgroundBall)
          const BouncingBall(),
        // first check if the server ip is not empty when the app is first opened
        NetworkController.serverIpAddress.host.isNotEmpty
            ? const BottomLineChartScaffold()
            : const SizedBox.shrink(),
        NetworkController.serverIpAddress.host.isNotEmpty
            ? frontBody()
            : Center(child: ChangeServerIPScreen(reloader: () {
                setState(() {});
              }))
      ],
    );
  }

  ZoomDrawer frontBody() {
    Color shadowColor = context.watch<ThemeModel>().isDark
        ? const Color.fromARGB(183, 255, 197, 117)
        : const Color.fromARGB(183, 2, 105, 240);
    return ZoomDrawer(
      menuScreen: MenuScreen(
        setIndex: (index) {
          currentIndex = index;
          setState(() {});
        },
      ),
      mainScreen: mainScreen(),
      androidCloseOnBackTap: true,
      showShadow: true,
      mainScreenTapClose: true,
      shadowLayer1Color: shadowColor,
      angle: 0.0,
      slideWidth: 280.0,
      mainScreenScale: 0.28,
      mainScreenAbsorbPointer: false,
      openCurve: Curves.easeIn,
      closeCurve: Curves.easeOut,
    );
  }
}

class BottomLineChartScaffold extends StatelessWidget {
  const BottomLineChartScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        padding: const EdgeInsets.only(left: 200),
        height: 90,
        color: MediaQuery.of(context).orientation == Orientation.landscape
            ? null
            : Colors.transparent,
        child: MediaQuery.of(context).orientation == Orientation.landscape &&
                context.watch<BottomLineChartNotifier>().showBottomLineChart
            ? const BottomLineChart()
            : const SizedBox.shrink(),
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.watch<ThemeModel>().isDark
              ? gradientColorDark
              : gradientColorLight,
          transform: const GradientRotation(0.5),
        ),
        backgroundBlendMode: BlendMode.darken,
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key, required this.setIndex}) : super(key: key);

  final ValueSetter setIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // back button to close drawer menu
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: IconButton(
                onPressed: () {
                  ZoomDrawer.of(context)!.close();
                },
                color: context.watch<ThemeModel>().colorScheme.secondary,
                icon: const Icon(Icons.arrow_forward_ios_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                border: Border.all(
                    color: context.watch<ThemeModel>().colorScheme.secondary,
                    width: 1),
                borderRadius: BorderRadius.circular(18),
              ),
              padding:
                  const EdgeInsets.only(top: 1, left: 10, right: 10, bottom: 1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamsStartStopControllerButtons(isStopping: false),
                  StreamsStartStopControllerButtons(isStopping: true),
                  GraphsControllerButton(),
                  ExportButton(),
                ],
              ),
            ),
            const SizedBox(height: 25),
            MenuList(setIndex: setIndex),
            const Spacer(),

            Container(
              margin: const EdgeInsets.only(right: 60),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Change Server',
                    icon: const Icon(MaterialCommunityIcons.server_network),
                    onPressed: () {
                      Navigator.of(context).push(
                        HeroDialogRoute(
                          builder: (BuildContext context) => const Center(
                            child: ChangeServerIPScreen(),
                          ),
                          settings:
                              const RouteSettings(name: 'ChangeServerView'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 25),
                  IconButton(
                    icon: Icon(
                      context.watch<ThemeModel>().isDark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    onPressed: () async {
                      context.read<ThemeModel>().toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class MenuList extends StatelessWidget {
  const MenuList({
    super.key,
    required this.setIndex,
  });

  static const double size = 21;
  final ValueSetter setIndex;
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      style: ListTileStyle.drawer,
      dense: MediaQuery.of(context).size.height < 600,
      enableFeedback: true,
      contentPadding: const EdgeInsets.only(left: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.gaugeHigh, size: size),
            iconColor: Colors.white,
            title: const Text('Dashboard'),
            onTap: () {
              setIndex(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            iconColor: Colors.blueAccent,
            title: const Text('Streams'),
            onTap: () {
              setIndex(1);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.microchip, size: size),
            iconColor: Colors.deepOrangeAccent,
            title: const Text('Devices'),
            onTap: () {
              setIndex(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph_outlined),
            iconColor: Colors.deepPurpleAccent,
            title: const Text('Charts'),
            onTap: () {
              setIndex(3);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.gears, size: size),
            iconColor: Colors.blueGrey.shade500,
            title: const Text('Settings'),
            onTap: () {
              setIndex(4);
            },
          ),
          AboutListTile(
            icon: const Icon(MaterialCommunityIcons.information, size: size),
            applicationName: "E-Jam",
            applicationVersion: "1.1.2",
            applicationIcon:
                Image.asset("assets/Icon-logo.ico", width: 100, height: 100),
            applicationLegalese: "© 2023 E-Jam",
            aboutBoxChildren: const <Widget>[
              Text(
                  'Introducing E-Jam - the ultimate system environment for testing, monitoring, and debugging switches.'),
              Text(
                  '\n\nOur team of experts, including Abdullah Elbelkasy, Mohamed Elhagery, Khaled Waleed, Islam Wagih, and Mostafa Abdullah, has developed this tool to help you in the way you manage your Network Switches.'),
              Text(
                  "\nWith E-Jam, you'll have access to a powerful suite of features that make monitoring, testing, and debugging switches a breeze."),
              Text(
                  '\nOur user-friendly front-end application is designed to provide you with real-time insights and analytics, making it easier than ever to identify and resolve issues.'),
              Text(
                  "\nWhether you're a seasoned IT professional or just starting out, E-Jam is the perfect tool for streamlining your workflow and maximizing your productivity. ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
            child: const Text('About'),
          ),
        ],
      ),
    );
  }
}

class GraphsControllerButton extends StatefulWidget {
  const GraphsControllerButton({super.key});

  @override
  State<GraphsControllerButton> createState() => _GraphsControllerButtonState();
}

class _GraphsControllerButtonState extends State<GraphsControllerButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip:
          SystemSettings.chartsAreRunning ? 'Freeze Graphs' : 'Unfreeze Graphs',
      onPressed: () async {
        setState(() {
          SystemSettings.chartsAreRunning = !SystemSettings.chartsAreRunning;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
            'chartsAreRunning', SystemSettings.chartsAreRunning);
      },
      color: SystemSettings.chartsAreRunning
          ? context.watch<ThemeModel>().colorScheme.secondary
          : context.watch<ThemeModel>().colorScheme.surfaceTint,
      icon: FaIcon(
          SystemSettings.chartsAreRunning
              ? FontAwesomeIcons.camera
              : FontAwesomeIcons.solidSnowflake,
          size: 21),
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
