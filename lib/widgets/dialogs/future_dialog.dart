import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'app_dialog.dart';

class FutureDialog extends StatefulWidget {
  final BuildContext context;
  final FutureBuilder futureBuilder;
  final String title;

  FutureDialog(
      {this.context, @required this.futureBuilder, @required this.title});

  @override
  FutureDialogState createState() => FutureDialogState();

  Future<Contact> show() {
    return showDialog(
        context: context, builder: (BuildContext context) => this);
  }
}

class FutureDialogState extends State<FutureDialog> {
  @override
  Widget build(BuildContext context) {
    return AppDialog(
      context: context,
      title: widget.title,
      actions: [
        FlatButton(
            child: Text('CLOSE'), onPressed: () => Navigator.of(context).pop())
      ],
      content: widget.futureBuilder,
    );
  }
}
