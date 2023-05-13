import 'dart:convert';
import 'package:e_jam/src/Model/Enums/processes.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';

class StreamEntry {
  StreamEntry({
    required this.name,
    required this.description,
    this.lastUpdated,
    this.startTime,
    this.endTime,
    required this.delay,
    required this.streamId,
    required this.generatorsIds,
    required this.verifiersIds,
    required this.payloadType,
    required this.burstLength,
    required this.burstDelay,
    required this.numberOfPackets,
    required this.payloadLength,
    required this.seed,
    required this.broadcastFrames,
    required this.interFrameGap,
    required this.timeToLive,
    required this.transportLayerProtocol,
    required this.flowType,
    required this.checkContent,
    this.runningGenerators,
    this.runningVerifiers,
    this.streamStatus,
  });

  final String name;
  final String description;
  final DateTime? lastUpdated;
  final DateTime? startTime;
  final DateTime? endTime;
  final num delay;
  final String streamId;
  final List<String> generatorsIds;
  final List<String> verifiersIds;
  final int payloadType;
  final num burstLength;
  final num burstDelay;
  final num numberOfPackets;
  final num payloadLength;
  final num seed;
  final num broadcastFrames;
  final num interFrameGap;
  final num timeToLive;
  final TransportLayerProtocol transportLayerProtocol;
  final FlowType flowType;
  final bool checkContent;
  final Process? runningGenerators;
  final Process? runningVerifiers;
  final StreamStatus? streamStatus;

  factory StreamEntry.fromRawJson(String str) =>
      StreamEntry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StreamEntry.fromJson(Map<String, dynamic> json) => StreamEntry(
        name: json["name"],
        description: json["description"],
        lastUpdated:
            DateTime.fromMillisecondsSinceEpoch(json["lastUpdated"] * 1000)
                .toLocal(),
        startTime:
            DateTime.fromMillisecondsSinceEpoch((json["startTime"] ?? 0) * 1000)
                .toLocal(),
        endTime:
            DateTime.fromMillisecondsSinceEpoch((json["endTime"] ?? 0) * 1000)
                .toLocal(),
        delay: (num.tryParse(json["delay"].toString()) ?? num.parse("-1")),
        streamId: json["streamId"],
        generatorsIds: List<String>.from(json["generatorsIds"].map((x) => x)),
        verifiersIds: List<String>.from(json["verifiersIds"].map((x) => x)),
        payloadType: json["payloadType"],
        burstLength:
            (num.tryParse(json["burstLength"].toString()) ?? num.parse("-1"))
                .floor(),
        burstDelay:
            (num.tryParse(json["burstDelay"].toString()) ?? num.parse("-1"))
                .floor(),
        numberOfPackets: (num.tryParse(json["numberOfPackets"].toString()) ??
                num.parse("-1"))
            .floor(),
        payloadLength:
            (num.tryParse(json["payloadLength"].toString()) ?? num.parse("-1"))
                .floor(),
        seed: (num.tryParse(json["seed"].toString()) ?? num.parse("-1")),
        broadcastFrames: (num.tryParse(json["broadcastFrames"].toString()) ??
                num.parse("-1"))
            .floor(),
        interFrameGap:
            (num.tryParse(json["interFrameGap"].toString()) ?? num.parse("-1"))
                .floor(),
        timeToLive:
            (num.tryParse(json["timeToLive"].toString()) ?? num.parse("-1"))
                .floor(),
        transportLayerProtocol:
            transportLayerProtocolFromString(json["transportLayerProtocol"]),
        flowType: flowTypeFromString(json["flowType"]),
        checkContent: json["checkContent"],
        runningGenerators: Process.fromJson(json["runningGenerators"]),
        runningVerifiers: Process.fromJson(json["runningVerifiers"]),
        streamStatus: streamStatusFromString(json["streamStatus"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "lastUpdated": lastUpdated,
        "startTime": startTime,
        "endTime": endTime,
        "delay": delay,
        "streamId": streamId,
        "generatorsIds": List<String>.from(generatorsIds.map((x) => x)),
        "verifiersIds": List<String>.from(verifiersIds.map((x) => x)),
        "payloadType": payloadType,
        "burstLength": burstLength,
        "burstDelay": burstDelay,
        "numberOfPackets": numberOfPackets,
        "payloadLength": payloadLength,
        "seed": seed,
        "broadcastFrames": broadcastFrames,
        "interFrameGap": interFrameGap,
        "timeToLive": timeToLive,
        "transportLayerProtocol":
            transportLayerProtocolToString(transportLayerProtocol),
        "flowType": flowTypeToString(flowType),
        "checkContent": checkContent,
        "runningGenerators": runningGenerators?.toJson(),
        "runningVerifiers": runningVerifiers?.toJson(),
        "streamStatus": streamStatus,
      };
}

class Process {
  Process({
    required this.processes,
  });

  const Process.empty() : processes = const {};

  final Map<String, ProcessStatus> processes;

  int get total => processes.length;
  int get progress => processes.values
      .where((element) => element == ProcessStatus.completed)
      .length;

  factory Process.fromRawJson(String str) => Process.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Process.fromJson(Map<String, dynamic> json) => Process(
        processes: Map.from(json).map((k, v) =>
            MapEntry<String, ProcessStatus>(k, processStatusFromString(v))),
      );

  Map<String, dynamic> toJson() => Map.from(processes)
      .map((k, v) => MapEntry<String, dynamic>(k, processStatusToString(v)));
}
