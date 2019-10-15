import 'package:flutter/material.dart';

// TODO: Set button color to green and theme as Bit's
ThemeData getAppTheme(context) {
  return ThemeData(
    primarySwatch: Colors.blue,
    textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
  );
}

const String appTitle = 'Call Analyzer';

const double defaultPadding = 8.0;
