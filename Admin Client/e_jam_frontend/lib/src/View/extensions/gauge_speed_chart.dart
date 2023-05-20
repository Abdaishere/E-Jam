import 'package:e_jam/src/Model/Classes/Statistics/utils.dart';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
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
    SpeedInfoWrapper speedInfoWrapper = Utils.getUploadSpeed(
        context.watch<StatisticsController>().getGeneratorStatistics,
        context.watch<StatisticsController>().getVerifierStatistics);
    return buildGauge(context, speedInfoWrapper);
  }

  Card buildGauge(BuildContext context, SpeedInfoWrapper speedInfoWrapper) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(8),
      )),
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 450
            ? 340
            : MediaQuery.of(context).size.width,
        height: 280,
        child: Consumer(
          builder: (context, ThemeModel theme, child) {
            return SfRadialGauge(
              title: const GaugeTitle(
                text: 'Performance',
              ),
              enableLoadingAnimation: SystemSettings.showDashboardAnimations,
              animationDuration: 1500,
              axes: <RadialAxis>[
                // Acceptance rate for packets in the system
                RadialAxis(
                  centerY: 0.3,
                  radiusFactor:
                      MediaQuery.of(context).size.width > 450 ? 0.55 : 0.6,
                  startAngle: 205,
                  endAngle: 335,
                  showLabels: false,
                  annotations: [
                    GaugeAnnotation(
                      angle: 270,
                      positionFactor: 0.4,
                      widget: Text(
                        'AC Pkt',
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
                      value: speedInfoWrapper.accepted,
                      enableAnimation: SystemSettings.showDashboardAnimations,
                    ),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 100,
                      gradient: SweepGradient(
                        colors: <Color>[
                          Colors.greenAccent,
                          deviceStatusColorScheme(DeviceStatus.online),
                        ],
                        stops: const <double>[0.5, 0.75],
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
                  radiusFactor:
                      MediaQuery.of(context).size.width > 450 ? 0.6 : 0.65,
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
                      value: speedInfoWrapper.upload,
                      enableAnimation: SystemSettings.showDashboardAnimations,
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
                  radiusFactor:
                      MediaQuery.of(context).size.width > 450 ? 0.6 : 0.65,
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
                      value: speedInfoWrapper.download,
                      enableAnimation: SystemSettings.showDashboardAnimations,
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
                  startAngle: 180,
                  endAngle: 360,
                  radiusFactor:
                      MediaQuery.of(context).size.width > 450 ? 0.45 : 0.5,
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
                      value: speedInfoWrapper.errored,
                      enableAnimation: SystemSettings.showDashboardAnimations,
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
