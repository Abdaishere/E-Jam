import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

// should be the difference between the youngest and oldest stream task in the system
class GaugeTotalProgressForSystem extends StatefulWidget {
  const GaugeTotalProgressForSystem({super.key});

  @override
  State<GaugeTotalProgressForSystem> createState() =>
      _GaugeTotalProgressForSystemState();
}

class _GaugeTotalProgressForSystemState
    extends State<GaugeTotalProgressForSystem> {
  double getProgress() {
    final List<StreamEntry>? streams =
        Provider.of<StreamsController>(context, listen: false).getStreams;
    if (streams == null) {
      return 0;
    }
    int totalProgress = 0;
    int totalTasks = 0;
    for (final StreamEntry stream in streams) {
      totalProgress += stream.runningGenerators?.progress ?? 0;
      totalTasks += stream.runningGenerators?.total ?? 0;
      totalProgress += stream.runningVerifiers?.progress ?? 0;
      totalTasks += stream.runningVerifiers?.total ?? 0;
    }
    if (totalTasks == 0) {
      return 0;
    }
    return totalProgress / totalTasks;
  }

  @override
  Widget build(BuildContext context) {
    double totalProgress = getProgress();
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
                  value: totalProgress,
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
                  value: totalProgress,
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
                    totalProgress == 0
                        ? 'No Tasks'
                        : totalProgress == 100
                            ? 'Done'
                            : '${(getProgress() * 100).toStringAsFixed(2)}%',
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
