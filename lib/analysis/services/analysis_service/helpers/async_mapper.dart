import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';

class AsyncMapper {
  static Future<List<New>> asyncMap<Original, New, HelperList>(
      List<Original> original,
      HelperList helperList,
      New Function(Original element, HelperList helper) mapFunction) async {
    return (await compute(_mapBy, {
      'original': original,
      'helperList': helperList,
      'mapFunction': mapFunction
    }))
        .cast<New>()
        .toList();
  }

  static List<New> _mapBy<Original, New, HelperList>(Map args) {
    List<Original> list = args["original"];
    HelperList helper = args['helperList'];
    var map = args["mapFunction"];
    return list.map((Original element) => map(element, helper)).toList();
  }

  static CallLogInfo callLogEntryToCallLogInfo(
      CallLogEntry callLog, List<Contact> contacts) {
    return CallLogInfo(
        contact: _getContactFromCallLog(callLog, contacts),
        duration: Duration(seconds: callLog.duration),
        number: callLog.number,
        formattedNumber: callLog.formattedNumber,
        callType: callLog.callType,
        name: callLog.name,
        dateTime: DateTime.fromMillisecondsSinceEpoch(callLog.timestamp));
  }

  static Contact _getContactFromCallLog(
      CallLogEntry callLog, List<Contact> contacts) {
    return contacts.firstWhere(
        (Contact contact) =>
            contact.displayName == callLog.name ||
            contactHasPhoneNumber(contact, callLog.number) ||
            contactHasPhoneNumber(contact, callLog.formattedNumber),
        orElse: () => null);
  }
}
