import 'dart:convert';

class StreamStatusDetails {
  StreamStatusDetails({
    required this.name,
    required this.streamId,
    required this.streamStatus,
    required this.lastUpdated,
    required this.startTime,
    required this.endTime,
  });

  final String name;
  final String streamId;
  final String streamStatus;
  final dynamic lastUpdated;
  final dynamic startTime;
  final dynamic endTime;

  factory StreamStatusDetails.fromRawJson(String str) =>
      StreamStatusDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StreamStatusDetails.fromJson(Map<String, dynamic> json) =>
      StreamStatusDetails(
        name: json["name"],
        streamId: json["streamId"],
        streamStatus: json["streamStatus"],
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(json["lastUpdated"],
            isUtc: true),
        startTime:
            DateTime.fromMillisecondsSinceEpoch(json["startTime"], isUtc: true),
        endTime:
            DateTime.fromMillisecondsSinceEpoch(json["endTime"], isUtc: true),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "streamId": streamId,
        "streamStatus": streamStatus,
        "lastUpdated": lastUpdated,
        "startTime": startTime,
        "endTime": endTime,
      };
}
