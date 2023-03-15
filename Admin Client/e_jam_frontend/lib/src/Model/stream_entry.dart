import 'dart:convert';

class StreamEntry {
  StreamEntry({
    required this.name,
    required this.description,
    required this.lastUpdated,
    required this.startTime,
    required this.endTime,
    required this.delay,
    required this.streamId,
    required this.generatorsIds,
    required this.verifiersIds,
    required this.payloadType,
    required this.numberOfPackets,
    required this.payloadLength,
    required this.seed,
    required this.broadcastFrames,
    required this.interFrameGap,
    required this.timeToLive,
    required this.transportLayerProtocol,
    required this.flowType,
    required this.checkContent,
    required this.runningGenerators,
    required this.runningVerifiers,
    required this.streamStatus,
  });

  final String name;
  final String description;
  final int lastUpdated;
  final dynamic startTime;
  final dynamic endTime;
  final int delay;
  final String streamId;
  final List<String> generatorsIds;
  final List<String> verifiersIds;
  final int payloadType;
  final int numberOfPackets;
  final int payloadLength;
  final int seed;
  final int broadcastFrames;
  final int interFrameGap;
  final int timeToLive;
  final String transportLayerProtocol;
  final String flowType;
  final bool checkContent;
  final Running runningGenerators;
  final Running runningVerifiers;
  final String streamStatus;

  factory StreamEntry.fromRawJson(String str) =>
      StreamEntry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StreamEntry.fromJson(Map<String, dynamic> json) => StreamEntry(
        name: json["name"],
        description: json["description"],
        lastUpdated: json["lastUpdated"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        delay: json["delay"],
        streamId: json["streamId"],
        generatorsIds: List<String>.from(json["generatorsIds"].map((x) => x)),
        verifiersIds: List<String>.from(json["verifiersIds"].map((x) => x)),
        payloadType: json["payloadType"],
        numberOfPackets: json["numberOfPackets"],
        payloadLength: json["payloadLength"],
        seed: json["seed"],
        broadcastFrames: json["broadcastFrames"],
        interFrameGap: json["interFrameGap"],
        timeToLive: json["timeToLive"],
        transportLayerProtocol: json["transportLayerProtocol"],
        flowType: json["flowType"],
        checkContent: json["checkContent"],
        runningGenerators: Running.fromJson(json["runningGenerators"]),
        runningVerifiers: Running.fromJson(json["runningVerifiers"]),
        streamStatus: json["streamStatus"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "lastUpdated": lastUpdated,
        "startTime": startTime,
        "endTime": endTime,
        "delay": delay,
        "streamId": streamId,
        "generatorsIds": List<dynamic>.from(generatorsIds.map((x) => x)),
        "verifiersIds": List<dynamic>.from(verifiersIds.map((x) => x)),
        "payloadType": payloadType,
        "numberOfPackets": numberOfPackets,
        "payloadLength": payloadLength,
        "seed": seed,
        "broadcastFrames": broadcastFrames,
        "interFrameGap": interFrameGap,
        "timeToLive": timeToLive,
        "transportLayerProtocol": transportLayerProtocol,
        "flowType": flowType,
        "checkContent": checkContent,
        "runningGenerators": runningGenerators.toJson(),
        "runningVerifiers": runningVerifiers.toJson(),
        "streamStatus": streamStatus,
      };
}

class Running {
  Running();

  factory Running.fromRawJson(String str) => Running.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Running.fromJson(Map<String, dynamic> json) => Running();

  Map<String, dynamic> toJson() => {};
}
