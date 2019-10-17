import 'package:call_analyzer/config.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final String animationFile = 'assets/animations/load-trim.flr';
  final String animationName = 'load-trim';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(4 * defaultPadding),
            child: FlareActor(
              animationFile,
              alignment: Alignment.center,
              fit: BoxFit.cover,
              animation: animationName,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}
