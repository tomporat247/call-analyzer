import 'package:call_analyzer/models/chart_data.dart';
import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/widgets/pie_chart_wrapper.dart';
import 'package:call_analyzer/widgets/slide_show.dart';
import 'package:call_analyzer/widgets/time_series_chart_wrapper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GeneralDetails extends StatefulWidget {
  @override
  _GeneralDetailsState createState() => _GeneralDetailsState();
}

class _GeneralDetailsState extends State<GeneralDetails> {
  final AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  int _totalCallAmount;
  Duration _totalCallDuration;
  List<ChartData<num>> _totalCallsChartData;
  List<ChartData<num>> _topCallDurationData;
  List<ChartData<DateTime>> _totalCallsWithDate;
  int _selectedYearForCallPerMonth;

  @override
  initState() {
    _setupTotalCallData();
    _setupCallDurationData();
    _setupTotalCallWithDateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideShow(
      <Widget>[
        PieChartWrapper(
            _totalCallsChartData, 'Total Calls - $_totalCallAmount'),
        PieChartWrapper(_topCallDurationData,
            'Total Call Duration  - ${stringifyDuration(_totalCallDuration)}'),
        // TODO: Figure out how to show this without freezing the app
//        _getCallPerMonthTimeSeriesChart(),
      ],
      onPageSwitch: _onPageSwitch,
    );
  }

  _onPageSwitch(int prevIndex, int currIndex) {
    if (prevIndex == 2) {
      setState(() {
        _selectedYearForCallPerMonth = null;
      });
    }
  }

  _setupTotalCallData() {
    _totalCallAmount = _analysisService.getAmountOfTotalCallLogs();
    _totalCallsChartData = <ChartData<num>>[
      ChartData(
          "",
          "Incoming",
          _analysisService.getAllCallLogsOfType(CallType.incoming).length,
          Colors.green),
      ChartData(
          "",
          "Outgoing",
          _analysisService.getAllCallLogsOfType(CallType.outgoing).length,
          Colors.blue),
      ChartData(
          "",
          "Missed",
          _analysisService.getAllCallLogsOfType(CallType.missed).length,
          Colors.grey[800]),
      ChartData(
          "",
          "Rejected",
          _analysisService.getAllCallLogsOfType(CallType.rejected).length,
          Colors.red[700])
    ];
  }

  _setupCallDurationData() async {
    List<Color> colors = [
      Colors.blue[700],
      Colors.green[300],
      Colors.grey,
      Colors.brown[400],
      Colors.yellow,
      Colors.deepOrange,
      Colors.brown[700],
      Colors.green[700],
      Colors.lightBlue,
      Colors.red[700],
    ];
    _totalCallDuration = _analysisService.getTotalCallDuration();
    _topCallDurationData = new List<ChartData<num>>();
    List<Contact> topContacts = await _analysisService.getTopContacts();
    setState(() {
      double sum = 0;
      topContacts.forEach((Contact contact) {
        double contactPercentageOutOfAllCalls =
            _analysisService.getTotalCallDurationFor(contact).inSeconds /
                _totalCallDuration.inSeconds *
                100;
        sum += contactPercentageOutOfAllCalls;
        _topCallDurationData.add(ChartData(
          "",
          contact.displayName,
          double.parse(stringifyNumber(contactPercentageOutOfAllCalls)),
          colors[topContacts.indexOf(contact)],
          suffix: ' %',
          limitCaption: true,
        ));
      });
      _topCallDurationData.add(ChartData(
        "",
        'Other',
        double.parse(stringifyNumber(100 - sum)),
        Colors.black,
        suffix: ' %',
        limitCaption: true,
      ));
    });
  }

  _setupTotalCallWithDateData() {
    _totalCallsWithDate = [];
    DateTime currentDateTime;
    DateTime previousDateTime = DateTime.fromMillisecondsSinceEpoch(
        _analysisService.callLogs.last.timestamp);
    int callsThisMonth = 0;

    _analysisService.callLogs.reversed.forEach((CallLogEntry callLog) {
      currentDateTime = DateTime.fromMillisecondsSinceEpoch(callLog.timestamp);

      if (currentDateTime.month == previousDateTime.month) {
        callsThisMonth++;
      } else {
        _totalCallsWithDate.add(ChartData<DateTime>(
            '', '', callsThisMonth, Colors.white,
            pos: DateTime(currentDateTime.year, currentDateTime.month, 1)));
        callsThisMonth = 1;
      }

      previousDateTime = currentDateTime;
    });
    _totalCallsWithDate.add(ChartData<DateTime>(
        '', '', callsThisMonth, Colors.white,
        pos: DateTime(currentDateTime.year, currentDateTime.month, 1)));
  }

  _getCallPerMonthTimeSeriesChart() {
    int firstYear = DateTime.fromMillisecondsSinceEpoch(
            _analysisService.callLogs.last.timestamp)
        .year;
    int lastYear = DateTime.fromMillisecondsSinceEpoch(
            _analysisService.callLogs.first.timestamp)
        .year;
    List<int> years = new List<int>.generate(
        lastYear - firstYear + 1, (int i) => firstYear + i);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Wrap(
            children: <Widget>[
              for (int year in years)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: ChoiceChip(
                    label: Text(year.toString()),
                    selected: _selectedYearForCallPerMonth == year,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedYearForCallPerMonth = selected ? year : null;
                      });
                    },
                  ),
                )
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: TimeSeriesChartWrapper([
            _selectedYearForCallPerMonth == null
                ? []
                : _totalCallsWithDate
                    .where((ChartData<DateTime> data) =>
                        data.pos.year == _selectedYearForCallPerMonth)
                    .toList()
          ], 'Calls Per Month'),
        )
      ],
    );
  }
}
