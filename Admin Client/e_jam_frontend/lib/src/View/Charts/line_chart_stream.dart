import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartStream extends StatefulWidget {
  const LineChartStream(this.id, {super.key});

  final String id;
  @override
  State<LineChartStream> createState() => _LineChartStreamState();
}

class _LineChartStreamState extends State<LineChartStream> {
  get id => widget.id;
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
        labelFormat: '{value} Sec',
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color:
                SystemSettings.fullChartsDetails ? null : Colors.transparent),
        majorTickLines: const MajorTickLines(size: 1),
        labelIntersectAction: AxisLabelIntersectAction.hide,
        // TODO: Make this show the Packets per second not the size of the packets
        labelFormat: '{value}MB',
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
        SplineAreaSeries<ChartData, int>(
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
          dataSource: chartData(),
          xValueMapper: (ChartData chartData, _) => chartData.date,
          yValueMapper: (ChartData chartData, _) => chartData.value,
          color: uploadColor.withOpacity(0.2),
        ),

        // Renders Download area chart
        SplineAreaSeries<ChartData, int>(
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
          dataSource: chartData2(),
          xValueMapper: (ChartData chartData, _) => chartData.date,
          yValueMapper: (ChartData chartData, _) => chartData.value,
          color: downloadColor.withOpacity(0.2),
        ),

        // Renders Error line chart
        SplineSeries<ChartData, int>(
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
          dataSource: chartData3(),
          xValueMapper: (ChartData chartData, _) => chartData.date,
          yValueMapper: (ChartData chartData, _) => chartData.value,
        ),
      ],
    );
  }
}
