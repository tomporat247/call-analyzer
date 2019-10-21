import 'package:flutter/material.dart';

class AppDialog extends AlertDialog {
  AppDialog({
    @required String title,
    IconData iconData,
    @required Widget content,
    @required List<MaterialButton> actions,
    BuildContext context,
  }) : super(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))),
    title: Text(title),
    content: content,
    actions: actions,
  );
}
