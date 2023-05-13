import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Model/Statistics/utils.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StreamProgressBar extends StatefulWidget {
  const StreamProgressBar({
    super.key,
    this.status,
    this.startTime,
    this.endTime,
  });
  final StreamStatus? status;
  final DateTime? startTime;
  final DateTime? endTime;
  @override
  State<StreamProgressBar> createState() => _StreamProgressBarState();
}

class _StreamProgressBarState extends State<StreamProgressBar> {
  final double accuracy = 0.9;

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
      markerPointers: [
        LinearShapePointer(
          value: Utils.getProgress(widget.status ?? StreamStatus.created,
              widget.startTime, widget.endTime, false),
          shapeType: LinearShapePointerType.diamond,
          position: LinearElementPosition.cross,
          enableAnimation: false,

          animationType: LinearAnimationType.ease,
          // color of the state of the stream
          color: streamColorScheme(widget.status),
        ),
      ],
      barPointers: [
        LinearBarPointer(
          value: Utils.getProgress(widget.status ?? StreamStatus.created,
              widget.startTime, widget.endTime, false),
          enableAnimation: SystemSettings.showChartsAnimation,
          animationType: LinearAnimationType.ease,
          color: streamColorScheme(widget.status),
        ),
      ],
    );
  }
}
