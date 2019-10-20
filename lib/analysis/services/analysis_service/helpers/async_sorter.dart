import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';

class AsyncSorter {

  static Future<List<T>> asyncSort<T>(
      List<T> list,
      int Function(T a, T b, Map<String, dynamic> helper) compareFunction,
      Map helperMap) async {
    return compute(_sortBy, {
      'list': list,
      'compare': compareFunction,
      'helperMap': helperMap,
    });
  }

  static List<T> _sortBy<T>(Map args) {
    List<T> list = args["list"];
    var compare = args["compare"];
    Map helperMap = args['helperMap'];
    return list..sort((a, b) => compare(a, b, helperMap));
  }

  static int compareByCallDuration(Contact one, Contact two,
      Map<String, dynamic> contactIdToCallDurationInSeconds) {
    return contactIdToCallDurationInSeconds[two.identifier]
        .compareTo(contactIdToCallDurationInSeconds[one.identifier]);
  }

  static int compareByCallAmount(
      Contact one, Contact two, Map<String, dynamic> contactIdToCallLogs) {
    return contactIdToCallLogs[two.identifier]
        .length
        .compareTo(contactIdToCallLogs[one.identifier].length);
  }
}
