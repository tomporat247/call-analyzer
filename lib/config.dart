import 'package:flutter/material.dart';

// TODO: Change button color
ThemeData getAppTheme(context) {
  return ThemeData(
    fontFamily: 'product',
    primarySwatch: Colors.blue,
// TODO: Get correct text color(app vs permissions)
//    textTheme: Theme.of(context).textTheme.apply(
//          bodyColor: Colors.white,
//          displayColor: Colors.white,
//        ),
  );
}
final List<Color> backgroundColors = [Color(0xff1a9c91), Color(0xff0c4661)];

const String appTitle = 'Call Analyzer';

const double defaultPadding = 8.0;
