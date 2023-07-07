// To parse this JSON data, do
//
//     final generatorStatisticsInstance = generatorStatisticsInstanceFromJson(jsonString);

import 'dart:convert';

class GeneratorStatisticsInstance {
  final String macAddress;
  final String streamId;
  final int packetsSent;
  final int packetsErrors;
  final DateTime timestamp;

  GeneratorStatisticsInstance({
    required this.macAddress,
    required this.streamId,
    required this.packetsSent,
    required this.packetsErrors,
    required this.timestamp,
  });

  factory GeneratorStatisticsInstance.fromRawJson(String str) =>
      GeneratorStatisticsInstance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GeneratorStatisticsInstance.fromJson(Map<String, dynamic> json) =>
      GeneratorStatisticsInstance(
        macAddress: json["macAddress"],
        streamId: json["streamId"],
        packetsSent: json["packetsSent"],
        packetsErrors: json["packetsErrors"],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json["timestamp"] * 1000)
            .toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "macAddress": macAddress,
        "streamId": streamId,
        "packetsSent": packetsSent,
        "packetsErrors": packetsErrors,
        "timestamp": timestamp,
      };
}
