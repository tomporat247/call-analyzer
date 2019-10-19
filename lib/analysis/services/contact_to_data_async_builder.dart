import 'package:call_analyzer/helper/helper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';

class ContactToDataAsyncBuilder {
  static Future<Map<String, List<CallLogEntry>>> mapContactToCallLogs(
      List<Contact> contacts, List<CallLogEntry> callLogs) {
    return compute(_buildContactIdToCallLogs,
        {'contacts': contacts, 'callLogs': callLogs});
  }

  static Future<Map<String, int>> mapContactToCallDurationInSeconds(
      List<Contact> contacts,
      Map<String, List<CallLogEntry>> contactIdToCallLogs) {
    return compute(_buildContactToDurationInSeconds,
        {'contacts': contacts, 'contactIdToCallLogs': contactIdToCallLogs});
  }

  static Map<String, int> _buildContactToDurationInSeconds(Map args) {
    Map<String, int> contactIdToCallDurationInSeconds = new Map<String, int>();
    List<Contact> contacts = args['contacts'];
    Map<String, List<CallLogEntry>> contactIdToCallLogs =
        args['contactIdToCallLogs'];
    contacts.forEach((Contact contact) =>
        contactIdToCallDurationInSeconds[contact.identifier] =
            _getTotalCallDurationWith(contact, contactIdToCallLogs).inSeconds);
    return contactIdToCallDurationInSeconds;
  }

  static Duration _getTotalCallDurationWith(
      Contact contact, Map<String, List<CallLogEntry>> contactIdToCallLogs) {
    return Duration(
        seconds: contactIdToCallLogs[contact.identifier].fold<int>(
            0, (int curr, CallLogEntry callLog) => curr + callLog.duration));
  }

  static Map<String, List<CallLogEntry>> _buildContactIdToCallLogs(Map args) {
    Map<String, List<CallLogEntry>> contactIdToCallLogs =
        new Map<String, List<CallLogEntry>>();
    List<Contact> contacts = args['contacts'];
    List<CallLogEntry> callLogs = args['callLogs'];
    contacts.forEach((Contact contact) =>
        contactIdToCallLogs[contact.identifier] =
            _getAllCallLogsForContact(contact, callLogs));

    return contactIdToCallLogs;
  }

  static List<CallLogEntry> _getAllCallLogsForContact(
      Contact contact, List<CallLogEntry> callLogs) {
    return callLogs
        .where((CallLogEntry callLog) => (contact.displayName == callLog.name ||
            _contactHasPhoneNumber(contact, callLog.number) ||
            _contactHasPhoneNumber(contact, callLog.formattedNumber)))
        .toList();
  }

  static bool _contactHasPhoneNumber(Contact contact, String phoneNumber) {
    return contactHasPhoneNumber(contact, phoneNumber);
  }
}
