import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class Loader extends StatelessWidget {
  final String animationFile = 'assets/animations/load-trim.flr';
  final String animationName = 'load-trim';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4 * defaultPadding),
      child: FlareActor(
        animationFile,
        alignment: Alignment.center,
        fit: BoxFit.cover,
        animation: animationName,
      ),
    );
  }
}
