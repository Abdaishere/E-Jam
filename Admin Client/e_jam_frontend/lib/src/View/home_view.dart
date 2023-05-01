import 'package:e_jam/main.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/View/extensions/icons_system_elements.dart';
import 'package:e_jam/src/View/extensions/gauge_speed_chart.dart';
import 'package:e_jam/src/View/extensions/progress_task_for_all_system.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:e_jam/src/View/extensions/treemap_drilldown_devices_load.dart';

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
              children: SystemSettings.homeExtensionsOrder
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
