import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/extensions/icons_system_elements.dart';
import 'package:e_jam/src/View/extensions/gauge_speed_chart.dart';
import 'package:e_jam/src/View/extensions/progress_task_for_all_system.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/View/extensions/treemap_drilldown_devices_load.dart';
import 'package:provider/provider.dart';

class DashBoardView extends StatefulWidget {
  const DashBoardView({super.key});

  @override
  State<DashBoardView> createState() => _DashBoardViewState();
}

class _DashBoardViewState extends State<DashBoardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSystemData(false);
    });
  }

  void _loadSystemData(bool forced) async {
    // load system data
    context.read<DevicesController>().loadAllDevices(forced);
    context.read<StreamsController>().loadAllStreamStatus(forced);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const DrawerWidget(),
        actions: [
          // refresh icon for refreshing the whole system
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.arrowsRotate,
              size: 20,
            ),
            onPressed: () => _loadSystemData(true),
          ),
          // question mark icon for help
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.circleQuestion,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
          children: [
            if (SystemSettings.showTreeMap) const TreeMapDrillDownDevicesLoad(),
            Wrap(
              children: SystemSettings.dashboardExtensionsOrder
                  .map(
                    (e) => widgetFilter(e),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget widgetFilter(String e) {
    switch (e) {
      case '1Progress':
        return const GaugeTotalProgressForSystem();
      case '1Elements':
        return const IconsElementsSystem();
      case '1Performance':
        return const GaugeSpeedChart();
      default:
        return const SizedBox();
    }
  }
}
