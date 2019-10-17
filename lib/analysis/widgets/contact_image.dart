import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

class ContactImage extends StatelessWidget {
  final AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  final Contact _contact;
  final double radius;

  ContactImage(this._contact, {this.radius});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _analysisService.getContactWithImage(_contact),
      builder: (BuildContext context, AsyncSnapshot<Contact> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data?.avatar != null
              ? _getContactWithActualImageWidget(snapshot.data)
              : _getContactWithDefaultImage();
        } else {
          return _getContactWithDefaultImage();
        }
      },
    );
  }

  CircleAvatar _getContactWithActualImageWidget(Contact contact) {
    return CircleAvatar(
      backgroundImage: MemoryImage(contact.avatar),
      radius: radius,
    );
  }

  CircleAvatar _getContactWithDefaultImage() {
    return CircleAvatar(
      child: Icon(
        FontAwesomeIcons.user,
        color: Colors.black,
      ),
      backgroundColor: Colors.grey,
      radius: radius,
    );
  }
}
