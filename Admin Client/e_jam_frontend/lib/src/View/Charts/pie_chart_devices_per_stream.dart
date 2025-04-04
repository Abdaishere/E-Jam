import 'package:e_jam/src/Model/Enums/processes.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RunningProcesses {
  final ProcessStatus state;
  final int number;

  RunningProcesses(this.state, this.number);
}

// if chart explode is enabled then the first index is exploded by default according to the insertion order
List<RunningProcesses> runningProcessesToList(Map<ProcessStatus, int> data) {
  List<RunningProcesses> result = [];

  data.forEach((key, value) {
    if (value > 0) result.add(RunningProcesses(key, value));
  });

  return result;
}

class PieDevices extends StatelessWidget {
  const PieDevices(this.data, {super.key});
  final List<RunningProcesses> data;

  @override
  Widget build(BuildContext context) {
    return _buildDefaultPieChart();
  }

  /// Returns the circular  chart with pie series.
  SfCircularChart _buildDefaultPieChart() {
    return SfCircularChart(
      title: SystemSettings.fullChartsDetails
          ? ChartTitle(
              text: 'Devices',
              textStyle: const TextStyle(),
            )
          : null,
      legend: Legend(
        isVisible: SystemSettings.fullChartsDetails,
        textStyle: const TextStyle(fontSize: 12),
        iconHeight: 12,
        iconWidth: 12,
      ),
      series: _getDefaultPieSeries(),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: 'Devices',
      ),
      margin: const EdgeInsets.all(0),
    );
  }

  /// Returns the pie series.
  List<PieSeries<RunningProcesses, String>> _getDefaultPieSeries() {
    return <PieSeries<RunningProcesses, String>>[
      PieSeries<RunningProcesses, String>(
        animationDuration: SystemSettings.showChartsAnimation ? 800 : 0,
        radius: '90%',
        explode: SystemSettings.chartsExplode,
        explodeIndex: 0,
        explodeOffset: '15%',
        dataSource: data,
        xValueMapper: (RunningProcesses data, _) =>
            processStatusToString(data.state),
        yValueMapper: (RunningProcesses data, _) => data.number,
        dataLabelMapper: (RunningProcesses data, _) =>
            processStatusToString(data.state),
        pointColorMapper: (RunningProcesses data, _) =>
            processStatusColorScheme(data.state),
        startAngle: 90,
        endAngle: 90,
        enableTooltip: true,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
        ),
      )
    ];
  }
}
