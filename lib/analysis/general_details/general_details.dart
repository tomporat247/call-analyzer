import 'package:call_analyzer/analysis/widgets/slide_show.dart';
import 'package:flutter/material.dart';

class GeneralDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SlideShow(<Widget>[
      Container(color: Colors.teal),
      Container(color: Colors.green),
      Container(color: Colors.blue),
    ]);
  }
}
