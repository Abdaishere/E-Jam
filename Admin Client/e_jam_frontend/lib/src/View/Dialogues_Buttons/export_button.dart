import 'dart:math';

import 'package:e_jam/src/View/Animation/hero_dialog_route.dart';
import 'package:e_jam/src/services/data_exporter.dart';
import 'package:flutter/material.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// TODO: impl export button for csv and pdf export
class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const FaIcon(
        FontAwesomeIcons.solidFloppyDisk,
        size: 21,
      ),
      color: context.watch<ThemeModel>().colorScheme.secondary,
      tooltip: 'Export as CSV or PDF',
      onPressed: () async {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (BuildContext context) => const Center(
              child: ExportDataView(),
            ),
            settings: const RouteSettings(name: 'ChangeServerView'),
          ),
        );
      },
    );
  }
}

class ExportDataView extends StatefulWidget {
  const ExportDataView({super.key});
  // a list of five boolean choice for each data type

  @override
  State<ExportDataView> createState() => _ExportDataViewState();
}

class _ExportDataViewState extends State<ExportDataView> {
  static List<bool> choices = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: min(500, MediaQuery.of(context).size.width * 0.8),
      height: min(280, MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Export Data',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  choiceChipButton(0, 'Devices', FontAwesomeIcons.microchip,
                      Colors.deepOrangeAccent),
                  choiceChipButton(
                    1,
                    'Streams Status',
                    MaterialCommunityIcons.view_dashboard,
                    Colors.blue,
                  ),
                  choiceChipButton(
                    2,
                    'Streams Data',
                    MaterialCommunityIcons.view_dashboard_variant,
                    Colors.blue,
                  ),
                  choiceChipButton(
                    3,
                    'Generators Statistics',
                    MaterialCommunityIcons.progress_upload,
                    downloadColor,
                  ),
                  choiceChipButton(
                    4,
                    'Verifiers Statistics',
                    MaterialCommunityIcons.progress_check,
                    uploadColor,
                  ),
                ],
              ),
              TextButtonTheme(
                data: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: Wrap(
                  spacing: 30,
                  runSpacing: 10,
                  children: [
                    TextButton(
                      onPressed: () => DataExporter.exportSelectedData(
                        context,
                        choices,
                        0,
                      ),
                      child: const Text('Export as CSV'),
                    ),
                    TextButton(
                      onPressed: () => DataExporter.exportSelectedData(
                        context,
                        choices,
                        1,
                      ),
                      child: const Text('Export as PDF'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ChoiceChip choiceChipButton(
      int index, String label, IconData icon, Color color) {
    return ChoiceChip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(label),
      onSelected: (bool value) {
        choices[index] = value;
        setState(() {});
      },
      selected: choices[index],
    );
  }
}
