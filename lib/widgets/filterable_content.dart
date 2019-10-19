import 'package:flutter/material.dart';

class FilterableContent extends StatelessWidget {
  final Widget filterRow;
  final Widget content;

  FilterableContent({@required this.filterRow, @required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[filterRow, Divider()],
          ),
        ),
        Expanded(
          flex: 7,
          child: content,
        )
      ],
    );
  }
}
