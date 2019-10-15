import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';

class AnalysisService {
  List<Contact> _contacts;
  List<CallLogEntry> _callLogs;

  init(List<Contact> contacts, List<CallLogEntry> callLogs) {
    _contacts = contacts;
    _callLogs = callLogs;
    _sortContactsByCallDuration();
  }

  _sortContactsByCallDuration() {
    _contacts.sort((Contact one, Contact two) => _getTotalCallDurationWith(two)
        .compareTo(_getTotalCallDurationWith(one)));
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
            (callType == null || callLog.callType == callType) &&
            (contact.displayName == callLog.name ||
                contact.phones
                    .map((phone) => phone.value)
                    .contains(callLog.number) ||
                contact.phones
                    .map((phone) => phone.value)
                    .contains(callLog.formattedNumber)))
        .toList();
  }
}
