import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/Animation/background_bouncing_ball.dart';
import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/View/extensions/bottom_line_chart.dart';
import 'package:e_jam/src/View/Lists/graphs_list_view.dart';
import 'package:e_jam/src/View/change_server_ip_screen.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
import 'package:e_jam/src/controller/streams_controller.dart';
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
      ],
      child: Consumer(
        builder: (context, ThemeModel themeModel, child) => MaterialApp(
          title: 'E Jam',
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
        const BottomLineChartScaffold(),
        frontBody(
          context.watch<ThemeModel>().isDark
              ? const Color.fromARGB(183, 255, 197, 117)
              : const Color.fromARGB(183, 2, 105, 240),
        ),
      ],
    );
  }

  ZoomDrawer frontBody(Color shadowColor) {
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
      shadowLayer1Color: shadowColor,
      angle: 0.0,
      slideWidth: 250.0,
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
        height: 100,
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

class MenuScreen extends StatefulWidget {
  final ValueSetter setIndex;
  const MenuScreen({Key? key, required this.setIndex}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
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
              color: context.watch<ThemeModel>().colorScheme.secondary,
              icon: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ),
          const SizedBox(height: 20),
          // TODO: control panel with icons start and camera icon and export button
          Container(
            margin: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: context.watch<ThemeModel>().colorScheme.secondary,
                  width: 1),
              borderRadius: BorderRadius.circular(18),
            ),
            padding:
                const EdgeInsets.only(top: 1, left: 20, right: 20, bottom: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StreamsControllerButton(),
                GraphsControllerButton(),
                ExportButton(),
              ],
            ),
          ),
          const SizedBox(height: 25),
          ListTile(
            leading: const FaIcon(FontAwesome.dashboard),
            iconColor: Colors.white,
            title: const Text('Dashboard'),
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
            applicationVersion: "1.0.2",
            applicationIcon:
                Image.asset("assets/Icon-logo.ico", width: 100, height: 100),
            applicationLegalese: "© 2023 E-Jam",
            aboutBoxChildren: const <Widget>[
              Text(
                  'E-Jam is a System Environment for Testing, Monitoring, and Debugging Switches.\n',
                  style: TextStyle(fontSize: 15)),
              Text('Developed by:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                        settings: const RouteSettings(name: 'ChangeServerView'),
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
    );
  }
}

class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Export as CSV or PDF',
      onPressed: () async {},
      color: context.watch<ThemeModel>().colorScheme.secondary,
      icon: const FaIcon(
        FontAwesomeIcons.solidFloppyDisk,
        size: 21,
      ),
    );
  }
}

class StreamsControllerButton extends StatefulWidget {
  const StreamsControllerButton({super.key});

  @override
  State<StreamsControllerButton> createState() =>
      _StreamsControllerButtonState();
}

class _StreamsControllerButtonState extends State<StreamsControllerButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: SystemSettings.streamsAreRunning ? 'Pause' : 'Start',
      onPressed: () async => SystemSettings.streamsAreRunning
          ? context
              .read<StreamsController>()
              .stopAllStreams()
              .then((value) async {
              if (value && mounted) {
                setState(() {
                  SystemSettings.streamsAreRunning =
                      !SystemSettings.streamsAreRunning;
                });
                final pref = await SharedPreferences.getInstance();
                pref.setBool(
                    'streamsAreRunning', SystemSettings.streamsAreRunning);
              }
            })
          : context
              .read<StreamsController>()
              .startAllStreams()
              .then((value) async {
              if (value && mounted) {
                setState(() {
                  SystemSettings.streamsAreRunning =
                      !SystemSettings.streamsAreRunning;
                });
                final pref = await SharedPreferences.getInstance();
                pref.setBool(
                    'streamsAreRunning', SystemSettings.streamsAreRunning);
              }
            }),
      color: SystemSettings.streamsAreRunning
          ? context.watch<ThemeModel>().colorScheme.secondary
          : context.watch<ThemeModel>().colorScheme.error,
      icon: FaIcon(
        SystemSettings.streamsAreRunning
            ? FontAwesomeIcons.play
            : FontAwesomeIcons.pause,
        size: 21,
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
      onPressed: () {
        setState(() {
          SystemSettings.chartsAreRunning = !SystemSettings.chartsAreRunning;
        });
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
