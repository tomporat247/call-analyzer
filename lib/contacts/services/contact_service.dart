import 'package:contacts_service/contacts_service.dart';

class ContactService {
  List<Contact> _contacts;

  List<Contact> get contacts => _contacts;

  Future<void> init() async {
    _contacts =
        (await ContactsService.getContacts(withThumbnails: false)).toList();
  }
}
