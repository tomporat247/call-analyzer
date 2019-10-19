import 'package:call_analyzer/analysis/services/analysis_service_async_helper.dart';
import 'package:call_analyzer/models/sort_option.dart';
import 'package:call_analyzer/contacts/services/contact_service.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';

class AnalysisService {
  final ContactService _contactService;
  List<Contact> _contacts;
  List<CallLogEntry> _callLogs;
  Map<String, List<CallLogEntry>> _contactIdToCallLogs;
  Map<String, int> _contactIdToCallDurationInSeconds;

  List<Contact> get contacts => _contacts;

  List<CallLogEntry> get callLogs => _callLogs;

  AnalysisService(this._contactService);

  init(List<Contact> contacts, List<CallLogEntry> callLogs) async {
    _contactIdToCallDurationInSeconds = new Map<String, int>();
    _contactIdToCallLogs = new Map<String, List<CallLogEntry>>();
    _callLogs = callLogs;
    _contacts = contacts;

    // TODO: Figure out how to run these in compute
    _contacts.forEach((Contact contact) =>
    _contactIdToCallLogs[contact.identifier] = _getAllCallLogsForContact(contact));

    _contacts.forEach((Contact contact) =>
    _contactIdToCallDurationInSeconds[contact.identifier] =
            _getTotalCallDurationWith(contact).inSeconds);
  }

  Contact getContactFromCallLog(CallLogEntry callLog) {
    return _contacts.firstWhere(
        (Contact contact) =>
            contact.displayName == callLog.name ||
            _contactHasPhoneNumber(contact, callLog.number) ||
            _contactHasPhoneNumber(contact, callLog.formattedNumber),
        orElse: () => null);
  }

  CallLogEntry getLongestCallLog() {
    CallLogEntry longest = CallLogEntry(duration: 0);
    _callLogs.forEach((CallLogEntry callLog) {
      if (callLog.duration > longest.duration) {
        longest = callLog;
      }
    });
    return longest;
  }

  Map<String, dynamic> getMostCallsInADayData() {
    Map<String, dynamic> ans = new Map<String, dynamic>();
    DateTime prevDate =
        DateTime.fromMillisecondsSinceEpoch(_callLogs.first.timestamp);
    int amount = 0;
    DateTime maxDate;
    int maxAmount = 0;
    _callLogs.forEach((CallLogEntry callLog) {
      DateTime newDate = DateTime.fromMillisecondsSinceEpoch(callLog.timestamp);
      if (newDate.day == prevDate.day) {
        amount++;
      } else {
        if (amount > maxAmount) {
          maxAmount = amount;
          maxDate = prevDate;
        }
        amount = 0;
      }
      prevDate = newDate;
    });

    ans['date'] = maxDate;
    ans['amount'] = maxAmount;
    return ans;
  }

  int getContactAmount() {
    return _contacts.length;
  }

  int getAmountOfTotalCallLogs() {
    return _callLogs.length;
  }

  List<CallLogEntry> getAllCallLogsOfType(CallType callType) {
    return _callLogs.where((CallLogEntry c) => c.callType == callType).toList();
  }

  DateTime getFirstCallDate() {
    return DateTime.fromMillisecondsSinceEpoch(_callLogs.last.timestamp);
  }

  Duration getTotalCallDurationFor(Contact contact) {
    return Duration(seconds: _contactIdToCallDurationInSeconds[contact.identifier]);
  }

  Duration getTotalCallDuration() {
    int totalSeconds = _contacts.fold<int>(
        0,
        (int curr, Contact contact) =>
            curr + _contactIdToCallDurationInSeconds[contact.identifier]);
    return Duration(seconds: totalSeconds);
  }

  List<CallLogEntry> getCallLogsFor(Contact contact) {
    return _contactIdToCallLogs[contact.identifier];
  }

  Future<Contact> getContactWithImage(Contact contact) async {
    if (contact.avatar.isEmpty) {
      Contact contactWithImage =
          await _contactService.getContactWithImage(contact);
      _updateContact(contactWithImage);
      return contactWithImage;
    } else {
      return contact;
    }
  }

  Future<List<Contact>> getTopContacts(
      {SortOption sortOption: SortOption.CALL_DURATION, int amount}) async {
    List<Contact> contacts = await _getSortedContacts(sortOption);
    if (amount != null) {
      contacts = contacts.take(amount).toList();
    }
    return contacts;
  }

  _updateContact(Contact contactToUpdate) {
    int index = _contacts.indexWhere(
        (Contact contact) => contact.identifier == contactToUpdate.identifier);
    _contacts[index].avatar = contactToUpdate.avatar;
  }

  Future<List<Contact>> _getSortedContacts(SortOption sortOption) {
    List<Contact> contactsCopy = List.from(_contacts);
    switch (sortOption) {
      case SortOption.CALL_DURATION:
        return _sortContactsByCallDuration(contactsCopy);
      case SortOption.CALL_AMOUNT:
        return _sortContactsByCallAmount(contactsCopy);
      case SortOption.ALPHABETICAL:
        return _sortContactsByName(contactsCopy);
      default:
        return null;
    }
  }

  Future<List<Contact>> _sortContactsByCallDuration(
      List<Contact> contacts) async {
    return AnalysisServiceAsyncHelper.asyncSort<Contact>(
        contacts,
        AnalysisServiceAsyncHelper.compareByCallDuration,
        _contactIdToCallLogs,
        _contactIdToCallDurationInSeconds);
  }

  Future<List<Contact>> _sortContactsByCallAmount(
      List<Contact> contacts) async {
    return AnalysisServiceAsyncHelper.asyncSort<Contact>(
        contacts,
        AnalysisServiceAsyncHelper.compareByCallAmount,
        _contactIdToCallLogs,
        _contactIdToCallDurationInSeconds);
  }

  Future<List<Contact>> _sortContactsByName(List<Contact> contacts) async {
    return contacts
      ..sort((Contact one, Contact two) =>
          one.displayName.compareTo(two.displayName));
  }

  Duration _getTotalCallDurationWith(Contact contact) {
    return Duration(
        seconds: _contactIdToCallLogs[contact.identifier].fold<int>(
            0, (int curr, CallLogEntry callLog) => curr + callLog.duration));
  }

  List<CallLogEntry> _getAllCallLogsForContact(Contact contact) {
    return _callLogs
        .where((CallLogEntry callLog) => (contact.displayName == callLog.name ||
            _contactHasPhoneNumber(contact, callLog.number) ||
            _contactHasPhoneNumber(contact, callLog.formattedNumber)))
        .toList();
  }

  // TODO: Verify that this works
  bool _contactHasPhoneNumber(Contact contact, String callLogPhone) {
    return contact.phones
        .map((phone) => formatPhoneNumber(phone.value))
        .contains(formatPhoneNumber(callLogPhone));
  }
}
