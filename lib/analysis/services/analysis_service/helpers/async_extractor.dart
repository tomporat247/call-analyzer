import 'package:call_analyzer/helper/data_structures/my_heap.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:flutter/foundation.dart';

class AsyncExtractor {
  static Future<List<T>> asyncExtractor<T>(List<T> list, int amount,
      List<T> Function(List<T> list, int amount) extractorFunction) async {
    return compute(_extractBy,
        {'list': list, 'amount': amount, 'extractor': extractorFunction});
  }

  static List<T> _extractBy<T>(Map args) {
    List<T> list = args["list"];
    int amount = args['amount'];
    var extractor = args["extractor"];
    return extractor(list, amount);
  }

  static List<CallLogInfo> getLongestCallLogs(
      List<CallLogInfo> callLogs, int amount) {
    MyHeap<CallLogInfo> longestCallLogs = new MyHeap<CallLogInfo>(
        (CallLogInfo a, CallLogInfo b) => a.duration.compareTo(b.duration));

    callLogs.take(amount).forEach((CallLogInfo callLog) {
      longestCallLogs.insert(callLog);
    });

    callLogs.skip(amount).forEach((CallLogInfo callLog) {
      if (callLog.duration > longestCallLogs.getHead().duration) {
        longestCallLogs.removeHead();
        longestCallLogs.insert(callLog);
      }
    });
    return longestCallLogs.asList().reversed.toList();
  }
}
