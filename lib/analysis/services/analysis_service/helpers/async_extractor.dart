import 'package:call_analyzer/helper/data_structures/my_heap.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:flutter/foundation.dart';

class AsyncExtractor {
  static Future<List<Return>> asyncExtractor<Origin, Return>(List<Origin> list, int amount,
      List<Return> Function(List<Origin> list, int amount) extractorFunction) async {
    return compute(_extractBy,
        {'list': list, 'amount': amount, 'extractor': extractorFunction});
  }

  static List<Return> _extractBy<Origin, Return>(Map args) {
    List<Origin> list = args["list"];
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

  static List<Map> getMostCallsInADayData(
      List<CallLogInfo> callLogs, int amount) {
    MyHeap<Map> mostCallsInADay = new MyHeap<Map>(
        (dynamic a, dynamic b) => a['amount'].compareTo(b['amount']));

    for (int i = 0; i < amount; i++) {
      mostCallsInADay.insert({'amount': 0, 'date': DateTime.now()});
    }

    DateTime prevDate = callLogs.last.dateTime;
    int todayAmount = 0;
    callLogs.forEach((CallLogInfo callLog) {
      if (callLog.dateTime.day == prevDate.day) {
        todayAmount++;
      } else {
        if (todayAmount > mostCallsInADay.getHead()['amount']) {
          mostCallsInADay.removeHead();
          mostCallsInADay.insert({'amount': todayAmount, 'date': prevDate});
        }
        todayAmount = 0;
      }
      prevDate = callLog.dateTime;
    });

    if (todayAmount > mostCallsInADay.getHead()['amount']) {
      mostCallsInADay.removeHead();
      mostCallsInADay.insert({'amount': todayAmount, 'date': prevDate});
    }

    return mostCallsInADay.asList().reversed.toList();
  }
}
