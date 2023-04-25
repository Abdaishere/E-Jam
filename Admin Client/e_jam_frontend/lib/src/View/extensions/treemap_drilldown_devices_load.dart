import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

// should include all the devices and their streams and the total packets (uploaded and downloaded) of each stream in the device
class TreeMapDrillDownDevicesLoad extends StatefulWidget {
  const TreeMapDrillDownDevicesLoad({super.key});

  @override
  State<TreeMapDrillDownDevicesLoad> createState() =>
      _TreeMapDrillDownDevicesLoadState();
}

class _TreeMapDrillDownDevicesLoadState
    extends State<TreeMapDrillDownDevicesLoad> {
  late List<DeviceInfo> _source;
  late Map<String, Color> _colors;

  @override
  void initState() {
    _source = <DeviceInfo>[
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Elantra', totalPackets: 198210),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Sonata', totalPackets: 131803),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Tucson', totalPackets: 114735),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Santa Fe', totalPackets: 133171),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Accent', totalPackets: 58955),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Veloster', totalPackets: 12658),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'loniq', totalPackets: 11197),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Azera', totalPackets: 3060),
      const DeviceInfo(
          deviceName: 'Server CX4', stream: 'Elantra', totalPackets: 198210),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'C-Class', totalPackets: 77447),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'GLE-Class', totalPackets: 54595),
      const DeviceInfo(
          deviceName: 'Server CX11',
          stream: 'E/ CLS-CLass',
          totalPackets: 51312),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'GLC-Class', totalPackets: 48643),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'GLS-Class', totalPackets: 322548),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'Sprinter', totalPackets: 27415),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'CLA-Class', totalPackets: 20669),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'GLA-Class', totalPackets: 24104),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'S-Class', totalPackets: 15888),
      const DeviceInfo(
          deviceName: 'Server CX11', stream: 'Metris', totalPackets: 7579),
      const DeviceInfo(
          deviceName: 'XYZ', stream: '3-Series', totalPackets: 59449),
      const DeviceInfo(deviceName: 'XYZ', stream: 'X5', totalPackets: 50815),
      const DeviceInfo(deviceName: 'XYZ', stream: 'X3', totalPackets: 40691),
      const DeviceInfo(
          deviceName: 'XYZ', stream: '5-Series', totalPackets: 40658),
      const DeviceInfo(
          deviceName: 'XYZ', stream: '4-Series', totalPackets: 39634),
      const DeviceInfo(
          deviceName: 'XYZ', stream: '2-Series', totalPackets: 11737),
      const DeviceInfo(
          deviceName: 'XYZ', stream: '7-Series', totalPackets: 9276),
      const DeviceInfo(deviceName: 'XYZ', stream: 'X1', totalPackets: 30826),
      const DeviceInfo(deviceName: 'XYZ', stream: 'X6', totalPackets: 6780),
      const DeviceInfo(deviceName: 'XYZ', stream: 'X4', totalPackets: 5198),
      const DeviceInfo(
          deviceName: 'XYZ', stream: '6-Series', totalPackets: 3355),
      const DeviceInfo(
          deviceName: 'F1', stream: 'Cherokee', totalPackets: 169822),
      const DeviceInfo(
          deviceName: 'F1', stream: 'Renegada', totalPackets: 103434),
      const DeviceInfo(
          deviceName: 'F1', stream: 'Wrangler', totalPackets: 190522),
      const DeviceInfo(
          deviceName: 'F1', stream: 'Compass', totalPackets: 83523),
      const DeviceInfo(
          deviceName: 'F1', stream: 'Patriot', totalPackets: 10735),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Rogue', totalPackets: 403465),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Sentra', totalPackets: 218451),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Murano', totalPackets: 76732),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Frontier', totalPackets: 74360),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Altima', totalPackets: 254996),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Versa', totalPackets: 106772),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Pathfinder', totalPackets: 81065),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Maxima', totalPackets: 67627),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Titan', totalPackets: 52924),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Armada', totalPackets: 35667),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'NV', totalPackets: 17858),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'NV200', totalPackets: 18602),
      const DeviceInfo(
          deviceName: 'CASX14Y', stream: 'Duke', totalPackets: 10157),
      const DeviceInfo(
          deviceName: '192.168.1.54', stream: 'Rogue', totalPackets: 403465),
      const DeviceInfo(
          deviceName: '192.168.1.54', stream: 'Sentra', totalPackets: 218451),
    ];
    _colors = <String, Color>{
      'Server CX4': deviceIdleColor,
      'XYZ': deviceOfflineOrErrorColor,
      'Server CX11': deviceRunningOrOnlineColor,
      'CASX14Y': deviceRunningOrOnlineColor,
      'F1': deviceRunningOrOnlineColor,
      'Ford': deviceRunningOrOnlineColor,
      '192.168.1.54': deviceRunningOrOnlineColor,
    };
    super.initState();
  }

  @override
  void dispose() {
    _source.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 10, right: 10),
        child: SfTreemap(
          legend: const TreemapLegend(
            position: TreemapLegendPosition.top,
            title: Text('Devices Load'),
          ),
          dataCount: _source.length,
          weightValueMapper: (int index) {
            return _source[index].totalPackets!;
          },
          enableDrilldown: true,
          breadcrumbs: TreemapBreadcrumbs(
            builder: (BuildContext context, TreemapTile tile, bool isCurrent) {
              if (tile.group == 'Home') {
                return const Icon(MaterialCommunityIcons.home, size: 20);
              } else {
                return Text(
                  tile.group,
                );
              }
            },
            divider: const Icon(Icons.chevron_right),
            position: TreemapBreadcrumbPosition.top,
          ),
          levels: [
            // Displays the device name in the first level.
            TreemapLevel(
              border: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
              ),
              padding: const EdgeInsets.all(1.0),
              groupMapper: (int index) => _source[index].deviceName,
              labelBuilder: (BuildContext context, TreemapTile tile) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                  child: Text(
                    tile.group,
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              colorValueMapper: (TreemapTile tile) {
                return _colors[_source[tile.indices[0]].deviceName];
              },
              tooltipBuilder: (BuildContext context, TreemapTile tile) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Device: ${tile.group}',
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            ),

            // Displays the stream name in the second level.
            TreemapLevel(
              border: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
              ),
              padding: const EdgeInsets.all(1.0),
              groupMapper: (int index) {
                return _source[index].stream;
              },
              colorValueMapper: (TreemapTile tile) {
                return _colors[_source[tile.indices[0]].deviceName];
              },
              labelBuilder: (BuildContext context, TreemapTile tile) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                  child: Text(
                    tile.group,
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              tooltipBuilder: (BuildContext context, TreemapTile tile) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Stream: ${tile.group}',
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceInfo {
  const DeviceInfo(
      {required this.deviceName,
      this.stream,
      this.version,
      this.versionNumber,
      this.totalPackets});
  final String deviceName;
  final String? stream;
  final String? version;
  final String? versionNumber;
  final double? totalPackets;
}
