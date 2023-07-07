import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Model/Classes/Statistics/utils.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StreamProgressBar extends StatefulWidget {
  const StreamProgressBar({
    super.key,
    this.status,
    this.startTime,
    this.endTime,
    required this.lastUpdated,
  });
  final StreamStatus? status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? lastUpdated;
  @override
  State<StreamProgressBar> createState() => _StreamProgressBarState();
}

class _StreamProgressBarState extends State<StreamProgressBar> {
  @override
  Widget build(BuildContext context) {
    double progress = Utils.getProgress(
        widget.status ?? StreamStatus.created,
        widget.startTime,
        widget.endTime,
        false,
        widget.status != StreamStatus.running
            ? widget.lastUpdated
            : DateTime.now());

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
          value: progress,
          shapeType: LinearShapePointerType.diamond,
          position: LinearElementPosition.cross,
          enableAnimation: true,

          animationType: LinearAnimationType.ease,
          // color of the state of the stream
          color: streamColorScheme(widget.status),
        ),
      ],
      barPointers: [
        LinearBarPointer(
          value: progress,
          enableAnimation: SystemSettings.showChartsAnimation,
          animationType: LinearAnimationType.ease,
          color: streamColorScheme(widget.status),
        ),
      ],
    );
  }
}
