import 'package:call_analyzer/analysis/contacts/contact_tile.dart';
import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/flare_animation.dart';
import 'package:call_analyzer/models/sort_option.dart';
import 'package:call_analyzer/widgets/loader.dart';
import 'package:call_analyzer/widgets/slide.dart';
import 'package:call_analyzer/widgets/slide_show.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TopAccolades extends StatefulWidget {
  @override
  _TopAccoladesState createState() => _TopAccoladesState();
}

class _TopAccoladesState extends State<TopAccolades> {
  final AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  final String _mostCallsInADayId = 'mostCallsInADay';
  final String _mostCallsWithId = 'mostCallsWith';
  final String _longestCallId = 'longestCall';
  Map<String, FlareAnimation> _nameToFlare;
  Contact _mostCallWith;
  CallLogEntry _longestCallCallLog;
  Contact _longestCallContact;
  DateTime _mostCallsInADayDate;
  int _mostCallsInADayAmount;
  bool _fetchedData = false;

  // TODO: When every slide is tapped do something - same for general tab

  @override
  void initState() {
    _nameToFlare = {
      _mostCallsInADayId: FlareAnimation(
          fileName: 'assets/animations/phone_call.flr', animationName: 'call'),
      _mostCallsWithId: FlareAnimation(
          fileName: 'assets/animations/trophy.flr', animationName: 'trophy'),
      _longestCallId: FlareAnimation(
          fileName: 'assets/animations/ticking_clock.flr',
          animationName: 'tick')
    };
    _fetchTopAccolades();
    super.initState();
  }

  _fetchTopAccolades() async {
    setState(() {
      _fetchedData = false;
    });

    // TODO: Run this in async compute
    _mostCallWith = (await _analysisService.getTopContacts(
        sortOption: SortOption.CALL_AMOUNT, amount: 1)).first;
    _longestCallCallLog = _analysisService.getLongestCallLog();
    _longestCallContact =
        _analysisService.getContactFromCallLog(_longestCallCallLog);
    Map mostCallsInADateData = _analysisService.getMostCallsInADayData();
    _mostCallsInADayDate = mostCallsInADateData['date'];
    _mostCallsInADayAmount = mostCallsInADateData['amount'];

    if (mounted) {
      setState(() {
        _fetchedData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_fetchedData
        ? Loader()
        : SlideShow(<Slide>[
            _getMostCallsWithSlide(),
            _getLongestCallWithSlide(),
            getMostCallsADaySlide(),
          ]);
  }

  Slide _getMostCallsWithSlide() {
    return Slide(
      title: 'Most Calls With',
      content: _getSlideContent(
          ContactTile(_mostCallWith,
              '${_analysisService.getCallLogsFor(_mostCallWith).length} Calls'),
          _nameToFlare[_mostCallsWithId]),
    );
  }

  Slide _getLongestCallWithSlide() {
    return Slide(
      title: 'Longest Call',
      content: _getSlideContent(
          _longestCallContact != null
              ? ContactTile(
                  _longestCallContact,
                  stringifyDuration(
                      Duration(seconds: _longestCallCallLog.duration)))
              : ListTile(
                  title: Text(_longestCallCallLog.number ??
                      _longestCallCallLog.formattedNumber ??
                      'private number'),
                  trailing: Text(stringifyDuration(
                      Duration(seconds: _longestCallCallLog.duration))),
                ),
          _nameToFlare[_longestCallId]),
    );
  }

  Slide getMostCallsADaySlide() {
    String date = _mostCallsInADayDate.toString();
    return Slide(
      title: 'Most Calls In a Day',
      content: _getSlideContent(
          Text(
              '$_mostCallsInADayAmount Calls on ${date.substring(0, date.indexOf(' '))}'),
          _nameToFlare[_mostCallsInADayId]),
    );
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
