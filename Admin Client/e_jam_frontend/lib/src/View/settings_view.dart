import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// should include but not limited to:
// TODO: Disable animation for system button
// TODO: Change Line charts curve to smooth
// TODO: Change Order and types of extensions in main screen
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
        child: SingleChildScrollView(
          child: ListTileTheme(
            contentPadding: const EdgeInsets.symmetric(horizontal: 40),
            horizontalTitleGap: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _chartsSettings + _homeSettings + _defaults,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _changedShowBackgroundBallValue = false;
  bool _changedShowBottomLineChartValue = false;

  List<Widget> get _chartsSettings {
    return [
      const ListTile(
        leading: Icon(Icons.auto_graph_outlined),
        title: Text(
          'Charts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      ListTile(
        title: const Text('Animation'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showChartsAnimation,
          onChanged: (value) async {
            SystemSettings.showChartsAnimation = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showChartsAnimation', value);
            setState(() {});
          },
        ),
      ),
      ListTile(
        title: const Text('Line charts curve smooth'),
        trailing: CupertinoSwitch(
          value: SystemSettings.lineGraphCurveSmooth,
          onChanged: (value) async {
            SystemSettings.lineGraphCurveSmooth = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('lineGraphCurveSmooth', value);
            setState(() {});
          },
        ),
      ),
      ListTile(
        leading: _changedShowBackgroundBallValue
            ? IconButton(
                icon: const Icon(Icons.restart_alt_outlined),
                color: Colors.amber,
                tooltip: 'Restart app to apply changes',
                onPressed: () {},
              )
            : null,
        title: const Text('Background ball animation'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showBackgroundBall,
          onChanged: (value) async {
            SystemSettings.showBackgroundBall = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showBackgroundBall', value);
            _changedShowBackgroundBallValue = !_changedShowBackgroundBallValue;
            setState(() {});
          },
        ),
      ),
      ListTile(
        leading: _changedShowBottomLineChartValue
            ? IconButton(
                icon: const Icon(Icons.restart_alt_outlined),
                color: Colors.amber,
                tooltip: 'Restart app to apply changes',
                onPressed: () {},
              )
            : null,
        title: const Text('Bottom line chart'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showBottomLineChart,
          onChanged: (value) async {
            SystemSettings.showBottomLineChart = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showBottomLineChart', value);
            _changedShowBottomLineChartValue =
                !_changedShowBottomLineChartValue;
            setState(() {});
          },
        ),
      ),
      ListTile(
        title: const Text('Dense charts'),
        trailing: CupertinoSwitch(
          value: !SystemSettings.fullChartsDetails,
          onChanged: (value) async {
            SystemSettings.fullChartsDetails = !value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('fullChartsDetails', !value);
            setState(() {});
          },
        ),
      ),
      const Divider(
        height: 15,
        indent: 10,
        endIndent: 10,
      ),
    ];
  }

  List<Widget> get _homeSettings {
    return [
      const ListTile(
        leading: FaIcon(FontAwesome.dashboard),
        title: Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      ListTile(
        title: const Text('Home Animations'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showHomeAnimations,
          onChanged: (value) async {
            SystemSettings.showHomeAnimations = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showHomeAnimations', value);
            setState(() {});
          },
        ),
      ),
      ListTile(
        title: const Text('Dense Tree Map'),
        trailing: CupertinoSwitch(
          value: !SystemSettings.fullTreeMap,
          onChanged: (value) async {
            SystemSettings.fullTreeMap = !value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('fullTreeMap', !value);
            setState(() {});
          },
        ),
      ),
      const SizedBox(height: 10),
      _homeExtensionsOrder(),
      const SizedBox(height: 15),
      const Divider(
        height: 15,
        indent: 10,
        endIndent: 10,
      ),
    ];
  }

  Center _homeExtensionsOrder() {
    return Center(
      child: Container(
        height: 190,
        width: 350,
        padding: const EdgeInsets.all(12),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: ReorderableListView(
          header: const Text(
            'Home Extensions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          footer: const Text(
            'Drag and drop to reorder, click icon to enable/disable.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          children: SystemSettings.homeExtensionsOrder
              .map(
                (e) => _extensionTile(e),
              )
              .toList(),
          onReorder: (int oldIndex, int newIndex) async {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final String item =
                  SystemSettings.homeExtensionsOrder.removeAt(oldIndex);
              SystemSettings.homeExtensionsOrder.insert(newIndex, item);
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setStringList(
                'homeExtensionsOrder', SystemSettings.homeExtensionsOrder);
          },
        ),
      ),
    );
  }

  ListTile _extensionTile(String e) {
    return ListTile(
      leading: IconButton(
        icon: const Icon(MaterialIcons.extension),
        color: e[0] == '1' ? Colors.green : Colors.red,
        onPressed: () async {
          setState(() {
            int index = SystemSettings.homeExtensionsOrder.indexOf(e);
            if (e[0] == '1') {
              SystemSettings.homeExtensionsOrder.removeAt(index);
              e = '0${e.substring(1)}';
              SystemSettings.homeExtensionsOrder.insert(index, e);
            } else {
              SystemSettings.homeExtensionsOrder.removeAt(index);
              e = '1${e.substring(1)}';
              SystemSettings.homeExtensionsOrder.insert(index, e);
            }
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setStringList(
              'homeExtensionsOrder', SystemSettings.homeExtensionsOrder);
        },
      ),
      key: Key(e),
      title: Text(e.substring(1)),
      textColor: e[0] == '1' ? null : Colors.red,
      dense: true,
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _defaultDevicesPortController =
      TextEditingController();
  final TextEditingController _defaultSystemApiSubnetController =
      TextEditingController();

  List<Widget> get _defaults {
    _defaultDevicesPortController.text =
        SystemSettings.defaultDevicesPort.toString();
    _defaultSystemApiSubnetController.text =
        SystemSettings.defaultSystemApiSubnet;
    return [
      const ListTile(
        leading: Icon(FontAwesome.cogs),
        title: Text(
          'Defaults',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      Center(
        child: Container(
          height: 250,
          width: 350,
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  enableIMEPersonalizedLearning: false,
                  decoration: InputDecoration(
                    labelText: 'Devices Subnet IP',
                    border: const OutlineInputBorder(),
                    hintText: SystemSettings.defaultSystemApiSubnet.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an ip address for the Device';
                    } else if (!RegExp(
                            r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$|^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$")
                        .hasMatch(value)) {
                      return 'Please enter a valid Subnet';
                    }
                    return null;
                  },
                  controller: _defaultSystemApiSubnetController,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  enableIMEPersonalizedLearning: false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Devices Port',
                    hintText: SystemSettings.defaultDevicesPort.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a port';
                    } else if (int.parse(value) > 65535) {
                      return 'Please enter a valid port';
                    }
                    return null;
                  },
                  controller: _defaultDevicesPortController,
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          SystemSettings.defaultDevicesPort =
                              int.parse(_defaultDevicesPortController.text);
                          SystemSettings.defaultSystemApiSubnet =
                              _defaultSystemApiSubnetController.text;
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setInt('defaultDevicesPort',
                              SystemSettings.defaultDevicesPort);
                          prefs.setString('defaultSystemApiSubnet',
                              SystemSettings.defaultSystemApiSubnet);
                          setState(() {});
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    ];
  }
}
