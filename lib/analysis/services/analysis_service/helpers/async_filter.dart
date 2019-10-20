import 'package:call_analyzer/helper/helper.dart';
import 'package:call_log/call_log.dart';
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

  static bool filterByDate(CallLogEntry callLog, Map args) {
    DateTime dateTime = getCallLogDateTime(callLog);
    return dateTime.isBefore(args['filterTo']) &&
        dateTime.isAfter(args['filterFrom']);
  }
}
