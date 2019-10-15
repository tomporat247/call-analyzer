import 'package:contacts_service/contacts_service.dart';

class ContactService {
  Future<List<Contact>> getContacts() async {
    return (await ContactsService.getContacts(withThumbnails: false)).toList();
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
}
