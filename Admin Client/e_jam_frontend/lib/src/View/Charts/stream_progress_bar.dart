import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StreamProgressBar extends StatefulWidget {
  const StreamProgressBar({
    super.key,
    required this.status,
    required this.startTime,
    required this.endTime,
  });
  final StreamStatus status;
  final DateTime startTime;
  final DateTime endTime;
  @override
  State<StreamProgressBar> createState() => _StreamProgressBarState();
}

class _StreamProgressBarState extends State<StreamProgressBar> {
  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
      orientation: LinearGaugeOrientation.horizontal,
      minimum: 0,
      maximum: 100,
      interval: 10,
      axisTrackStyle: const LinearAxisTrackStyle(
        edgeStyle: LinearEdgeStyle.bothFlat,
      ),
      labelPosition: LinearLabelPosition.outside,
      markerPointers: const [
        LinearShapePointer(
          value: 50,
          shapeType: LinearShapePointerType.diamond,
          position: LinearElementPosition.cross,
          enableAnimation: false,

          animationType: LinearAnimationType.ease,
          // color of the state of the stream
          color: Colors.greenAccent,
        ),
      ],
      barPointers: const [
        LinearBarPointer(
          value: 50,
          enableAnimation: false,
          animationType: LinearAnimationType.ease,
          color: Colors.greenAccent,
        ),
      ],
    );
  }
}
