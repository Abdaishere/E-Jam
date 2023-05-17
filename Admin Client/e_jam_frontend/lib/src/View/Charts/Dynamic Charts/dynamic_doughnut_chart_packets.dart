import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Model/Classes/Statistics/fake_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DynamicDoughnutChartPackets extends StatefulWidget {
  const DynamicDoughnutChartPackets(this.packetsState, {super.key});

  final List<PacketsState> packetsState;
  @override
  State<DynamicDoughnutChartPackets> createState() =>
      _DynamicDoughnutChartPacketsState();
}

class _DynamicDoughnutChartPacketsState
    extends State<DynamicDoughnutChartPackets> {
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
        isVisible: SystemSettings.fullChartsDetails,
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
        animationDuration: SystemSettings.showChartsAnimation ? 800 : 0,
        radius: '90%',
        explode: SystemSettings.chartsExplode,
        explodeOffset: '15%',
        dataSource: packetsState,
        xValueMapper: (PacketsState data, _) => data.state,
        yValueMapper: (PacketsState data, _) => data.value,
        dataLabelMapper: (PacketsState data, _) => data.state,
        enableTooltip: true,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      )
    ];
  }
}
