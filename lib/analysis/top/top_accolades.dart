import 'package:call_analyzer/analysis/contacts/contact_tile.dart';
import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_analyzer/models/flare_animation.dart';
import 'package:call_analyzer/models/life_event.dart';
import 'package:call_analyzer/models/sort_option.dart';
import 'package:call_analyzer/widgets/dialogs/future_dialog.dart';
import 'package:call_analyzer/widgets/slide.dart';
import 'package:call_analyzer/widgets/slide_show.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TopAccolades extends StatefulWidget {
  final Stream<LifeEvent> _lifeEvent$;

  const TopAccolades(this._lifeEvent$);

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
  CallLogInfo _longestCallCallLog;
  DateTime _mostCallsInADayDate;
  int _mostCallsInADayAmount;
  bool _fetchedData = false;

  // TODO: When every slide is tapped do something like show the top 10 - same for general tab
  // TODO: Add a slide for longest total call duration with

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
    _setup();
    widget._lifeEvent$.takeWhile((e) => mounted).listen((LifeEvent event) {
      if (event == LifeEvent.RELOAD) {
        _setup();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: fastSwitchDuration,
      child: !_fetchedData
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SlideShow(slides: <Slide>[
              _getMostCallsWithSlide(),
              _getLongestCallWithSlide(),
              _getMostCallsADaySlide(),
            ]),
    );
  }

  _setup() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _fetchedData = false;
    });

    // TODO: Run this in async compute
    _mostCallWith = (await _analysisService.getTopContacts(
            sortOption: SortOption.CALL_AMOUNT, amount: 1))
        .first;
    _longestCallCallLog = _analysisService.getLongestCallLog();
    Map mostCallsInADateData = _analysisService.getMostCallsInADayData();
    _mostCallsInADayDate = mostCallsInADateData['date'];
    _mostCallsInADayAmount = mostCallsInADateData['amount'];

    if (mounted) {
      setState(() {
        _fetchedData = true;
      });
    }
  }

  Slide _getMostCallsWithSlide() {
    return Slide(
      title: 'Most Calls With',
      content: _getSlideContent(
          bottomContent: ContactTile(
            _mostCallWith,
            trailingText:
                '${_analysisService.getCallLogsFor(_mostCallWith).length} Calls',
          ),
          flareAnimation: _nameToFlare[_mostCallsWithId],
          onFlareTapped: () {
            _showTopDialogFor<Contact>(
                context: context,
                title: 'Top 10 Most Calls With',
                future: _analysisService.getTopContacts(
                    sortOption: SortOption.CALL_AMOUNT, amount: 10),
                itemBuilder: (BuildContext context, Contact contact) =>
                    ContactTile(
                      contact,
                      subtitleText:
                          '${_analysisService.getCallLogsFor(contact).length} Calls',
                    ));
          }),
      gradient: appGradient,
    );
  }

  Slide _getLongestCallWithSlide() {
    return Slide(
      title: 'Longest Call',
      content: _getSlideContent(
          bottomContent: _longestCallCallLog.contact != null
              ? ContactTile(
                  _longestCallCallLog.contact,
                  trailingText: stringifyDuration(_longestCallCallLog.duration),
                )
              : ListTile(
                  title: Text(_longestCallCallLog.number ??
                      _longestCallCallLog.formattedNumber ??
                      'private number'),
                  trailing:
                      Text(stringifyDuration(_longestCallCallLog.duration)),
                ),
          flareAnimation: _nameToFlare[_longestCallId]),
      gradient: appGradient,
    );
  }

  Slide _getMostCallsADaySlide() {
    return Slide(
      title: 'Most Calls In a Day',
      content: _getSlideContent(
          bottomContent: Text(
              '$_mostCallsInADayAmount Calls on ${stringifyDateTime(_mostCallsInADayDate)}'),
          flareAnimation: _nameToFlare[_mostCallsInADayId]),
      gradient: appGradient,
    );
  }

  Widget _getSlideContent(
      {@required Widget bottomContent,
      @required FlareAnimation flareAnimation,
      VoidCallback onFlareTapped}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: InkWell(
            child: _getFlareActorFor(flareAnimation),
            onTap: onFlareTapped,
          ),
        ),
        Expanded(
          flex: 1,
          child: bottomContent,
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

  _showTopDialogFor<T>(
      {@required BuildContext context,
      @required String title,
      @required Future<List<T>> future,
      @required Widget Function(BuildContext context, T data) itemBuilder}) {
    FutureDialog(
      context: context,
      title: title,
      futureBuilder: FutureBuilder<List<T>>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
          return FractionallySizedBox(
            heightFactor: 0.6,
            child: snapshot.connectionState == ConnectionState.done
                ? SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (T item in snapshot.data) itemBuilder(context, item)
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        },
      ),
    ).show();
  }
}
