// To parse this JSON data, do
//
//     final verifierStatisticsInstance = verifierStatisticsInstanceFromJson(jsonString);

import 'dart:convert';

class VerifierStatisticsInstance {
  final String macAddress;
  final String streamId;
  final int packetsCorrect;
  final int packetsErrors;
  final int packetsDropped;
  final int packetsOutOfOrder;
  final DateTime timestamp;

  VerifierStatisticsInstance({
    required this.macAddress,
    required this.streamId,
    required this.packetsCorrect,
    required this.packetsErrors,
    required this.packetsDropped,
    required this.packetsOutOfOrder,
    required this.timestamp,
  });

  factory VerifierStatisticsInstance.fromRawJson(String str) =>
      VerifierStatisticsInstance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerifierStatisticsInstance.fromJson(Map<String, dynamic> json) =>
      VerifierStatisticsInstance(
        macAddress: json["macAddress"],
        streamId: json["streamId"],
        packetsCorrect: json["packetsCorrect"],
        packetsErrors: json["packetsErrors"],
        packetsDropped: json["packetsDropped"],
        packetsOutOfOrder: json["packetsOutOfOrder"],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json["timestamp"] * 1000)
            .toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "macAddress": macAddress,
        "streamId": streamId,
        "packetsCorrect": packetsCorrect,
        "packetsErrors": packetsErrors,
        "packetsDropped": packetsDropped,
        "packetsOutOfOrder": packetsOutOfOrder,
        "timestamp": timestamp,
      };
}
