import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

class ContactImage extends StatelessWidget {
  final AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  final Contact contact;
  final double radius;
  final double iconSize;

  ContactImage({@required this.contact, this.radius, this.iconSize});

  @override
  Widget build(BuildContext context) {
    // TODO: Don't do this in a future builder it is just slower and display flickers
    return FutureBuilder(
      future: _analysisService.getContactWithImage(contact),
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
        FontAwesomeIcons.userAlt,
        color: Colors.black,
        size: iconSize,
      ),
      backgroundColor: Colors.grey,
      radius: radius,
    );
  }
}
