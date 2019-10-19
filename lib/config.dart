import 'package:flutter/material.dart';

ThemeData getAppTheme(BuildContext context) {
  return ThemeData(
    fontFamily: 'product',
    primarySwatch: Colors.teal,
    brightness: Brightness.dark,
  );
}

final double normalFontSize = 14.0;

Color getAccentColor(BuildContext context) {
  return getAppTheme(context).accentColor;
}

Color getTextColor(BuildContext context) {
  return Theme.of(context).textTheme.body1.color;
}

final LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.teal[600], Colors.deepPurple[600]]);

const String appTitle = 'Call Analyzer';

const double defaultPadding = 8.0;

const Duration defaultChartAnimationDuration = Duration(milliseconds: 800);

const Duration normalSwitchDuration = Duration(seconds: 1);

const Duration fastSwitchDuration = Duration(milliseconds: 500);
