import 'package:call_analyzer/analysis/widgets/contact_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactProfile extends StatelessWidget {
  final Contact _contact;
  final double _avatarRadius = 60.0;

  ContactProfile(this._contact);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Information'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContactImage(
                      _contact,
                      radius: _avatarRadius,
                    ),
                    Text(_contact.displayName, style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),)
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text('Google Product Sans'),
          )
        ],
      ),
    );
  }
}
