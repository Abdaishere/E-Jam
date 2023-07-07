import 'dart:math';
import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';

class Utils {
  static double valueMapper(num sourceNumber, num fromStart, num fromEnd,
      num toStart, num toEnd, int decimalPrecision) {
    try {
      num deltaA = fromEnd - fromStart;
      num deltaB = toEnd - toStart;
      num scale = deltaB / deltaA;
      num negA = -1 * fromStart;
      num offset = (negA * scale) + toStart;
      num finalNumber = (sourceNumber * scale) + offset;
      num calcScale = pow(10, decimalPrecision);
      return ((finalNumber * calcScale).round() / calcScale);
    } catch (e) {
      return 0;
    }
  }

  static double getProgress(StreamStatus status, DateTime? startTime,
      DateTime? endTime, bool isDense, DateTime? nowTime) {
    if (status == StreamStatus.finished) return isDense ? 1 : 100;
    if (status == StreamStatus.running ||
        status == StreamStatus.error ||
        status == StreamStatus.stopped) {
      // sanity check
      if (startTime == null) return 0;
      if (endTime == null) return 50;
      if (endTime.difference(startTime).inSeconds <= 0) return 0;

      DateTime epoch = DateTime.fromMicrosecondsSinceEpoch(0);
      DateTime now = nowTime ?? DateTime.now();
      num fromStartToNow = now.difference(epoch).inSeconds;
      num fromStart = startTime.difference(epoch).inSeconds;
      num toEnd = endTime.difference(epoch).inSeconds;
      num progress = Utils.valueMapper(fromStartToNow, fromStart, toEnd, 0,
          isDense ? 1 : 100, isDense ? 5 : 2);

      return progress.toDouble();
    }
    return 0;
  }

  /// get the oldest start time and the latest end time and calculate the progress
  static double? getTotalProgress(List<StreamStatusDetails> streams) {
    DateTime epoch = DateTime.fromMicrosecondsSinceEpoch(0);
    num minStart = DateTime.now().difference(epoch).inSeconds;
    num maxEnd = DateTime.now().difference(epoch).inSeconds;
    bool hasRunning = false;

    for (final StreamStatusDetails stream in streams) {
      if (stream.streamStatus != StreamStatus.running) continue;
      hasRunning = true;
      num start = stream.startTime.difference(epoch).inSeconds;
      if (start < minStart) minStart = start;
      num end = stream.endTime.difference(epoch).inSeconds;
      if (end > maxEnd) maxEnd = end;
    }

    num fromStartToNow = DateTime.now().difference(epoch).inSeconds;
    return hasRunning
        ? Utils.valueMapper(fromStartToNow, minStart, maxEnd, 0, 100, 2)
        : 0;
  }

// Assuming a standard Ethernet frame size of 1500 bytes,
// a 10/100/1000 Ethernet port can transfer up to approximately 1.48 million packets per second at 10 Mbps,
// up to approximately 14.88 million packets per second at 100 Mbps,
// and up to approximately 148.81 million packets per second at 1000 Mbps (or 1 Gbps).
// Maybe add a setting for the max packets per second for upper bound
  static const upperBound = 1e5;
  static SpeedInfoWrapper getUploadSpeed(
      List<GeneratorStatisticsInstance> generatorStatistics,
      List<VerifierStatisticsInstance> verifierStatistics) {
    if (generatorStatistics.isEmpty || verifierStatistics.isEmpty) {
      return SpeedInfoWrapper(upload: 0, download: 0, accepted: 0, errored: 0);
    }

    double totalUpSpeed = 0;
    double totalUpErrors = 0;
    int counter1 = 0;
    int i = max(
        generatorStatistics.length - SystemSettings.lineGraphMaxDataPoints, 0);
    for (; i < generatorStatistics.length; i++) {
      counter1 += 1;
      int upSpeed = generatorStatistics[i].packetsSent;
      int upErrors = generatorStatistics[i].packetsErrors;
      totalUpSpeed += upSpeed;
      totalUpErrors += upErrors;
    }

    double totalDownErrors = 0;
    double totalDownSpeed = 0;
    int counter2 = 0;
    i = max(
        verifierStatistics.length - SystemSettings.lineGraphMaxDataPoints, 0);
    for (; i < verifierStatistics.length; i++) {
      counter2 += 1;
      int downSpeed = verifierStatistics[i].packetsCorrect +
          verifierStatistics[i].packetsOutOfOrder +
          verifierStatistics[i].packetsErrors;

      int downErrors = verifierStatistics[i].packetsDropped +
          verifierStatistics[i].packetsOutOfOrder +
          verifierStatistics[i].packetsErrors;

      totalDownSpeed += downSpeed;
      totalDownErrors += downErrors;
    }

    double upload =
        valueMapper(totalUpSpeed / counter1, 0, upperBound, 0, 100, 10);
    double download =
        valueMapper(totalDownSpeed / counter2, 0, upperBound, 0, 100, 10);

    double upError =
        valueMapper(totalUpErrors / counter1, 0, upperBound, 0, 100, 10);
    double downError =
        valueMapper(totalDownErrors / counter2, 0, upperBound, 0, 100, 10);

    return SpeedInfoWrapper(
        upload: upload,
        download: download,
        accepted: 100 - upError,
        errored: downError);
  }
}

class SpeedInfoWrapper {
  final double upload;
  final double download;
  final double accepted;
  final double errored;

  SpeedInfoWrapper(
      {required this.upload,
      required this.download,
      required this.accepted,
      required this.errored});
}
