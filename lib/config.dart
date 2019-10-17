import 'package:flutter/material.dart';

ThemeData getAppTheme(context) {
  return ThemeData(
    fontFamily: 'product',
    primarySwatch: Colors.teal,
    brightness: Brightness.dark,
  );
}

final double normalFontSize = 14.0;

Color getAccentColor(context) {
  return getAppTheme(context).accentColor;
}

final LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.teal[600], Colors.deepPurple[600]]);

const String appTitle = 'Call Analyzer';

const double defaultPadding = 8.0;

const Duration defaultChartAnimationDuration = Duration(milliseconds: 800);