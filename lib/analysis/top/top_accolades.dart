import 'package:call_analyzer/analysis/contacts/contact_tile.dart';
import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:call_analyzer/models/flare_animation.dart';
import 'package:call_analyzer/widgets/slide.dart';
import 'package:call_analyzer/widgets/slide_show.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TopAccolades extends StatefulWidget {
  @override
  _TopAccoladesState createState() => _TopAccoladesState();
}

class _TopAccoladesState extends State<TopAccolades> {
  final AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  final String _mostCallsInADayAnimationName = 'mostCallsInADay';
  final String _mostCallsWith = 'mostCallsWith';
  final String _longestCall = 'longestCall';
  Map<String, FlareAnimation> _nameToFlare;

  @override
  void initState() {
    _nameToFlare = {
      _mostCallsInADayAnimationName: FlareAnimation(
          fileName: 'assets/animations/phone_call.flr', animationName: 'call'),
      _mostCallsWith: FlareAnimation(
          fileName: 'assets/animations/trophy.flr', animationName: 'trophy'),
      _longestCall: FlareAnimation(
          fileName: 'assets/animations/ticking_clock.flr',
          animationName: 'tick')
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideShow(<Slide>[
      Slide(
        title: 'Most Calls With',
        content: _getSlideContent(
            ContactTile(_analysisService.contacts[146], '560 calls'),
            _nameToFlare[_mostCallsWith]),
      ),
      Slide(
        title: 'Longest Call',
        content: _getSlideContent(
            ContactTile(_analysisService.contacts[146], '3h 24m 15s'),
            _nameToFlare[_longestCall]),
      ),
      Slide(
        title: 'Most Calls In a Day',
        content: _getSlideContent(Text('15 Calls on 12/10/18'),
            _nameToFlare[_mostCallsInADayAnimationName]),
      ),
    ]);
  }

  Widget _getSlideContent(Widget content, FlareAnimation flareAnimation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: _getFlareActorFor(flareAnimation),
        ),
        Expanded(
          flex: 1,
          child: content,
        ),
      ],
    );
  }

  Widget _getFlareActorFor(FlareAnimation flareAnimation) {
    return FlareActor(
      flareAnimation.fileName,
      alignment: Alignment.center,
      fit: BoxFit.fitWidth,
      animation: flareAnimation.animationName,
    );
  }
}
