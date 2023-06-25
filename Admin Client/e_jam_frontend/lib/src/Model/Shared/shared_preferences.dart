import 'package:e_jam/src/services/devices_services.dart';
import 'package:e_jam/src/services/stream_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ThemePreferences {
  static const String _themeMode = 'themeMode';

  Future<ThemeMode> getThemeMode() async {
    final pref = await SharedPreferences.getInstance();
    final themeMode = pref.getString(_themeMode);
    if (themeMode == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhere((e) => e.toString() == themeMode);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_themeMode, themeMode.toString());
  }

  Future<bool> isDarkMode() async {
    final themeMode = await getThemeMode();
    switch (themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      default:
        return true;
    }
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    if (isDarkMode) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}

class NetworkController {
  static Uri serverIpAddress = Uri.parse('');
  static final client = http.Client();
  static Duration timeout = const Duration(minutes: 60);

  static changeServerIpAddress(String newIpAddress, String newPort) async {
    if (newPort == "") {
      newPort = "8084";
    }
    serverIpAddress = Uri.parse('http://$newIpAddress:$newPort');
    DevicesServices.uri.replace(
        scheme: serverIpAddress.scheme,
        host: serverIpAddress.host,
        port: serverIpAddress.port);

    DevicesServices.uri = Uri.parse('$serverIpAddress/devices');
    StreamServices.uri = Uri.parse('$serverIpAddress/streams');
    final pref = await SharedPreferences.getInstance();
    pref.setString('serverIpAddress', serverIpAddress.host);
    pref.setInt('serverPort', serverIpAddress.port);
  }
}

class SystemSettings {
  static bool showChartsAnimation = true;
  static bool lineGraphCurveSmooth = true;
  static bool showBottomLineChart = true;
  // maybe add this to the settings
  static int lineGraphMaxDataPoints = 150;
  static bool showBackgroundBall = true;
  static bool fullChartsDetails = false;
  static bool chartsExplode = true;
  static bool showDashboardAnimations = true;
  static bool showTreeMap = true;
  static bool fullTreeMap = true;
  static List<String> dashboardExtensionsOrder = [
    "1Progress",
    "1Elements",
    "1Performance"
  ];
  // starts with D for device S for stream
  static List<String> pinnedElements = [];
  // saved Preset streams
  static List<String> savedStreams = [];
  static int defaultDevicesPort = 8000;
  static String defaultSystemApiSubnet = "192.168.0";
  static bool chartsAreRunning = true;

  static init() async {
    WidgetsFlutterBinding.ensureInitialized();
    final pref = await SharedPreferences.getInstance();

    showChartsAnimation = pref.getBool('showChartsAnimation') ?? true;
    lineGraphCurveSmooth = pref.getBool('lineGraphCurveSmooth') ?? true;
    showBottomLineChart = pref.getBool('showBottomLineChart') ?? true;
    showBackgroundBall = pref.getBool('showBackgroundBall') ?? true;
    fullChartsDetails = pref.getBool('fullChartsDetails') ?? false;
    chartsExplode = pref.getBool("chartsExplode") ?? true;
    showDashboardAnimations = pref.getBool('showDashboardAnimations') ?? true;
    fullTreeMap = pref.getBool('fullTreeMap') ?? true;
    dashboardExtensionsOrder = pref.getStringList('dashboardExtensionsOrder') ??
        ["1Progress", "1Elements", "1Performance"];

    pinnedElements = pref.getStringList('pinnedElements') ?? [];
    savedStreams = pref.getStringList('savedStreams') ?? [];
    defaultDevicesPort = pref.getInt('defaultDevicesPort') ?? 8000;
    defaultSystemApiSubnet =
        pref.getString('defaultSystemApiSubnet') ?? "192.168.0";
    chartsAreRunning = pref.getBool('chartsAreRunning') ?? true;

    showTreeMap = pref.getBool('showTreeMap') ?? true;

    NetworkController.changeServerIpAddress(
        pref.getString('serverIpAddress') ?? "",
        pref.getInt('serverPort')?.toString() ?? "8084");
  }
}

class BackgroundBallNotifier extends ChangeNotifier {
  get showBackgroundBall => SystemSettings.showBackgroundBall;

  void changeShowBackgroundBall(bool value) {
    SystemSettings.showBackgroundBall = value;
    notifyListeners();
  }
}

class BottomLineChartNotifier extends ChangeNotifier {
  get showBottomLineChart => SystemSettings.showBottomLineChart;

  void changeShowBottomLineChart(bool value) {
    SystemSettings.showBottomLineChart = value;
    notifyListeners();
  }
}
