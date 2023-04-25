import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
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
          enableLoadingAnimation: true,
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
              pointers: const [
                RangePointer(
                  value: 60,
                  width: 0.1,
                  sizeUnit: GaugeSizeUnit.factor,
                  cornerStyle: CornerStyle.bothCurve,
                  enableAnimation: true,
                  gradient: SweepGradient(
                    colors: <Color>[
                      Color(0xFF4FC3F7),
                      Color(0xFF00A8B5),
                    ],
                    stops: <double>[0.5, 0.75],
                  ),
                ),
                MarkerPointer(
                  value: 60,
                  markerType: MarkerType.circle,
                  markerHeight: 15,
                  markerWidth: 15,
                  enableAnimation: true,
                  color: Color(0xFF00A8B5),
                ),
              ],
              annotations: const [
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.1,
                  widget: Text(
                    '60%',
                    style: TextStyle(
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
