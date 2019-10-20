import 'package:flutter/foundation.dart';

class CallLogAsyncFilter {
  static Future<List<T>> asyncFilter<T>(List<T> list,
      bool Function(T element, List<T> list) filterFunction) async {
    return compute(_filterBy, {
      'list': list,
      'filter': filterFunction,
    });
  }

  static List<T> _filterBy<T>(Map args) {
    List<T> list = args["list"];
    var filter = args["filter"];
    return list.where((T element) => filter(element, list)).toList();
  }

  static int compareByCallDuration(Contact one, Contact two,
      Map<String, dynamic> contactIdToCallDurationInSeconds) {
    return contactIdToCallDurationInSeconds[two.identifier]
        .compareTo(contactIdToCallDurationInSeconds[one.identifier]);
  }
}
