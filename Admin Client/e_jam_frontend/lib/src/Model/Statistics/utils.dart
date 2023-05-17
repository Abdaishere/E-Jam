import 'dart:math';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';

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
      num progress = Utils.valueMapper(
          fromStartToNow, fromStart, toEnd, 0, isDense ? 1 : 100, 5);

      return progress.toDouble();
    }
    return 0;
  }

  // get the oldest start time and the latest end time and calculate the progress
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
}
