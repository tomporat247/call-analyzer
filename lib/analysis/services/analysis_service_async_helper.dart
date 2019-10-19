import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';

class AnalysisServiceAsyncHelper {
  static Map<String, List<CallLogEntry>> contactIdToCallLogs;
  static Map<String, int> contactIdToCallDurationInSeconds;

  static Future<List<T>> asyncSort<T>(
      List<T> list,
      int Function(T a, T b) compareFunction,
      Map<String, List<CallLogEntry>> contactIdToCallLogs,
      Map<String, int> contactIdToCallDurationInSeconds) async {
    return compute(_sortWith, {
      'list': list,
      'compare': compareFunction,
      'contactIdToCallLogs': contactIdToCallLogs,
      'contactIdToCallDurationInSeconds': contactIdToCallDurationInSeconds
    });
  }

  static List<T> _sortWith<T>(Map args) {
    List<T> list = args["list"];
    var compare = args["compare"];
    contactIdToCallLogs = args['contactIdToCallLogs'];
    contactIdToCallDurationInSeconds = args['contactIdToCallDurationInSeconds'];
    return list..sort((a, b) => compare(a, b));
  }

  static int compareByCallDuration(Contact one, Contact two) {
    return contactIdToCallDurationInSeconds[two.identifier]
        .compareTo(contactIdToCallDurationInSeconds[one.identifier]);
  }

  static int compareByCallAmount(Contact one, Contact two) {
    return contactIdToCallLogs[two.identifier]
        .length
        .compareTo(contactIdToCallLogs[one.identifier].length);
  }
}
