import 'package:flutter/material.dart';

// TODO: Change button color
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
