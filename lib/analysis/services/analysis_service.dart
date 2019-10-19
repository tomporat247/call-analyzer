import 'package:call_analyzer/analysis/services/async_sorter.dart';
import 'package:call_analyzer/models/sort_option.dart';
import 'package:call_analyzer/contacts/services/contact_service.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'contact_to_data_async_builder.dart';

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
    _callLogs = callLogs;
    _contacts = contacts;
    _contactIdToCallLogs = await ContactToDataAsyncBuilder.mapContactToCallLogs(
        _contacts, _callLogs);
    _contactIdToCallDurationInSeconds =
        await ContactToDataAsyncBuilder.mapContactToCallDurationInSeconds(
            _contacts, _contactIdToCallLogs);
  }

  Contact getContactFromCallLog(CallLogEntry callLog) {
    return _contacts.firstWhere(
        (Contact contact) =>
            contact.displayName == callLog.name ||
            contactHasPhoneNumber(contact, callLog.number) ||
            contactHasPhoneNumber(contact, callLog.formattedNumber),
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
    return Duration(
        seconds: _contactIdToCallDurationInSeconds[contact.identifier]);
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
    return AsyncSorter.asyncSort<Contact>(contacts,
        AsyncSorter.compareByCallDuration, _contactIdToCallDurationInSeconds);
  }

  Future<List<Contact>> _sortContactsByCallAmount(
      List<Contact> contacts) async {
    return AsyncSorter.asyncSort<Contact>(
        contacts, AsyncSorter.compareByCallAmount, _contactIdToCallLogs);
  }

  Future<List<Contact>> _sortContactsByName(List<Contact> contacts) async {
    return contacts
      ..sort((Contact one, Contact two) =>
          one.displayName.compareTo(two.displayName));
  }
}
