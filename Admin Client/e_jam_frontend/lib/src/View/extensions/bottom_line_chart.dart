import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BottomLineChart extends StatefulWidget {
  const BottomLineChart({super.key});

  @override
  State<BottomLineChart> createState() => _BottomLineChartState();
}

class _BottomLineChartState extends State<BottomLineChart> {
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.transparent),
        majorTickLines: const MajorTickLines(size: 0),
        labelPosition: ChartDataLabelPosition.inside,
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.transparent),
        majorTickLines: const MajorTickLines(size: 0),
        labelPosition: ChartDataLabelPosition.inside,
      ),
      series: <ChartSeries>[
        // Renders spline area chart
        if (context.watch<StatisticsController>().getGeneratorStatistics !=
            null)
          SplineAreaSeries<GeneratorStatisticsInstance, int>(
            borderColor: uploadColor,
            borderWidth: 1,
            dataSource:
                context.watch<StatisticsController>().getGeneratorStatistics!,
            yValueMapper: (GeneratorStatisticsInstance chartData, _) =>
                chartData.packetsSent,
            xValueMapper: (GeneratorStatisticsInstance chartData, _) =>
                now.difference(chartData.timestamp).inSeconds,
            color: uploadColor.withOpacity(0.2),
          ),

        // Renders spline area chart
        if (context.watch<StatisticsController>().getVerifierStatistics != null)
          SplineAreaSeries<VerifierStatisticsInstance, int>(
            borderColor: downloadColor,
            borderWidth: 1,
            dataSource:
                context.watch<StatisticsController>().getVerifierStatistics!,
            yValueMapper: (VerifierStatisticsInstance chartData, _) =>
                chartData.packetsCorrect +
                chartData.packetsErrors +
                chartData.packetsOutOfOrder,
            xValueMapper: (VerifierStatisticsInstance chartData, _) =>
                now.difference(chartData.timestamp).inSeconds,
            color: downloadColor.withOpacity(0.2),
          ),
      ],
    );
  }
}
