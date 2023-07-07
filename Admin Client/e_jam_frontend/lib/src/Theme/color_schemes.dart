import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Enums/processes.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:flutter/material.dart';

const uploadColor =
    Color.fromARGB(255, 0, 175, 228); // Color for Uploads indicators
const downloadColor =
    Color.fromARGB(255, 224, 131, 0); // Color for Downloads indicators
const packetErrorColor =
    Color(0xFFBA1A1A); // Color for Packet Errors indicators (charts only)

Color streamColorScheme(StreamStatus? status) {
  switch (status) {
    case StreamStatus.created:
      return Colors.blueGrey.shade700;
    case StreamStatus.queued:
      return Colors.orangeAccent.shade400;
    case StreamStatus.running:
      return Colors.greenAccent.shade700;
    case StreamStatus.stopped:
      return Colors.redAccent.shade400;
    case StreamStatus.error:
      return Colors.red.shade600;
    case StreamStatus.finished:
      return Colors.blueAccent.shade700;
    case StreamStatus.sent:
      return Colors.blueGrey.shade800;
    default:
      return Colors.blueGrey;
  }
}

Color deviceStatusColorScheme(DeviceStatus? status) {
  switch (status) {
    case DeviceStatus.running:
      return Colors.greenAccent.shade700;
    case DeviceStatus.online:
      return Colors.green.shade400;
    case DeviceStatus.idle:
      return Colors.orangeAccent.shade400;
    case DeviceStatus.offline:
      return Colors.red.shade600;
    default:
      return Colors.red;
  }
}

Color processStatusColorScheme(ProcessStatus? status) {
  switch (status) {
    case ProcessStatus.queued:
      return Colors.orange.shade500;
    case ProcessStatus.running:
      return Colors.green.shade500;
    case ProcessStatus.stopped:
      return Colors.redAccent.shade100;
    case ProcessStatus.completed:
      return Colors.blueGrey.shade700;
    case ProcessStatus.failed:
      return Colors.red.shade400;
    default:
      return Colors.blueGrey;
  }
}

final gradientColorLight = [
  const Color.fromARGB(255, 253, 209, 146),
  const Color.fromARGB(255, 255, 197, 117),
  const Color.fromARGB(255, 216, 151, 86),
  const Color.fromARGB(255, 255, 117, 117),
];

final gradientColorDark = [
  const Color.fromARGB(255, 0, 21, 48),
  const Color.fromARGB(255, 0, 27, 61),
  const Color.fromARGB(255, 0, 48, 98),
  const Color.fromARGB(255, 0, 128, 255),
];

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF005AC1),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD8E2FF),
  onPrimaryContainer: Color(0xFF001A41),
  secondary: Color(0xFF575E71),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFDBE2F9),
  onSecondaryContainer: Color(0xFF141B2C),
  tertiary: Color(0xFF715573),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFBD7FC),
  onTertiaryContainer: Color(0xFF29132D),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFEFBFF),
  onBackground: Color(0xFF1B1B1F),
  surface: Color(0xFFFEFBFF),
  onSurface: Color(0xFF1B1B1F),
  surfaceVariant: Color(0xFFE1E2EC),
  onSurfaceVariant: Color(0xFF44474F),
  outline: Color(0xFF74777F),
  onInverseSurface: Color(0xFFF2F0F4),
  inverseSurface: Color(0xFF303033),
  inversePrimary: Color(0xFFADC6FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF005AC1),
  outlineVariant: Color(0xFFC4C6D0),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFADC6FF),
  onPrimary: Color(0xFF002E69),
  primaryContainer: Color(0xFF004494),
  onPrimaryContainer: Color(0xFFD8E2FF),
  secondary: Color(0xFFBFC6DC),
  onSecondary: Color(0xFF293041),
  secondaryContainer: Color(0xFF3F4759),
  onSecondaryContainer: Color(0xFFDBE2F9),
  tertiary: Color(0xFFDEBCDF),
  onTertiary: Color(0xFF402843),
  tertiaryContainer: Color(0xFF583E5B),
  onTertiaryContainer: Color(0xFFFBD7FC),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1B1B1F),
  onBackground: Color(0xFFE3E2E6),
  surface: Color(0xFF1B1B1F),
  onSurface: Color(0xFFC7C6CA),
  surfaceVariant: Color(0xFF44474F),
  onSurfaceVariant: Color(0xFFC4C6D0),
  outline: Color(0xFF8E9099),
  onInverseSurface: Color(0xFF1B1B1F),
  inverseSurface: Color(0xFFE3E2E6),
  inversePrimary: Color(0xFF005AC1),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFADC6FF),
  outlineVariant: Color(0xFF44474F),
  scrim: Color(0xFF000000),
);

class ThemeModel extends ChangeNotifier {
  bool _isDark = true;
  ThemePreferences themePreferences = ThemePreferences();

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
  ColorScheme get colorScheme => _isDark ? darkColorScheme : lightColorScheme;

  ThemeModel() {
    _isDark = true;
    getTheme();
  }

  getTheme() async {
    _isDark = await themePreferences.isDarkMode();
    notifyListeners();
  }

  toggleTheme() {
    _isDark = !_isDark;
    themePreferences.setDarkMode(_isDark);
    notifyListeners();
  }

  set isDark(bool value) {
    _isDark = value;
    themePreferences.setDarkMode(value);
    notifyListeners();
  }
}
