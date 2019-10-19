import 'package:flutter/cupertino.dart';

import '../config.dart';

class ChartTopTitle extends StatelessWidget {
  final String _title;

  ChartTopTitle(this._title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: normalFontSize + 2),
      ),
    );
  }
}
