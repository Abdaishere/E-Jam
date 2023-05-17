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

  VerifierStatisticsInstance({
    required this.macAddress,
    required this.streamId,
    required this.packetsCorrect,
    required this.packetsErrors,
    required this.packetsDropped,
    required this.packetsOutOfOrder,
  });

  factory VerifierStatisticsInstance.fromRawJson(String str) =>
      VerifierStatisticsInstance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerifierStatisticsInstance.fromJson(Map<String, dynamic> json) =>
      VerifierStatisticsInstance(
        macAddress: json["mac_address"],
        streamId: json["stream_id"],
        packetsCorrect: json["packets_correct"],
        packetsErrors: json["packets_errors"],
        packetsDropped: json["packets_dropped"],
        packetsOutOfOrder: json["packets_out_of_order"],
      );

  Map<String, dynamic> toJson() => {
        "mac_address": macAddress,
        "stream_id": streamId,
        "packets_correct": packetsCorrect,
        "packets_errors": packetsErrors,
        "packets_dropped": packetsDropped,
        "packets_out_of_order": packetsOutOfOrder,
      };
}
