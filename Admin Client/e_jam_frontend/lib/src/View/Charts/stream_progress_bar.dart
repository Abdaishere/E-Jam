import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
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
  final double accuracy = 0.8;
  double getProgress(
      StreamStatus status, DateTime? startTime, DateTime? endTime) {
    if (status == StreamStatus.running ||
        status == StreamStatus.stopped ||
        status == StreamStatus.error) {
      return startTime == null
          ? 0
          : endTime == null
              ? 50
              : (startTime.difference(DateTime.now()).inSeconds /
                      (startTime.difference(endTime).inSeconds == 0
                          ? 1
                          : startTime.difference(DateTime.now()).inSeconds)) *
                  accuracy *
                  100;
    } else if (status == StreamStatus.finished) {
      return 100;
    } else {
      return 0;
    }
  }

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
          value: getProgress(widget.status ?? StreamStatus.created,
              widget.startTime, widget.endTime),
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
          value: getProgress(widget.status ?? StreamStatus.created,
              widget.startTime, widget.endTime),
          enableAnimation: false,
          animationType: LinearAnimationType.ease,
          color: streamColorScheme(widget.status),
        ),
      ],
    );
  }
}
