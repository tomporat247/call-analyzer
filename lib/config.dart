import 'package:flutter/material.dart';

final Color accentColor = Colors.tealAccent[700];

ThemeData getAppTheme(BuildContext context) {
  return ThemeData(
    fontFamily: 'product',
    primarySwatch: Colors.teal,
    accentColor: accentColor,
    brightness: Brightness.dark,
  );
}

final double normalFontSize = 14.0;

Color getTextColor(BuildContext context) {
  return Theme.of(context).textTheme.body1.color;
}

final LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.teal[600], Colors.deepPurple[600]]);

final LinearGradient darkGradient = LinearGradient(
    colors: [Colors.grey[850], Colors.grey[800]],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight);

final Color lineChartLineColor = Colors.grey[300];

const String appTitle = 'Call Analyzer';

const double defaultPadding = 8.0;

const Duration defaultChartAnimationDuration = Duration(milliseconds: 800);

const Duration normalSwitchDuration = Duration(seconds: 1);

const Duration fastSwitchDuration = Duration(milliseconds: 500);
