import 'dart:convert';
import 'dart:ffi';

import 'package:e_jam/src/Model/Enums/processes.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';

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
  final DateTime lastUpdated;
  final DateTime startTime;
  final DateTime endTime;
  final UnsignedLong delay;
  final String streamId;
  final List<String> generatorsIds;
  final List<String> verifiersIds;
  final UnsignedShort payloadType;
  final UnsignedLong numberOfPackets;
  final UnsignedShort payloadLength;
  final UnsignedLong seed;
  final UnsignedLong broadcastFrames;
  final UnsignedLong interFrameGap;
  final UnsignedLong timeToLive;
  final TransportLayerProtocol transportLayerProtocol;
  final FlowType flowType;
  final bool checkContent;
  final Process runningGenerators;
  final Process runningVerifiers;
  final StreamStatus streamStatus;

  factory StreamEntry.fromRawJson(String str) =>
      StreamEntry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StreamEntry.fromJson(Map<String, dynamic> json) => StreamEntry(
        name: json["name"],
        description: json["description"],
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(json["lastUpdated"],
            isUtc: true),
        startTime:
            DateTime.fromMillisecondsSinceEpoch(json["startTime"], isUtc: true),
        endTime:
            DateTime.fromMillisecondsSinceEpoch(json["endTime"], isUtc: true),
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
        "runningGenerators": runningGenerators.toJson(),
        "runningVerifiers": runningVerifiers.toJson(),
        "streamStatus": streamStatus,
      };
}

class Process {
  Process({
    required this.processes,
  });

  late Map<String, ProcessStatus> processes;

  factory Process.fromRawJson(String str) => Process.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Process.fromJson(Map<String, ProcessStatus> json) => Process(
        processes: Map.from(json).map((k, v) =>
            MapEntry<String, ProcessStatus>(k, processStatusFromString(v))),
      );

  Map<String, dynamic> toJson() => Map.from(processes)
      .map((k, v) => MapEntry<String, dynamic>(k, processStatusToString(v)));
}
