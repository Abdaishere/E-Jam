import 'package:e_jam/src/Model/fake_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutChartPackets extends StatefulWidget {
  const DoughnutChartPackets(this.packetsState, {super.key});

  final List<PacketsState> packetsState;
  @override
  State<DoughnutChartPackets> createState() => _DoughnutChartPacketsState();
}

class _DoughnutChartPacketsState extends State<DoughnutChartPackets> {
  get packetsState => widget.packetsState;
  @override
  Widget build(BuildContext context) {
    return _buildDefaultDoughnutChart();
  }

  /// Return the circular chart with default doughnut series.
  SfCircularChart _buildDefaultDoughnutChart() {
    return SfCircularChart(
      title: ChartTitle(
        text: 'Packets',
        textStyle: const TextStyle(),
      ),
      legend: Legend(
        isVisible: true,
        textStyle: const TextStyle(fontSize: 12),
        iconHeight: 12,
        iconWidth: 12,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: 'Packets',
      ),
      series: _getDefaultDoughnutSeries(),
      margin: const EdgeInsets.all(0),
    );
  }

  /// Returns the doughnut series which need to be render.
  List<DoughnutSeries<PacketsState, String>> _getDefaultDoughnutSeries() {
    return <DoughnutSeries<PacketsState, String>>[
      DoughnutSeries<PacketsState, String>(
          radius: '90%',
          explode: true,
          explodeOffset: '15%',
          animationDuration: 1100,
          animationDelay: 150,
          dataSource: packetsState,
          xValueMapper: (PacketsState data, _) => data.state,
          yValueMapper: (PacketsState data, _) => data.value,
          dataLabelMapper: (PacketsState data, _) => data.state,
          enableTooltip: true,
          dataLabelSettings: const DataLabelSettings(isVisible: true))
    ];
  }
}
