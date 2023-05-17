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
  static Uri serverIpAddress = Uri.parse('http://127.0.0.1:8080');
  static final client = http.Client();
  static Duration timeout = const Duration(minutes: 60);

  static changeServerIpAddress(String newIpAddress, String newPort) async {
    if (newIpAddress == "") {
      newIpAddress = "127.0.0.1";
    }
    if (newPort == "") {
      newPort = "8080";
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
  static bool showBackgroundBall = true;
  static bool fullChartsDetails = true;
  static bool showDashboardAnimations = true;
  static bool showTreeMap = true;
  static bool fullTreeMap = true;
  static List<String> dashboardExtensionsOrder = [
    "1Progress",
    "1Elements",
    "1Performance"
  ];
  static int defaultDevicesPort = 8000;
  static String defaultSystemApiSubnet = "192.168.0";
  static bool chartsAreRunning = true;

  static init() async {
    final pref = await SharedPreferences.getInstance();

    showChartsAnimation = pref.getBool('showChartsAnimation') ?? true;
    lineGraphCurveSmooth = pref.getBool('lineGraphCurveSmooth') ?? true;
    showBottomLineChart = pref.getBool('showBottomLineChart') ?? true;
    showBackgroundBall = pref.getBool('showBackgroundBall') ?? true;
    fullChartsDetails = pref.getBool('fullChartsDetails') ?? true;
    showDashboardAnimations = pref.getBool('showDashboardAnimations') ?? true;
    fullTreeMap = pref.getBool('fullTreeMap') ?? true;
    dashboardExtensionsOrder = pref.getStringList('dashboardExtensionsOrder') ??
        ["1Progress", "1Elements", "1Performance"];

    defaultDevicesPort = pref.getInt('defaultDevicesPort') ?? 8000;
    defaultSystemApiSubnet =
        pref.getString('defaultSystemApiSubnet') ?? "192.168.0";
    chartsAreRunning = pref.getBool('chartsAreRunning') ?? true;

    showTreeMap = pref.getBool('showTreeMap') ?? true;

    NetworkController.changeServerIpAddress(
        pref.getString('serverIpAddress') ?? "",
        pref.getInt('serverPort')?.toString() ?? "");
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
