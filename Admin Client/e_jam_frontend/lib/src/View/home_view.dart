import 'package:e_jam/main.dart';
import 'package:e_jam/src/View/Charts/extensions/icons_system_elements.dart';
import 'package:e_jam/src/View/Charts/extensions/gauge_speed_chart.dart';
import 'package:e_jam/src/View/Charts/extensions/progress_task_for_all_system.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:e_jam/src/View/Charts/extensions/treemap_drilldown_devices_load.dart';

// should not be scrollable
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
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
            onPressed: () {},
          ),
          // settings icon for changing the settings of the system
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.gear,
              size: 20,
            ),
            onPressed: () {},
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 350, child: TreeMapDrillDownDevicesLoad()),
            Wrap(
              children: const [
                GaugeTotalProgressForSystem(),
                IconsElementsSystem(),
                GaugeSpeedChart(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
