import 'dart:async';

import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Model/Statistics/utils.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeTotalProgressForSystem extends StatefulWidget {
  const GaugeTotalProgressForSystem({super.key});

  @override
  State<GaugeTotalProgressForSystem> createState() =>
      _GaugeTotalProgressForSystemState();
}

class _GaugeTotalProgressForSystemState
    extends State<GaugeTotalProgressForSystem> {
  double? _totalProgress = 0;
  bool _loading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getProgress(false);
    });

    timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => _getProgress(true));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _getProgress(bool forced) async {
    await context.read<StreamsController>().loadAllStreams(forced);
    if (!mounted) return;

    final List<StreamEntry>? streams =
        context.read<StreamsController>().getStreams;

    if (streams == null) {
      _totalProgress = null;
    } else {
      int totalProgress = 0;
      int totalTasks = 0;
      for (final StreamEntry stream in streams) {
        totalProgress += stream.runningGenerators?.progress ?? 0;
        totalTasks += stream.runningGenerators?.total ?? 0;
        totalProgress += stream.runningVerifiers?.progress ?? 0;
        totalTasks += stream.runningVerifiers?.total ?? 0;
      }

      _totalProgress =
          Utils.mapOneRangeToAnother(totalProgress, 0, totalTasks, 0, 100, 2);
    }
    _loading = false;
    if (mounted) setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    double progress = _totalProgress ?? 0;
    String message = '${(_totalProgress ?? 0).toStringAsFixed(2)}%';
    if (_loading) message = 'Loading...';
    if (_totalProgress == null) {
      message = 'Oops!';
    } else {
      if (_totalProgress == 0) message = 'No Tasks';
      if (_totalProgress == 100) message = 'Done';
    }

    return SizedBox(
      width: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width > 450
              ? 340
              : MediaQuery.of(context).size.width
          : 340,
      height: 280,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(8),
        )),
        child: SfRadialGauge(
          title: const GaugeTitle(
            text: 'Progress',
          ),
          enableLoadingAnimation: SystemSettings.showDashboardAnimations,
          animationDuration: 1500,
          axes: [
            RadialAxis(
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              endAngle: 270,
              radiusFactor: 0.8,
              axisLineStyle: const AxisLineStyle(
                thickness: 0.1,
                thicknessUnit: GaugeSizeUnit.factor,
                cornerStyle: CornerStyle.bothCurve,
              ),
              pointers: [
                RangePointer(
                  value: progress,
                  width: 0.1,
                  sizeUnit: GaugeSizeUnit.factor,
                  cornerStyle: CornerStyle.bothCurve,
                  enableAnimation: SystemSettings.showDashboardAnimations,
                  gradient: const SweepGradient(
                    colors: <Color>[
                      Color(0xFF4FC3F7),
                      Color(0xFF00A8B5),
                    ],
                    stops: <double>[0.5, 0.75],
                  ),
                ),
                MarkerPointer(
                  value: progress,
                  markerType: MarkerType.circle,
                  markerHeight: 15,
                  markerWidth: 15,
                  enableAnimation: SystemSettings.showDashboardAnimations,
                  color: const Color(0xFF00A8B5),
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.1,
                  widget: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
