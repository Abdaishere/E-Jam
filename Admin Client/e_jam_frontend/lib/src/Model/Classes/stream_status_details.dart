import 'dart:convert';

import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';

class StreamStatusDetails {
  StreamStatusDetails({
    required this.name,
    required this.id,
    required this.status,
    required this.lastUpdated,
    required this.startTime,
    required this.endTime,
  });

  final String name;
  final String id;
  final StreamStatus status;
  final DateTime lastUpdated;
  final DateTime startTime;
  final DateTime endTime;

  factory StreamStatusDetails.fromRawJson(String str) =>
      StreamStatusDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StreamStatusDetails.fromJson(Map<String, dynamic> json) =>
      StreamStatusDetails(
        name: json["name"],
        id: json["streamId"],
        status: streamStatusFromString(json["streamStatus"]),
        lastUpdated:
            DateTime.fromMillisecondsSinceEpoch(json["lastUpdated"] * 1000)
                .toLocal(),
        startTime:
            DateTime.fromMillisecondsSinceEpoch((json["startTime"] ?? 0) * 1000)
                .toLocal(),
        endTime:
            DateTime.fromMillisecondsSinceEpoch((json["endTime"] ?? 0) * 1000)
                .toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "streamId": id,
        "streamStatus": status,
        "lastUpdated": lastUpdated,
        "startTime": startTime,
        "endTime": endTime,
      };
}
