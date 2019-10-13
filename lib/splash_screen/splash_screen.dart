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
            padding: EdgeInsets.all(defaultPadding * 2),
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
          child: Center(
            child: Text(
              'Loading call logs and contacts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
