import 'package:flutter/material.dart';

import 'chart_top_title.dart';

class Slide extends StatelessWidget {
  final String title;
  final Widget content;
  final bool showContent;

  Slide({this.title, this.content, this.showContent = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: ChartTopTitle(title),
        ),
        Expanded(flex: 13, child: showContent ? content : Container()),
      ],
    );
  }
}
