import 'package:call_analyzer/analysis/models/chart_data.dart';
import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:call_analyzer/analysis/widgets/pie_chart_wrapper.dart';
import 'package:call_analyzer/analysis/widgets/slide_show.dart';
import 'package:call_analyzer/helper/helper.dart';
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
  List<ChartData> _totalCallsChartData;
  List<ChartData> _topCallDurationData;

  @override
  initState() {
    _setupTotalCallData();
    _setupCallDurationData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideShow(<Widget>[
      _getPieChart(_totalCallsChartData, 'Total Calls - $_totalCallAmount'),
      _getPieChart(_topCallDurationData,
          'Total Call Duration  - ${stringifyDuration(_totalCallDuration)}'),
      Text('CCc'),
    ]);
  }

  Widget _getPieChart(List<ChartData> dataSeries, String id) {
    return Center(
      child: PieChartWrapper(dataSeries, id),
    );
  }

  _setupTotalCallData() {
    _totalCallAmount = _analysisService.getAmountOfTotalCallLogs();
    _totalCallsChartData = <ChartData>[
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
    _topCallDurationData = [];
    List<Contact> topContacts = await _analysisService.getTopContacts();
    setState(() {
      _topCallDurationData = [
        for (Contact contact in topContacts)
          ChartData(
            "",
            contact.displayName,
            double.parse(stringifyNumber(
                _analysisService.getTotalCallDurationFor(contact).inSeconds /
                    _totalCallDuration.inSeconds *
                    100)),
            colors[topContacts.indexOf(contact)],
            suffix: ' %',
            limitCaption: true,
          )
      ];
    });
  }
}
