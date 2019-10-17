import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactSlide extends StatelessWidget {
  final Contact _contact;

  ContactSlide(this._contact);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_contact.displayName),);
  }
}
