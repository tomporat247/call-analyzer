import 'package:call_analyzer/analysis/models/SortOption.dart';
import 'package:call_analyzer/contacts/services/contact_service.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';

class AnalysisService {
  final int topContactsAmount = 8;
  final ContactService _contactService;
  List<Contact> _contacts;
  List<CallLogEntry> _callLogs;
  Map<Contact, List<CallLogEntry>> _contactToCallLogs;
  Map<Contact, int> _contactToCallDurationInSeconds;

  List<Contact> get contacts => _contacts;

  AnalysisService(this._contactService);

  init(List<Contact> contacts, List<CallLogEntry> callLogs) async {
    _contactToCallDurationInSeconds = new Map<Contact, int>();
    _contactToCallLogs = new Map<Contact, List<CallLogEntry>>();
    _callLogs = callLogs;
    _contacts = contacts;

    // TODO: Figure out how to run these in compute
    _contacts.forEach((Contact contact) =>
        _contactToCallLogs[contact] = _getAllCallLogsForContact(contact));

    _contacts.forEach((Contact contact) =>
        _contactToCallDurationInSeconds[contact] =
            _getTotalCallDurationWith(contact).inSeconds);
  }

  DateTime getFirstCallDate() {
    return DateTime.fromMillisecondsSinceEpoch(_callLogs.last.timestamp);
  }

  Duration getTotalCallDurationFor(Contact contact) {
    return Duration(seconds: _contactToCallDurationInSeconds[contact]);
  }

  List<CallLogEntry> getCallLogsFor(Contact contact) {
    return _contactToCallLogs[contact];
  }

  Future<Contact> getContactWithImage(Contact contact) async {
    if (contact.avatar.isEmpty) {
      Contact contactWithImage =
          await _contactService.getContactWithImage(contact);
      _updateContact(contactWithImage);
      return contact;
    } else {
      return contact;
    }
  }

  Future<List<Contact>> getTopContacts(int amount) async {
    return (await _getSortedContacts(SortOption.CALL_DURATION))
        .take(amount)
        .toList();
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
    return asyncSort(
        contacts, (Contact c) => _contactToCallDurationInSeconds[c]);
  }

  Future<List<Contact>> _sortContactsByCallAmount(
      List<Contact> contacts) async {
    return asyncSort(contacts, (Contact c) => _contactToCallLogs[c].length);
  }

  Future<List<Contact>> _sortContactsByName(List<Contact> contacts) async {
    return contacts
      ..sort((Contact one, Contact two) =>
          one.displayName.compareTo(two.displayName));
  }

  Duration _getTotalCallDurationWith(Contact contact) {
    return Duration(
        seconds: _contactToCallLogs[contact].fold<int>(
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
