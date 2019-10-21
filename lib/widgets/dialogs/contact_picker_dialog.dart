import 'package:call_analyzer/analysis/contacts/contact_tile.dart';
import 'package:call_analyzer/widgets/select_contacts_type_ahead.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_dialog.dart';

class ContactPickerDialog extends StatefulWidget {
  final BuildContext _context;
  final List<Contact> allContacts;
  final List<Contact> selectedContacts;

  ContactPickerDialog(this._context, {this.allContacts, this.selectedContacts});

  @override
  _ContactPickerDialogState createState() => _ContactPickerDialogState();

  Future<List<Contact>> show() {
    return showDialog(
        context: _context, builder: (BuildContext context) => this);
  }
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  Set<Contact> _selectedContacts;
  final TextEditingController nameTextFieldController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();

  @override
  void initState() {
    _selectedContacts = Set.from(widget.selectedContacts);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      context: context,
      title: "Select Contacts",
      iconData: FontAwesomeIcons.userFriends,
      actions: [
        FlatButton(
          child: Text('Select'),
          onPressed: () =>
              Navigator.of(context).pop(_selectedContacts.toList()),
        )
      ],
      content: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: SelectContactsTypeAhead(
                    context: context,
                    autoFocus: true,
                    controller: nameTextFieldController,
                    focusNode: textFieldFocusNode,
                    contacts: widget.allContacts,
                    onSelected: (contact) {
                      setState(() {
                        _selectedContacts.add(contact);
                      });
                      // TODO: Make this work well
//                    nameTextFieldController.clear();
//                    focus(context, textFieldFocusNode);
                    },
                    decoration: InputDecoration(
                        labelText: "Contact Name",
                        counterText:
                            "${_selectedContacts.length}/${widget.allContacts.length}",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.delete_sweep),
                          onPressed: _removeAllSelectedContacts,
                          tooltip: "Remove All",
                        )),
                  ),
                ),
              ],
            ),
            new Flexible(
              child: new ListView(children: getWidgetsToDisplay()),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getWidgetsToDisplay() {
    return _selectedContacts
        .map((Contact contact) => ContactTile(
              contact,
              trailing: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectedContacts.remove(contact);
                  });
                },
              ),
              tapToOpenContactProfile: false,
            ))
        .toList();
  }

  void _removeAllSelectedContacts() {
    _selectedContacts = new Set<Contact>();
  }
}
