import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactProfile extends StatelessWidget {
  final Contact _contact;

  ContactProfile(this._contact);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Information'),
      ),
      body: Center(child: Text(_contact.displayName),),
    );
  }
}
