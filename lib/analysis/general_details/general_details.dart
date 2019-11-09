import 'package:bezier_chart/bezier_chart.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_analyzer/models/chart_data.dart';
import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/life_event.dart';
import 'package:call_analyzer/widgets/charts/pie_chart_wrapper.dart';
import 'package:call_analyzer/widgets/slide.dart';
import 'package:call_analyzer/widgets/slide_show.dart';
import 'package:call_analyzer/widgets/charts/time_series_chart_wrapper.dart';
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
  final int topContactAmount = 10;
  int _totalCallAmount;
  Duration _totalCallDuration;
  List<ChartData<num>> _totalCallsChartData;
  List<ChartData<num>> _topCallDurationData;
  List<DataPoint<DateTime>> _callsPerMonthWithDate;

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
      slides: <Slide>[
        Slide(
          title: 'Total Calls - $_totalCallAmount',
          content: PieChartWrapper(_totalCallsChartData, _totalCallsId),
          gradient: appGradient,
        ),
        Slide(
          title:
              'Total Call Duration  - ${stringifyDuration(_totalCallDuration)}',
          content: PieChartWrapper(_topCallDurationData, _totalCallDurationId),
          gradient: appGradient,
        ),
        Slide(
          title: 'All Calls',
          content: _geCallsPerMonthTimeSeriesChart(),
          gradient: appGradient,
        ),
      ],
      animate: true,
    );
  }

  _setup() {
    _setupTotalCallData();
    _setupCallDurationData();
    _setupTotalCallWithDateData();
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
          Colors.red),
      ChartData(
          "",
          "Rejected",
          _analysisService.getAllCallLogsOfType(CallType.rejected).length,
          Colors.black)
    ];
  }

  _setupCallDurationData() async {
    List<Color> colors = [
      Colors.blue,
      Colors.teal[700],
      Colors.lightBlue[100],
      Colors.green[300],
      Colors.cyan[600],
      Colors.deepPurple,
      Colors.purple,
      Colors.indigo,
      Colors.blueGrey,
      Colors.green
      ];
    Color otherColor = Colors.grey[900];
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
          otherColor,
          suffix: ' %',
          limitCaption: true,
        ));
      });
    }
  }

  _setupTotalCallWithDateData() {
    _callsPerMonthWithDate = [];
    DateTime currentDateTime;
    DateTime previousDateTime = _analysisService.callLogs.last.dateTime;
    int callsThisMonth = 0;

    _analysisService.callLogs.reversed.forEach((CallLogInfo callLog) {
      currentDateTime = callLog.dateTime;

      if (currentDateTime.month == previousDateTime.month) {
        callsThisMonth++;
      } else {
        _callsPerMonthWithDate.add(DataPoint<DateTime>(
            value: callsThisMonth.toDouble(), xAxis: previousDateTime));
        callsThisMonth = 1;
      }

      previousDateTime = currentDateTime;
    });
    _callsPerMonthWithDate.add(DataPoint<DateTime>(
        value: callsThisMonth.toDouble(), xAxis: currentDateTime));
  }

  Widget _geCallsPerMonthTimeSeriesChart() {
    return TimeSeriesChartWrapper(
        allowPinchAndZoom: false,
        dataPointLines: [this._callsPerMonthWithDate],
        colors: [lineChartLineColor],
        labels: ['Calls']);
  }
}
