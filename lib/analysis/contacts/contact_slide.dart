import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactSlide extends StatelessWidget {
  final Contact _contact;
  final int _rank;

  ContactSlide(this._contact, [this._rank]);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_contact.displayName + ' ' + _rank.toString()),
    );
  }
}
