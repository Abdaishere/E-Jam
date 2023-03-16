import 'package:e_jam/src/Model/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DynamicLineChartStream extends StatefulWidget {
  const DynamicLineChartStream(this.index, {super.key});

  final int index;
  @override
  State<DynamicLineChartStream> createState() => _DynamicLineChartStreamState();
}

class _DynamicLineChartStreamState extends State<DynamicLineChartStream> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return _buildDynamicLineChartStream();
  }

  SfCartesianChart _buildDynamicLineChartStream() {
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
        labelStyle: const TextStyle(fontSize: 10),
        majorTickLines: const MajorTickLines(size: 1),
        labelIntersectAction: AxisLabelIntersectAction.multipleRows,
        labelFormat: '{value} Sec',
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400),
        majorTickLines: const MajorTickLines(size: 1),
        labelIntersectAction: AxisLabelIntersectAction.multipleRows,
        labelFormat: '{value} MB',
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
          // animationDelay: 100,
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
          dataSource: chartData,
          xValueMapper: (ChartData chartData, _) => chartData.date,
          yValueMapper: (ChartData chartData, _) => chartData.value,
          color: uploadColor.withOpacity(0.2),
        ),

        // Renders spline area chart
        SplineAreaSeries<ChartData, int>(
          name: 'Download',
          borderColor: downloadColor,
          // animationDelay: 100,
          borderWidth: 1,
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: downloadColor,
            borderColor: downloadColor,
            borderWidth: 1,
            height: 3,
            width: 3,
          ),
          dataSource: chartData2,
          xValueMapper: (ChartData chartData, _) => chartData.date,
          yValueMapper: (ChartData chartData, _) => chartData.value,
          color: downloadColor.withOpacity(0.2),
        ),
      ],
    );
  }
}
