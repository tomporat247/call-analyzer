import 'package:call_analyzer/config.dart';
import 'package:flutter/material.dart';

import 'chart_top_title.dart';

class Slide extends StatelessWidget {
  final String title;
  final Widget content;
  final bool showContent;
  final LinearGradient gradient;

  Slide(
      {@required this.title,
      @required this.content,
      this.gradient,
      this.showContent = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: defaultPadding, left: defaultPadding, right: defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ChartTopTitle(title),
          ),
          Expanded(flex: 13, child: showContent ? content : Container()),
        ],
      ),
    );
  }
}
