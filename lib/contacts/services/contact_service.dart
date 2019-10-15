import 'package:contacts_service/contacts_service.dart';

class ContactService {
  Future<List<Contact>> getContacts() async {
    return (await ContactsService.getContacts(withThumbnails: false)).toList();
  }
}
