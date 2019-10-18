import 'package:call_analyzer/models/flare_animation.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class Loader extends StatelessWidget {
  final FlareAnimation _flareAnimation = FlareAnimation(
      fileName: 'assets/animations/load-trim.flr', animationName: 'load-trim');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4 * defaultPadding),
      child: FlareActor(
        _flareAnimation.fileName,
        alignment: Alignment.center,
        fit: BoxFit.cover,
        animation: _flareAnimation.animationName,
      ),
    );
  }
}
