import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartStream extends StatefulWidget {
  const LineChartStream(
      {super.key,
      required this.id,
      required this.genChartData,
      required this.verChartData});

  final String id;
  final List<GeneratorStatisticsInstance> genChartData;
  final List<VerifierStatisticsInstance> verChartData;
  @override
  State<LineChartStream> createState() => _LineChartStreamState();
}

class _LineChartStreamState extends State<LineChartStream> {
  get id => widget.id;
  get _genChartData => widget.genChartData;
  get _verChartData => widget.verChartData;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // TODO: Implement Pinned Charts
      },
      child: _lineChart(),
    );
  }

  SfCartesianChart _lineChart() {
    return SfCartesianChart(
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: const InteractiveTooltip(
          enable: true,
        ),
      ),
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        labelStyle: const TextStyle(fontSize: 10),
        majorTickLines: const MajorTickLines(size: 1),
        labelIntersectAction: SystemSettings.fullChartsDetails
            ? AxisLabelIntersectAction.trim
            : AxisLabelIntersectAction.hide,
        labelFormat: '{value}',
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color:
                SystemSettings.fullChartsDetails ? null : Colors.transparent),
        majorTickLines: const MajorTickLines(size: 1),
        labelIntersectAction: AxisLabelIntersectAction.hide,
        labelFormat: '{value}Pkt',
        labelRotation: 90,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enablePinching: true,
        enableDoubleTapZooming: true,
        enableSelectionZooming: true,
        enableMouseWheelZooming: true,
        zoomMode: ZoomMode.x,
        selectionRectBorderColor: Colors.transparent,
        selectionRectBorderWidth: 0,
        selectionRectColor: Colors.transparent,
      ),
      series: <ChartSeries>[
        // Renders Upload area chart
        SplineAreaSeries<GeneratorStatisticsInstance, int>(
          name: 'Upload',
          animationDuration: SystemSettings.showChartsAnimation ? 1000 : 0,
          borderColor: uploadColor,
          borderWidth: 1,
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: uploadColor,
            borderColor: uploadColor,
            borderWidth: 1,
            height: 3,
            width: 3,
          ),
          splineType: SystemSettings.lineGraphCurveSmooth
              ? SplineType.monotonic
              : SplineType.cardinal,
          cardinalSplineTension: 0.0,
          dataSource: _genChartData,
          yValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              chartData.packetsSent,
          xValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              now.difference(chartData.timestamp).inSeconds,
          color: uploadColor.withOpacity(0.2),
        ),

        // Renders Download area chart
        SplineAreaSeries<VerifierStatisticsInstance, int>(
          name: 'Download',
          animationDuration: SystemSettings.showChartsAnimation ? 1000 : 0,
          borderColor: downloadColor,
          borderWidth: 1,
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: downloadColor,
            borderColor: downloadColor,
            borderWidth: 1,
            height: 3,
            width: 3,
          ),
          splineType: SystemSettings.lineGraphCurveSmooth
              ? SplineType.monotonic
              : SplineType.cardinal,
          cardinalSplineTension: 0.0,
          dataSource: _verChartData,
          yValueMapper: (VerifierStatisticsInstance chartData, _) =>
              chartData.packetsCorrect +
              chartData.packetsErrors +
              chartData.packetsOutOfOrder,
          // compare to now
          xValueMapper: (VerifierStatisticsInstance chartData, _) =>
              now.difference(chartData.timestamp).inSeconds,
          color: downloadColor.withOpacity(0.2),
        ),

        // Renders Error line chart
        SplineSeries<GeneratorStatisticsInstance, int>(
          name: 'Error',
          animationDelay: SystemSettings.showChartsAnimation ? 1000 : 0,
          animationDuration: SystemSettings.showChartsAnimation ? 1000 : 0,
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
          dataSource: _genChartData,
          yValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              chartData.packetsErrors,
          xValueMapper: (GeneratorStatisticsInstance chartData, _) =>
              now.difference(chartData.timestamp).inSeconds,
        ),
      ],
    );
  }
}
