import 'package:e_jam/src/services/data_exporter.dart';
import 'package:flutter/material.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
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
        List<List<dynamic>> rows = await DataExporter.devicesList(context);
        print(rows);
        await DataExporter.saveAsPdf(rows, 'devices.pdf');
      },
    );
  }
}
