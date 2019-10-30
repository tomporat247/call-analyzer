import 'package:bezier_chart/bezier_chart.dart';
import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_analyzer/widgets/call_icon.dart';
import 'package:call_analyzer/widgets/contact_image.dart';
import 'package:call_analyzer/widgets/time_series_chart_wrapper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import '../../config.dart';

class ContactProfile extends StatefulWidget {
  final Contact _contact;

  ContactProfile(this._contact);

  @override
  _ContactProfileState createState() => _ContactProfileState();
}

class _ContactProfileState extends State<ContactProfile> {
  final double _avatarRadius = 50.0;
  final double _cardBorderRadius = 12.0;
  final AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  Contact _contact;
  List<CallLogInfo> _callLogs;
  int _totalCallAmount;
  int _totalIncomingCallAmount;
  int _totalOutgoingCallAmount;
  int _totalMissedCallAmount;
  int _totalRejectedCallAmount;
  Duration _totalCallDuration;
  double _averageCallsPerDay;
  Duration _averageCallDurationInSecondsPerDay;
  List<DataPoint<DateTime>> _incomingCallsPerDay;
  List<DataPoint<DateTime>> _outgoingCallsPerDay;
  List<DataPoint<DateTime>> _missedCallsPerDay;
  List<DataPoint<DateTime>> _rejectedCallsPerDay;

  @override
  void initState() {
    _contact = widget._contact;
    _callLogs = _analysisService.getCallLogsFor(_contact)
      ..sort((CallLogInfo one, CallLogInfo two) =>
          one.dateTime.compareTo(two.dateTime));
    _formatContactPhones();
    _initCounters();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Contact Information'),
          ),
          body: ListView(
            children: <Widget>[
              _getContactProfile(),
              ..._getCards(),
              ..._getGraphs()
            ],
          )),
    );
  }

  _initCounters() {
    int daysSinceFirstCall =
        DateTime.now().difference(_analysisService.getFirstCallDate()).inDays;
    _totalCallAmount = _callLogs.length;
    _averageCallsPerDay = _totalCallAmount / daysSinceFirstCall;
    _totalCallDuration = _analysisService.getTotalCallDurationFor(_contact);
    _averageCallDurationInSecondsPerDay = Duration(
        seconds: (_totalCallDuration.inSeconds / (daysSinceFirstCall)).floor());
    _totalIncomingCallAmount = 0;
    _totalOutgoingCallAmount = 0;
    _totalMissedCallAmount = 0;
    _totalRejectedCallAmount = 0;
    _incomingCallsPerDay = new List<DataPoint<DateTime>>();
    _outgoingCallsPerDay = new List<DataPoint<DateTime>>();
    _missedCallsPerDay = new List<DataPoint<DateTime>>();
    _rejectedCallsPerDay = new List<DataPoint<DateTime>>();
    int incomingToday = 0;
    int outgoingToday = 0;
    int missedToday = 0;
    int rejectedToday = 0;
    DateTime prev = _callLogs.first.dateTime;
    _callLogs.forEach((CallLogInfo callLog) {
      switch (callLog.callType) {
        case CallType.incoming:
        case CallType.answeredExternally:
          _totalIncomingCallAmount++;
          incomingToday++;
          break;
        case CallType.outgoing:
          _totalOutgoingCallAmount++;
          outgoingToday++;
          break;
        case CallType.missed:
          _totalMissedCallAmount++;
          missedToday++;
          break;
        case CallType.rejected:
          _totalRejectedCallAmount++;
          rejectedToday++;
          break;
        default:
          break;
      }

      DateTime curr = callLog.dateTime;
      if (curr.day != prev.day) {
        _incomingCallsPerDay.add(
            DataPoint<DateTime>(value: incomingToday.toDouble(), xAxis: prev));
        _outgoingCallsPerDay.add(
            DataPoint<DateTime>(value: outgoingToday.toDouble(), xAxis: prev));
        _missedCallsPerDay.add(
            DataPoint<DateTime>(value: missedToday.toDouble(), xAxis: prev));
        _rejectedCallsPerDay.add(
            DataPoint<DateTime>(value: rejectedToday.toDouble(), xAxis: prev));
        incomingToday = 0;
        outgoingToday = 0;
        missedToday = 0;
        rejectedToday = 0;
      }
      prev = curr;
    });
    _incomingCallsPerDay
        .add(DataPoint<DateTime>(value: incomingToday.toDouble(), xAxis: prev));
    _outgoingCallsPerDay
        .add(DataPoint<DateTime>(value: outgoingToday.toDouble(), xAxis: prev));
    _missedCallsPerDay
        .add(DataPoint<DateTime>(value: missedToday.toDouble(), xAxis: prev));
    _rejectedCallsPerDay
        .add(DataPoint<DateTime>(value: rejectedToday.toDouble(), xAxis: prev));
  }

  Widget _getContactProfile() {
    final EdgeInsetsGeometry pad = EdgeInsets.only(bottom: defaultPadding);
    List<Widget> contactProfilePieces = [
      ContactImage(
        contact: _contact,
        radius: _avatarRadius,
      ),
      Text(
        _contact.displayName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: normalFontSize + 2,
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (Item phoneItem in _contact.phones)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text('${phoneItem.label[0].toUpperCase()}'
                    '${phoneItem.label.substring(1).toLowerCase()}: '
                    '${_contact.phones.toList()[0].value}'),
              )
          ],
        ),
      )
    ];

    return Padding(
      padding: EdgeInsets.only(top: 2 * defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (Widget widget in contactProfilePieces)
            Padding(
              padding: pad,
              child: widget,
            )
        ],
      ),
    );
  }

  _formatContactPhones() {
    List<Item> phones = new List<Item>();
    _contact.phones.forEach((Item phone) {
      if (phones
          .where((Item p) =>
              formatPhoneNumber(p.value) == formatPhoneNumber(phone.value))
          .isEmpty) {
        phones.add(phone);
      }
    });

    _contact.phones = phones;
  }

  // TODO: Add call duration graph as well
  List<Widget> _getGraphs() {
    List<List<Widget>> graphsData = [
      [
        Column(
          children: <Widget>[
            _getGraphTitle('Calls per Day'),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TimeSeriesChartWrapper(
                  dataPointLines: [
                    _incomingCallsPerDay,
                    _outgoingCallsPerDay,
                    _missedCallsPerDay,
                    _rejectedCallsPerDay
                  ],
                  colors: [Colors.green, Colors.blue, Colors.red, Colors.black],
                  labels: ['Incoming', 'Outgoing', 'Missed', 'Rejected'],
                ))
          ],
        )
      ]
    ];
    return [
      for (List<Widget> graphData in graphsData)
        _wrapInCard(graphData, gradient: appGradient)
    ];
  }

  Widget _getGraphTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: defaultPadding),
      child: Text(
        'Calls per Day',
        style: TextStyle(fontSize: normalFontSize + 4),
      ),
    );
  }

  List<Widget> _getCards() {
    List<List<Widget>> cardDataList = [
      _getCallDurationData(),
      _getAveragesData(),
      _getCallsCardData(),
    ];

    return [for (List<Widget> cardData in cardDataList) _wrapInCard(cardData)];
  }

  Widget _wrapInCard(List<Widget> data, {Gradient gradient}) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: defaultPadding),
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_cardBorderRadius),
                gradient: gradient ?? appGradient),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_cardBorderRadius)),
              color: Colors.transparent,
//              elevation: 0.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: data,
              ),
            ),
          ),
        ));
  }

  List<Widget> _getCallsCardData() {
    return [
      ListTile(
        title: Text('Total Calls'),
        leading: Icon(FontAwesomeIcons.phone),
        subtitle: Text(_totalCallAmount.toString()),
      ),
      ListTile(
        title: Text('Incoming Calls'),
        leading: CallIcon(callType: CallType.incoming),
        trailing: Text(_getPercentageFromTotalCalls(_totalIncomingCallAmount)),
        subtitle: Text(_totalIncomingCallAmount.toString()),
      ),
      ListTile(
        title: Text('Outgoing Calls'),
        leading: CallIcon(callType: CallType.outgoing),
        trailing: Text(_getPercentageFromTotalCalls(_totalOutgoingCallAmount)),
        subtitle: Text(_totalOutgoingCallAmount.toString()),
      ),
      ListTile(
        title: Text('Missed Calls'),
        leading: CallIcon(callType: CallType.missed),
        trailing: Text(_getPercentageFromTotalCalls(_totalMissedCallAmount)),
        subtitle: Text(_totalMissedCallAmount.toString()),
      ),
      ListTile(
        title: Text('Rejected Calls'),
        leading: CallIcon(callType: CallType.rejected),
        trailing: Text(_getPercentageFromTotalCalls(_totalRejectedCallAmount)),
        subtitle: Text(_totalRejectedCallAmount.toString()),
      ),
    ];
  }

  String _getPercentageFromTotalCalls(int value) {
    return '${stringifyNumber(value / _totalCallAmount * 100)}%';
  }

  List<Widget> _getCallDurationData() {
    return [
      ListTile(
        title: Text('Total Call Duration'),
        leading: Icon(FontAwesomeIcons.phoneVolume),
        subtitle: Text('${stringifyDuration(_totalCallDuration)}\n'
            'In Hours: ${getNumberWithCommas(_totalCallDuration.inHours)}h\n'
            'In Minutes: ${getNumberWithCommas(_totalCallDuration.inMinutes)}m\n'
            'In Seconds: ${getNumberWithCommas(_totalCallDuration.inSeconds)}s\n'),
      ),
    ];
  }

  List<Widget> _getAveragesData() {
    return [
      ListTile(
        title: Text('Average Per Day'),
        leading: Icon(FontAwesomeIcons.chartLine),
        subtitle: Text('Calls: ${stringifyNumber(_averageCallsPerDay)}\n'
            'Talk Time: ${stringifyDuration(_averageCallDurationInSecondsPerDay)}\n'),
      ),
      ListTile(
        title: Text('Average Per Week'),
        leading: Icon(FontAwesomeIcons.chartLine),
        subtitle: Text('Calls: ${stringifyNumber(_averageCallsPerDay * 7)}\n'
            'Talk Time: ${stringifyDuration(_averageCallDurationInSecondsPerDay * 7)}\n'),
      ),
      ListTile(
        title: Text('Average Per Year'),
        leading: Icon(FontAwesomeIcons.chartLine),
        subtitle: Text('Calls: ${stringifyNumber(_averageCallsPerDay * 365)}\n'
            'Talk Time: ${stringifyDuration(_averageCallDurationInSecondsPerDay * 365)}\n'),
      ),
    ];
  }
}
