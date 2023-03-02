import 'package:e_jam/main.dart';
import 'package:e_jam/src/View/Charts/Home/icons_system_elements.dart';
import 'package:e_jam/src/View/Charts/Home/gauge_speed_chart.dart';
import 'package:e_jam/src/View/Charts/Home/progress_task_for_all_system.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:e_jam/src/View/Charts/Home/treemap_drilldown_devices_load.dart';

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
          'Switchboard',
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: const Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(8),
                )),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TreeMapDrilldownDevicesLoad(),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Row(
                children: const [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      )),
                      child: GaugeTotalProgressForSystem(),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      )),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: IconsElementsSystem(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      )),
                      child: Center(
                        child: GaugeSpeedChart(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
