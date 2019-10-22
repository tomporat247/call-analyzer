import 'package:call_analyzer/widgets/select_contacts_type_ahead.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'app_dialog.dart';

class ContactPickerDialog extends StatefulWidget {
  final BuildContext _context;
  final List<Contact> contacts;

  ContactPickerDialog(this._context, {this.contacts});

  @override
  _ContactPickerDialogState createState() => _ContactPickerDialogState();

  Future<Contact> show() {
    return showDialog(
        context: _context, builder: (BuildContext context) => this);
  }
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  @override
  Widget build(BuildContext context) {
    return AppDialog(
      context: context,
      title: "Select Contact",
      actions: [],
      content: Row(
        children: <Widget>[
          Flexible(
            child: SelectContactsTypeAhead(
              context: context,
              autoFocus: true,
              contacts: widget.contacts,
              onSelected: (contact) {
                Navigator.of(context).pop(contact);
              },
              decoration: InputDecoration(labelText: "Contact Name"),
            ),
          )
        ],
      ),
    );
  }
}
