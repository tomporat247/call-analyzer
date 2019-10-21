import 'package:call_analyzer/widgets/contact_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'contact_profile.dart';

class ContactTile extends StatelessWidget {
  final Contact _contact;
  final String trailingText;
  final String subtitleText;
  final Widget trailing;

  ContactTile(this._contact,
      {this.trailingText, this.trailing, this.subtitleText});

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
      subtitle: subtitleText != null ? Text(subtitleText) : null,
      trailing: trailing ??
          Text(
            trailingText,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
    );
  }
}
