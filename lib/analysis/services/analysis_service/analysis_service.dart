import 'package:call_analyzer/analysis/services/analysis_service/helpers/async_filter.dart';
import 'package:call_analyzer/analysis/services/analysis_service/helpers/async_mapper.dart';
import 'package:call_analyzer/analysis/services/analysis_service/helpers/async_sorter.dart';
import 'package:call_analyzer/contacts/services/contact_service.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_analyzer/models/sort_option.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';

import 'helpers/contact_to_data_async_builder.dart';

class AnalysisService {
  final ContactService _contactService;
  DateTime _filterFrom;
  DateTime _filterTo;
  List<CallLogInfo> _allCallLogs;
  List<Contact> _contacts;
  List<CallLogInfo> _callLogs;
  Map<String, List<CallLogInfo>> _contactIdToCallLogs;
  Map<String, int> _contactIdToCallDurationInSeconds;
  bool _isFilteringByDate;

  bool get isFilteringByDate => _isFilteringByDate;

  DateTime get filterFrom => _filterFrom;

  DateTime get filterTo => _filterTo;

  List<Contact> get contacts => _contacts;

  List<CallLogInfo> get callLogs => _callLogs;

  AnalysisService(this._contactService);

  _setupContactToDataMaps() async {
    _contactIdToCallLogs = await ContactToDataAsyncBuilder.mapContactToCallLogs(
        _contacts, _callLogs);
    _contactIdToCallDurationInSeconds =
        await ContactToDataAsyncBuilder.mapContactToCallDurationInSeconds(
            _contacts, _contactIdToCallLogs);
  }

  init(List<Contact> contacts, List<CallLogEntry> callLogs) async {
    _allCallLogs =
        await AsyncMapper.asyncMap<CallLogEntry, CallLogInfo, List<Contact>>(
            callLogs, contacts, AsyncMapper.callLogEntryToCallLogInfo);
    _callLogs = _allCallLogs;
    _isFilteringByDate = false;
    _contacts = contacts;
    _filterFrom = getFirstCallDate();
    _filterTo = DateTime.now();
    await _setupContactToDataMaps();
  }

  Future<void> filterByDate({DateTime from, DateTime to}) async {
    _filterFrom = from ?? _filterFrom;
    _filterTo = to ?? _filterTo;
    _callLogs = await AsyncFilter.asyncFilter(
        _allCallLogs, AsyncFilter.filterByDate,
        filterFrom: _filterFrom, filterTo: _filterTo);
    await _setupContactToDataMaps();
    _isFilteringByDate = (_filterFrom
                .difference(getFirstCallDate(firstFromAllTime: true))
                .inDays !=
            0) ||
        (_filterTo.difference(DateTime.now()).inDays != 0);
  }

  CallLogInfo getLongestCallLog() {
    CallLogInfo longest = CallLogInfo(duration: Duration());
    _callLogs.forEach((CallLogInfo callLog) {
      if (callLog.duration > longest.duration) {
        longest = callLog;
      }
    });
    return longest;
  }

  Map<String, dynamic> getMostCallsInADayData() {
    Map<String, dynamic> ans = new Map<String, dynamic>();
    DateTime prevDate = getFirstCallDate();
    int amount = 0;
    DateTime maxDate = prevDate;
    int maxAmount = amount;
    _callLogs.forEach((CallLogInfo callLog) {
      if (callLog.dateTime.day == prevDate.day) {
        amount++;
      } else {
        if (amount > maxAmount) {
          maxAmount = amount;
          maxDate = prevDate;
        }
        amount = 0;
      }
      prevDate = callLog.dateTime;
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

  List<CallLogInfo> getAllCallLogsOfType(CallType callType) {
    return _callLogs.where((CallLogInfo c) => c.callType == callType).toList();
  }

  DateTime getFirstCallDate({firstFromAllTime = false}) {
    DateTime dateTime =
        (firstFromAllTime ? _allCallLogs : _callLogs).last.dateTime;
    dateTime.subtract(Duration(seconds: 1));
    return dateTime;
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

  List<CallLogInfo> getCallLogsFor(Contact contact) {
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
