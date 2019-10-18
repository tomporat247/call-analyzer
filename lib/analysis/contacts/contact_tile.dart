import 'package:call_analyzer/widgets/contact_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'contact_profile.dart';

class ContactTile extends StatelessWidget {
  final Contact _contact;
  final int _rank;

  ContactTile(this._contact, [this._rank]);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ContactProfile(_contact))),
      leading: ContactImage(_contact),
      title: Text(_contact.displayName),
      trailing: Text(
        '#$_rank',
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}
