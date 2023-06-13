import 'dart:math';

import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
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
    return _bottomLineChart(context);
  }

  SfCartesianChart _bottomLineChart(BuildContext context) {
    final generatorStatistics =
        context.watch<StatisticsController>().getGeneratorStatistics;
    final verifierStatistics =
        context.watch<StatisticsController>().getVerifierStatistics;

    final genChartData = generatorStatistics.sublist(max(
        generatorStatistics.length - SystemSettings.lineGraphMaxDataPoints, 0));

    final verChartData = verifierStatistics.sublist(max(
        verifierStatistics.length - SystemSettings.lineGraphMaxDataPoints, 0));

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
        // Renders spline area chart for Upload
        SplineAreaSeries<GeneratorStatisticsInstance, int>(
          borderColor: uploadColor,
          borderWidth: 1,
          splineType: SystemSettings.lineGraphCurveSmooth
              ? SplineType.monotonic
              : SplineType.cardinal,
          cardinalSplineTension: 0.0,
          dataSource: genChartData,
          yValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              chartData.packetsSent,
          xValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              chartData.timestamp.difference(now).inSeconds,
          color: uploadColor.withOpacity(0.2),
        ),

        // Renders spline area chart for Download
        SplineAreaSeries<VerifierStatisticsInstance, int>(
          borderColor: downloadColor,
          borderWidth: 1,
          splineType: SystemSettings.lineGraphCurveSmooth
              ? SplineType.monotonic
              : SplineType.cardinal,
          cardinalSplineTension: 0.0,
          dataSource: verChartData,
          yValueMapper: (VerifierStatisticsInstance chartData, _) =>
              chartData.packetsCorrect +
              chartData.packetsErrors +
              chartData.packetsOutOfOrder,
          // compare to now
          xValueMapper: (VerifierStatisticsInstance chartData, _) =>
              chartData.timestamp.difference(now).inSeconds,
          color: downloadColor.withOpacity(0.2),
        ),

        // Renders spline chart for Error
        SplineSeries<GeneratorStatisticsInstance, int>(
          name: 'Error',
          color: packetErrorColor,
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: packetErrorColor,
            borderColor: packetErrorColor,
            borderWidth: 1,
            height: 3,
            width: 3,
          ),
          width: 2,
          splineType: SystemSettings.lineGraphCurveSmooth
              ? SplineType.monotonic
              : SplineType.cardinal,
          cardinalSplineTension: 0.0,
          dataSource: genChartData,
          yValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              chartData.packetsErrors,
          xValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              chartData.timestamp.difference(now).inSeconds,
        ),
      ],
    );
  }
}
