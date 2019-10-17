import 'package:flutter/material.dart';

ThemeData getAppTheme(context) {
  return ThemeData(
    fontFamily: 'product',
    primarySwatch: Colors.teal,
    brightness: Brightness.dark,
  );
}

final List<Color> backgroundColors = [Color(0xff1a9c91), Color(0xff0c4661)];

const String appTitle = 'Call Analyzer';

const double defaultPadding = 8.0;
