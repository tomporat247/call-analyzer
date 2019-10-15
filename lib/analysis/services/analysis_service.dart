import 'package:call_analyzer/analysis/models/SortOption.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';

class AnalysisService {
  List<Contact> _contacts;
  List<CallLogEntry> _callLogs;

  init(List<Contact> contacts, List<CallLogEntry> callLogs) {
    _contacts = contacts;
    _callLogs = callLogs;
  }

  _getSortedContacts(SortOption sortOption) {
    List<Contact> contactsCopy = List.from(_contacts);
    switch (sortOption) {
      case SortOption.CALL_DURATION:
        _sortContactsByCallDuration(contactsCopy);
        break;
      case SortOption.CALL_AMOUNT:
        _sortContactsByCallAmount(contactsCopy);
        break;
      case SortOption.ALPHABETICAL:
        _sortContactsByName(contactsCopy);
        break;
    }
    return contactsCopy;
  }

  _sortContactsByCallDuration(List<Contact> contacts) {
    contacts.sort((Contact one, Contact two) => _getTotalCallDurationWith(two)
        .compareTo(_getTotalCallDurationWith(one)));
  }

  _sortContactsByCallAmount(List<Contact> contacts) {
    contacts.sort((Contact one, Contact two) =>
        _getTotalCallAmountWith(two).compareTo(_getTotalCallAmountWith(one)));
  }

  _sortContactsByName(List<Contact> contacts) {
    contacts.sort((Contact one, Contact two) =>
        two.displayName.compareTo(one.displayName));
  }

  Duration _getTotalCallDurationWith(Contact contact) {
    return Duration(
        seconds: _getAllCallLogsForContact(contact).fold<int>(
            0, (int curr, CallLogEntry callLog) => curr + callLog.duration));
  }

  int _getTotalCallAmountWith(Contact contact) {
    return _getAllCallLogsForContact(contact).length;
  }

  List<CallLogEntry> _getAllCallLogsForContact(Contact contact,
      [CallType callType]) {
    return _callLogs
        .where((CallLogEntry callLog) =>
            (callType == null || callType == callLog.callType) &&
            (contact.displayName == callLog.name ||
                _contactHasPhoneNumber(contact, callLog.number) ||
                _contactHasPhoneNumber(contact, callLog.formattedNumber)))
        .toList();
  }

  bool _contactHasPhoneNumber(Contact contact, String callLogPhone) {
    return contact.phones
        .map((phone) => formatPhoneNumber(phone.value))
        .contains(formatPhoneNumber(callLogPhone));
  }
}
