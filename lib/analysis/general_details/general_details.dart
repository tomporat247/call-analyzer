import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_analyzer/models/chart_data.dart';
import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/life_event.dart';
import 'package:call_analyzer/widgets/pie_chart_wrapper.dart';
import 'package:call_analyzer/widgets/slide.dart';
import 'package:call_analyzer/widgets/slide_show.dart';
import 'package:call_analyzer/widgets/time_series_chart_wrapper.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GeneralDetails extends StatefulWidget {
  final Stream<LifeEvent> _lifeEvent$;

  GeneralDetails(this._lifeEvent$);

  @override
  _GeneralDetailsState createState() => _GeneralDetailsState();
}

class _GeneralDetailsState extends State<GeneralDetails> {
  final AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  final String _totalCallsId = 'totalCalls';
  final String _totalCallDurationId = 'totalCallDuration';
  final String _callPerMonthId = 'callPerMonth';
  final int topContactAmount = 10;
  int _totalCallAmount;
  Duration _totalCallDuration;
  List<ChartData<num>> _totalCallsChartData;
  List<ChartData<num>> _topCallDurationData;
  List<ChartData<DateTime>> _totalCallsWithDate;
  int _selectedYearForCallPerMonth;

  @override
  initState() {
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
    return SlideShow(
      <Slide>[
        Slide(
          title: 'Total Calls - $_totalCallAmount',
          content: PieChartWrapper(_totalCallsChartData, _totalCallsId),
        ),
        Slide(
          title:
              'Total Call Duration  - ${stringifyDuration(_totalCallDuration)}',
          content: PieChartWrapper(_topCallDurationData, _totalCallDurationId),
        ),
        // TODO: Figure out how to show this without freezing the app
//        Slide(
//          title: 'Calls Per Month',
//          content: _getCallPerMonthTimeSeriesChart(),
//        ),
      ],
      onPageSwitch: _onPageSwitch,
    );
  }

  _setup() {
    _setupTotalCallData();
    _setupCallDurationData();
    _setupTotalCallWithDateData();
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
    List<Contact> topContacts =
        await _analysisService.getTopContacts(amount: topContactAmount);
    if (mounted) {
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
  }

  _setupTotalCallWithDateData() {
    _totalCallsWithDate = [];
    DateTime currentDateTime;
    DateTime previousDateTime = _analysisService.callLogs.last.dateTime;
    int callsThisMonth = 0;

    _analysisService.callLogs.reversed.forEach((CallLogInfo callLog) {
      currentDateTime = callLog.dateTime;

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

  Widget _getCallPerMonthTimeSeriesChart() {
    int firstYear = _analysisService.callLogs.last.dateTime.year;
    int lastYear = _analysisService.callLogs.first.dateTime.year;
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
          ], _callPerMonthId),
        )
      ],
    );
  }
}
