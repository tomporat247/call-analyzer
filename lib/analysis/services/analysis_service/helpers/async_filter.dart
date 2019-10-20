import 'package:call_analyzer/models/call_log_info.dart';
import 'package:flutter/foundation.dart';

class AsyncFilter {
  static Future<List<T>> asyncFilter<T>(
      List<T> list, bool Function(T element, Map args) filterFunction,
      {DateTime filterTo, DateTime filterFrom}) async {
    return compute(_filterBy, {
      'list': list,
      'filter': filterFunction,
      'filterTo': filterTo,
      'filterFrom': filterFrom
    });
  }

  static List<T> _filterBy<T>(Map args) {
    List<T> list = args["list"];
    var filter = args["filter"];
    return list.where((T element) => filter(element, args)).toList();
  }

  static bool filterByDate(CallLogInfo callLog, Map args) {
    return callLog.dateTime.isBefore(args['filterTo']) &&
        callLog.dateTime.isAfter(args['filterFrom']);
  }
}
