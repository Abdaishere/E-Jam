import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// should include but not limited to:
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _chartsSettings + _dashboardSettings + _defaults,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> get _chartsSettings {
    return [
      const ListTile(
        leading: Icon(Icons.auto_graph_outlined),
        title: Text('Charts'),
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
        title: const Text('Background ball animation'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showBackgroundBall,
          onChanged: (value) async {
            context
                .read<BackgroundBallNotifier>()
                .changeShowBackgroundBall(value);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showBackgroundBall', value);
            setState(() {});
          },
        ),
      ),
      ListTile(
        title: const Text('Bottom line chart'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showBottomLineChart,
          onChanged: (value) async {
            context
                .read<BottomLineChartNotifier>()
                .changeShowBottomLineChart(value);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showBottomLineChart', value);
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
      ListTile(
        title: const Text('Explode charts'),
        trailing: CupertinoSwitch(
          value: SystemSettings.chartsExplode,
          onChanged: (value) async {
            SystemSettings.chartsExplode = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('chartsExplode', value);
            setState(() {});
          },
        ),
      ),
      ListTile(
        title: const Text('Charts List View'),
        trailing: CupertinoButton(
          onPressed: () => _clearChartDialog(),
          child: const Text(
            'Clear',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      const Divider(
        height: 15,
        indent: 10,
        endIndent: 10,
      ),
    ];
  }

  _clearChartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Charts'),
        content:
            const Text('Are you sure you want to clear ALL charts Pinned?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Clear'),
            onPressed: () async {
              SystemSettings.pinnedElements.clear();
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setStringList('pinnedElements', []);
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }

  List<Widget> get _dashboardSettings {
    return [
      const ListTile(
        leading: FaIcon(FontAwesome.dashboard),
        title: Text('Dashboard'),
      ),
      ListTile(
        title: const Text('Dashboard Animations'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showDashboardAnimations,
          onChanged: (value) async {
            SystemSettings.showDashboardAnimations = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showDashboardAnimations', value);
            setState(() {});
          },
        ),
      ),
      ListTile(
        title: const Text('Show Tree Map'),
        trailing: CupertinoSwitch(
          value: SystemSettings.showTreeMap,
          onChanged: (value) async {
            SystemSettings.showTreeMap = value;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('showTreeMap', value);
            setState(() {});
          },
        ),
      ),
      ListTile(
        title: const Text('Dense Tree Map'),
        trailing: CupertinoSwitch(
          value: !SystemSettings.fullTreeMap,
          onChanged: SystemSettings.showTreeMap
              ? (value) async {
                  SystemSettings.fullTreeMap = !value;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('fullTreeMap', !value);
                  setState(() {});
                }
              : null,
        ),
      ),
      const SizedBox(height: 10),
      _dashboardExtensionsOrder(),
      const SizedBox(height: 15),
      const Divider(
        height: 15,
        indent: 10,
        endIndent: 10,
      ),
    ];
  }

  Center _dashboardExtensionsOrder() {
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
            'Dashboard Extensions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          footer: const Text(
            'Drag and drop to reorder, click icon to enable/disable.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          children: SystemSettings.dashboardExtensionsOrder
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
                  SystemSettings.dashboardExtensionsOrder.removeAt(oldIndex);
              SystemSettings.dashboardExtensionsOrder.insert(newIndex, item);
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setStringList('dashboardExtensionsOrder',
                SystemSettings.dashboardExtensionsOrder);
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
            int index = SystemSettings.dashboardExtensionsOrder.indexOf(e);
            if (e[0] == '1') {
              SystemSettings.dashboardExtensionsOrder.removeAt(index);
              e = '0${e.substring(1)}';
              SystemSettings.dashboardExtensionsOrder.insert(index, e);
            } else {
              SystemSettings.dashboardExtensionsOrder.removeAt(index);
              e = '1${e.substring(1)}';
              SystemSettings.dashboardExtensionsOrder.insert(index, e);
            }
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setStringList('dashboardExtensionsOrder',
              SystemSettings.dashboardExtensionsOrder);
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
