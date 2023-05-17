import 'package:e_jam/src/Model/Classes/Statistics/fake_chart_data.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BottomLineChart extends StatefulWidget {
  const BottomLineChart({super.key});

  @override
  State<BottomLineChart> createState() => _BottomLineChartState();
}

class _BottomLineChartState extends State<BottomLineChart> {
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
        SplineAreaSeries<ChartData, int>(
          borderColor: uploadColor,
          borderWidth: 1,
          dataSource: chartData(),
          xValueMapper: (ChartData chartData, _) => chartData.date,
          yValueMapper: (ChartData chartData, _) => chartData.value,
          color: uploadColor.withOpacity(0.2),
        ),

        // Renders spline area chart
        SplineAreaSeries<ChartData, int>(
          borderColor: downloadColor,
          borderWidth: 1,
          dataSource: chartData2(),
          xValueMapper: (ChartData chartData, _) => chartData.date,
          yValueMapper: (ChartData chartData, _) => chartData.value,
          color: downloadColor.withOpacity(0.2),
        ),
      ],
    );
  }
}
