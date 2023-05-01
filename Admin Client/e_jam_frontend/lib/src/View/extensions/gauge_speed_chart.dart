import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// should include the upload and download speed and error rate of the system in gauge charts
class GaugeSpeedChart extends StatefulWidget {
  const GaugeSpeedChart({super.key});

  @override
  State<GaugeSpeedChart> createState() => _GaugeSpeedChartState();
}

class _GaugeSpeedChartState extends State<GaugeSpeedChart> {
  @override
  Widget build(BuildContext context) {
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
        child: Consumer(
          builder: (context, ThemeModel theme, child) {
            return SfRadialGauge(
              title: const GaugeTitle(
                text: 'Performance',
              ),
              enableLoadingAnimation: SystemSettings.showHomeAnimations,
              animationDuration: 1500,
              axes: <RadialAxis>[
                // Acceptence rate for packets in the system
                RadialAxis(
                  centerY: 0.3,
                  radiusFactor: 0.55,
                  startAngle: 205,
                  endAngle: 335,
                  showLabels: false,
                  annotations: [
                    GaugeAnnotation(
                      angle: 270,
                      positionFactor: 0.4,
                      widget: Text(
                        'AC Pkts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    MarkerPointer(
                      value: 90,
                      enableAnimation: SystemSettings.showHomeAnimations,
                    ),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 100,
                      gradient: const SweepGradient(
                        colors: <Color>[
                          Colors.greenAccent,
                          deviceRunningOrOnlineColor,
                        ],
                        stops: <double>[0.5, 0.75],
                      ),
                    ),
                  ],
                  majorTickStyle: MajorTickStyle(
                    color: theme.colorScheme.secondary,
                    length: 0.1,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                  minorTickStyle: MinorTickStyle(
                    color: theme.colorScheme.secondary,
                    length: 0.05,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                ),
                // upload speed
                RadialAxis(
                  centerY: 0.5,
                  centerX: 0.25,
                  radiusFactor: 0.6,
                  startAngle: 90,
                  endAngle: 360,
                  showLabels: false,
                  annotations: [
                    GaugeAnnotation(
                      angle: 110,
                      positionFactor: 0.4,
                      widget: Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      needleColor: theme.colorScheme.secondary,
                      value: 90,
                      enableAnimation: SystemSettings.showHomeAnimations,
                      needleStartWidth: 1,
                      needleEndWidth: 5,
                      needleLength: 0.8,
                      knobStyle: KnobStyle(
                        color: theme.colorScheme.secondary,
                        knobRadius: 0.08,
                      ),
                      tailStyle: TailStyle(
                        color: theme.colorScheme.secondary,
                        length: 0.1,
                        width: 1,
                      ),
                    ),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 100,
                      gradient: const SweepGradient(
                        colors: <Color>[uploadColor, Colors.blueAccent],
                        stops: <double>[0.5, 0.75],
                      ),
                    ),
                  ],
                  majorTickStyle: MajorTickStyle(
                    color: theme.colorScheme.primary,
                    length: 0.1,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                  minorTickStyle: MinorTickStyle(
                    color: theme.colorScheme.primary,
                    length: 0.05,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                ),
                // download speed
                RadialAxis(
                  centerY: 0.5,
                  centerX: 0.75,
                  radiusFactor: 0.6,
                  startAngle: 180,
                  endAngle: 90,
                  showLabels: false,
                  annotations: [
                    GaugeAnnotation(
                      angle: 70,
                      positionFactor: 0.4,
                      widget: Text(
                        'Download',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      needleColor: theme.colorScheme.secondary,
                      value: 90,
                      enableAnimation: SystemSettings.showHomeAnimations,
                      needleStartWidth: 1,
                      needleEndWidth: 5,
                      needleLength: 0.8,
                      knobStyle: KnobStyle(
                        color: theme.colorScheme.secondary,
                        knobRadius: 0.08,
                      ),
                      tailStyle: TailStyle(
                        color: theme.colorScheme.secondary,
                        length: 0.1,
                        width: 1,
                      ),
                    ),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 100,
                      gradient: const SweepGradient(
                        colors: <Color>[downloadColor, Colors.deepOrangeAccent],
                        stops: <double>[0.5, 0.75],
                      ),
                    ),
                  ],
                  majorTickStyle: MajorTickStyle(
                    color: theme.colorScheme.error,
                    length: 0.1,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                  minorTickStyle: MinorTickStyle(
                    color: theme.colorScheme.error,
                    length: 0.05,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                ),
                // error rate
                RadialAxis(
                  radiusFactor: 0.45,
                  startAngle: 180,
                  endAngle: 360,
                  showLabels: false,
                  canScaleToFit: true,
                  annotations: [
                    GaugeAnnotation(
                      angle: 270,
                      positionFactor: 0.2,
                      widget: Text(
                        'Error Rate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    MarkerPointer(
                      value: 10,
                      enableAnimation: SystemSettings.showHomeAnimations,
                    ),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 100,
                      gradient: const SweepGradient(
                        colors: <Color>[
                          Colors.red,
                          Colors.redAccent,
                          packetErrorColor
                        ],
                        stops: <double>[0.25, 0.5, 0.75],
                      ),
                    ),
                  ],
                  majorTickStyle: MajorTickStyle(
                    color: theme.colorScheme.error,
                    length: 0.1,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                  minorTickStyle: MinorTickStyle(
                    color: theme.colorScheme.error,
                    length: 0.05,
                    lengthUnit: GaugeSizeUnit.factor,
                    thickness: 1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
