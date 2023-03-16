import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DynamicPieDevices extends StatefulWidget {
  const DynamicPieDevices(this.data, {super.key});
  final List<RunningDevices> data;
  @override
  State<StatefulWidget> createState() => _DynamicPieDevicesState();
}

/// State class of pie series.
class _DynamicPieDevicesState extends State<DynamicPieDevices> {
  get data => widget.data;
  _DynamicPieDevicesState();

  @override
  Widget build(BuildContext context) {
    return _buildDynamicPieChart();
  }

  /// Returns the circular  chart with pie series.
  SfCircularChart _buildDynamicPieChart() {
    return SfCircularChart(
      title: ChartTitle(
        text: 'Devices',
        textStyle: const TextStyle(),
      ),
      legend: Legend(
        isVisible: true,
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
  List<PieSeries<RunningDevices, String>> _getDefaultPieSeries() {
    return <PieSeries<RunningDevices, String>>[
      PieSeries<RunningDevices, String>(
        radius: '90%',
        explode: true,
        explodeIndex: 0,
        explodeOffset: '15%',
        animationDuration: 1000,
        animationDelay: 150,
        dataSource: data,
        xValueMapper: (RunningDevices data, _) => data.state,
        yValueMapper: (RunningDevices data, _) => data.value,
        dataLabelMapper: (RunningDevices data, _) => data.state,
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
