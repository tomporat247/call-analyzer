import 'package:contacts_service/contacts_service.dart';

class ContactService {
  Future<List<Contact>> getContacts() async {
    List<Contact> contacts =
        (await ContactsService.getContacts(withThumbnails: false)).toList();
    contacts.forEach(_fixContactIterables);
    return contacts;
  }

  Future<Contact> getContactWithImage(Contact contact) async {
    Contact contactWithImage = (await ContactsService.getContacts(
            query: contact.displayName, withThumbnails: true))
        .first;
    if (contactWithImage.avatar.isEmpty) {
      contactWithImage.avatar = null;
    }
    return contactWithImage;
  }

  _fixContactIterables(Contact contact) {
    contact.phones = contact.phones.toList();
    contact.emails = contact.emails.toList();
    contact.postalAddresses = contact.postalAddresses.toList();
  }
}
