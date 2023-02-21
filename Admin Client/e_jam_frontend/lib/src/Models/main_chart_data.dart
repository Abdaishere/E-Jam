import 'package:flutter/material.dart';

class ChartData {
  final double date;
  final double value;

  ChartData(this.date, this.value);
}

List<ChartData> chartData = [
  ChartData(654, 35),
  ChartData(754, 28),
  ChartData(824, 34),
  ChartData(994, 32),
  ChartData(1154, 40),
];

List<ChartData> chartData2 = [
  ChartData(654, 15),
  ChartData(754, 38),
  ChartData(824, 54),
  ChartData(994, 72),
  ChartData(1154, 60),
];
