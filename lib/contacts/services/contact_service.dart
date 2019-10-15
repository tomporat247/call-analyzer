import 'package:call_analyzer/helper/helper.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactService {
  Future<List<Contact>> getContacts() async {
    List<Contact> contacts =
        (await ContactsService.getContacts(withThumbnails: false)).toList();
    await _formatContacts(contacts);
    return contacts;
  }

  Future<void> _formatContacts(List<Contact> contacts) async {
    contacts.forEach((Contact contact) => contact.phones
        .forEach((phone) => phone.value = formatPhoneNumber(phone.value)));
  }
}
