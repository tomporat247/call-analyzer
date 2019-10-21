import 'package:flutter/material.dart';
import 'dart:async';
import 'package:numberpicker/numberpicker.dart';

import 'app_dialog.dart';

class ContactAmountPickerDialog extends StatefulWidget {
  final BuildContext _context;
  final int initialValue;
  final int maximumValue;

  ContactAmountPickerDialog(this._context,
      {this.initialValue, this.maximumValue, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactAmountPickerDialogState();

  Future<int> show() {
    return showDialog(
        context: _context, builder: (BuildContext context) => this);
  }
}

class _ContactAmountPickerDialogState extends State<ContactAmountPickerDialog> {
  num _currentValue;

  @override
  void initState() {
    _currentValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new AppDialog(
        title: "Contact Amount To Display",
        content: NumberPicker.integer(
            initialValue: _currentValue,
            minValue: 1,
            maxValue: widget.maximumValue,
            onChanged: (num newValue) {
              setState(() {
                _currentValue = newValue;
              });
            }),
        actions: [
          FlatButton(
            child: Text('Select'),
            onPressed: () => Navigator.of(context).pop(_currentValue.floor()),
          )
        ]);
  }
}
