import 'package:flutter/material.dart';

class MenuTextOption extends Text {
  final VoidCallback onPressed;
  final dynamic value;

  MenuTextOption({
    @required String text,
    @required this.onPressed,
    this.value
  }) : super(text);
}
