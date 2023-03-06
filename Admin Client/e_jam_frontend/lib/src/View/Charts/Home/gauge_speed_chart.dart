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
    return Consumer(
      builder: (context, ThemeModel theme, child) {
        return SfRadialGauge(
          title: const GaugeTitle(
            text: 'System Performance',
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          enableLoadingAnimation: true,
          animationDuration: 1500,
          axes: <RadialAxis>[
            // Acceptence rate for packets in the system
            RadialAxis(
              centerY: MediaQuery.of(context).size.height > 800 ? 0.35 : 0.3,
              radiusFactor:
                  MediaQuery.of(context).size.width > 1200 ? 0.6 : 0.5,
              startAngle: 205,
              endAngle: 335,
              showLabels: false,
              annotations: [
                GaugeAnnotation(
                  angle: 270,
                  positionFactor: 0.4,
                  widget: Text(
                    'Pkts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
              pointers: const <GaugePointer>[
                MarkerPointer(
                  value: 90,
                  enableAnimation: true,
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
              centerY: MediaQuery.of(context).size.height > 800 ? 0.53 : 0.5,
              centerX: MediaQuery.of(context).size.width > 1200 ? 0.27 : 0.25,
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
                  enableAnimation: true,
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
              centerY: MediaQuery.of(context).size.height > 800 ? 0.53 : 0.5,
              centerX: MediaQuery.of(context).size.width > 1200 ? 0.73 : 0.75,
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
                  enableAnimation: true,
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
              pointers: const <GaugePointer>[
                MarkerPointer(
                  value: 10,
                  enableAnimation: true,
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
    );
  }
}
