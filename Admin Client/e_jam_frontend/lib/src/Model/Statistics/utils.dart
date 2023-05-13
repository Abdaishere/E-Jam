import 'dart:math';
import 'package:e_jam/src/Model/Enums/stream_data_enums.dart';

class Utils {
  static double mapOneRangeToAnother(num sourceNumber, num fromA, num fromB,
      num toA, num toB, int decimalPrecision) {
    num deltaA = fromB - fromA;
    num deltaB = toB - toA;
    num scale = deltaB / deltaA;
    num negA = -1 * fromA;
    num offset = (negA * scale) + toA;
    num finalNumber = (sourceNumber * scale) + offset;
    num calcScale = pow(10, decimalPrecision);
    return ((finalNumber * calcScale).round() / calcScale);
  }

  static double getProgress(StreamStatus status, DateTime? startTime,
      DateTime? endTime, bool isDense) {
    if (status == StreamStatus.running ||
        status == StreamStatus.stopped ||
        status == StreamStatus.error) {
      if (startTime == null) return 0;
      if (endTime == null) return 50;
      if (endTime.difference(startTime).inSeconds <= 0) return 0;
      DateTime epoch = DateTime.fromMicrosecondsSinceEpoch(0);
      num fromStartToNow = DateTime.now().difference(epoch).inSeconds;
      num toEnd = endTime.difference(epoch).inSeconds;

      num progress = Utils.mapOneRangeToAnother(
          fromStartToNow, 0, toEnd, isDense ? 1 : 100, 0, 5);

      return progress.toDouble();
    } else if (status == StreamStatus.finished) {
      return isDense ? 1 : 100;
    } else {
      return 0;
    }
  }
}
