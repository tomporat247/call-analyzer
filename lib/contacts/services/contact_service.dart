import 'package:contacts_service/contacts_service.dart';

class ContactService {
  List<Contact> _contacts;

  List<Contact> get contacts => _contacts;

  Future<void> loadAllContacts() async {
    // TODO: set withThumbnails to false if it's too slow
    _contacts = (await ContactsService.getContacts()).toList();
  }
}
