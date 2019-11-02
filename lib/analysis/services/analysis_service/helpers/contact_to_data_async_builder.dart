import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';

class ContactToDataAsyncBuilder {
  static Future<Map<String, List<CallLogInfo>>> mapContactToCallLogs(
      List<Contact> contacts, List<CallLogInfo> callLogs) {
    return compute(_buildContactIdToCallLogs,
        {'contacts': contacts, 'callLogs': callLogs});
  }

  static Future<Map<String, int>> mapContactToCallDurationInSeconds(
      List<Contact> contacts,
      Map<String, List<CallLogInfo>> contactIdToCallLogs) {
    return compute(_buildContactToDurationInSeconds,
        {'contacts': contacts, 'contactIdToCallLogs': contactIdToCallLogs});
  }

  static Map<String, int> _buildContactToDurationInSeconds(Map args) {
    Map<String, int> contactIdToCallDurationInSeconds = new Map<String, int>();
    List<Contact> contacts = args['contacts'];
    Map<String, List<CallLogInfo>> contactIdToCallLogs =
        args['contactIdToCallLogs'];
    contacts.forEach((Contact contact) =>
        contactIdToCallDurationInSeconds[contact.identifier] =
            _getTotalCallDurationWith(contact, contactIdToCallLogs).inSeconds);
    return contactIdToCallDurationInSeconds;
  }

  static Duration _getTotalCallDurationWith(
      Contact contact, Map<String, List<CallLogInfo>> contactIdToCallLogs) {
    return contactIdToCallLogs[contact.identifier].fold<Duration>(Duration(),
        (Duration curr, CallLogInfo callLog) => curr + callLog.duration);
  }

  static Map<String, List<CallLogInfo>> _buildContactIdToCallLogs(Map args) {
    Map<String, List<CallLogInfo>> contactIdToCallLogs =
        new Map<String, List<CallLogInfo>>();
    List<Contact> contacts = args['contacts'];
    List<CallLogInfo> callLogs = args['callLogs'];
    contacts.forEach((Contact contact) =>
        contactIdToCallLogs[contact.identifier] =
            _getAllCallLogsForContact(contact, callLogs));

    return contactIdToCallLogs;
  }

  static List<CallLogInfo> _getAllCallLogsForContact(
      Contact contact, List<CallLogInfo> callLogs) {
    return callLogs
        .where((CallLogInfo callLog) => (contact.displayName == callLog.name ||
            _contactHasPhoneNumber(contact, callLog.number) ||
            _contactHasPhoneNumber(contact, callLog.formattedNumber)))
        .toList()
          ..sort((CallLogInfo one, CallLogInfo two) =>
              one.dateTime.compareTo(two.dateTime));
  }

  static bool _contactHasPhoneNumber(Contact contact, String phoneNumber) {
    return contactHasPhoneNumber(contact, phoneNumber);
  }
}
