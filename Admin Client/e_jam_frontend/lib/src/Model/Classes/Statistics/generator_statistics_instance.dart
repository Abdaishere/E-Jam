// To parse this JSON data, do
//
//     final generatorStatisticsInstance = generatorStatisticsInstanceFromJson(jsonString);

import 'dart:convert';

class GeneratorStatisticsInstance {
  final String macAddress;
  final String streamId;
  final int packetsSent;
  final int packetsErrors;

  GeneratorStatisticsInstance({
    required this.macAddress,
    required this.streamId,
    required this.packetsSent,
    required this.packetsErrors,
  });

  factory GeneratorStatisticsInstance.fromRawJson(String str) =>
      GeneratorStatisticsInstance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GeneratorStatisticsInstance.fromJson(Map<String, dynamic> json) =>
      GeneratorStatisticsInstance(
        macAddress: json["mac_address"],
        streamId: json["stream_id"],
        packetsSent: json["packets_sent"],
        packetsErrors: json["packets_errors"],
      );

  Map<String, dynamic> toJson() => {
        "mac_address": macAddress,
        "stream_id": streamId,
        "packets_sent": packetsSent,
        "packets_errors": packetsErrors,
      };
}
