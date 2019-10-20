import 'package:call_analyzer/widgets/contact_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'contact_profile.dart';

class ContactTile extends StatelessWidget {
  final Contact _contact;
  final String trailingText;
  final Widget trailingWidget;

  ContactTile(this._contact, {this.trailingText, this.trailingWidget});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ContactProfile(_contact))),
      leading: ContactImage(contact: _contact),
      title: Text(
        _contact.displayName,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailingWidget ??
          Text(
            trailingText,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
    );
  }
}
