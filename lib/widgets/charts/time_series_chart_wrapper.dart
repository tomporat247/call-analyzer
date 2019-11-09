import 'package:bezier_chart/bezier_chart.dart';
import 'package:call_analyzer/config.dart';
import 'package:flutter/material.dart';

class TimeSeriesChartWrapper extends StatelessWidget {
  final List<List<DataPoint<DateTime>>> dataPointLines;
  final List<Color> colors;
  final List<String> labels;
  final bool allowPinchAndZoom;
  DateTime _fromDate;
  DateTime _toDate;

  TimeSeriesChartWrapper(
      {@required this.dataPointLines,
      @required this.colors,
      @required this.labels,
      this.allowPinchAndZoom = true}) {
    dataPointLines
        .removeWhere((List<DataPoint<DateTime>> line) => line.isEmpty);

    if (dataPointLines.isNotEmpty) {
      _fromDate = dataPointLines
          .map((List<DataPoint<DateTime>> line) => line.first.xAxis)
          .reduce(
              (DateTime one, DateTime two) => one.isBefore(two) ? one : two);
      _toDate = dataPointLines
          .map((List<DataPoint<DateTime>> line) => line.last.xAxis)
          .reduce((DateTime one, DateTime two) => one.isAfter(two) ? one : two);
    } else {
      _fromDate = DateTime.now();
      _toDate = _fromDate;
    }

    if (_fromDate == _toDate) {
      _toDate = _toDate.add(Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'long press and drag points for information',
          style: TextStyle(fontSize: normalFontSize - 2, color: Colors.white70),
        ),
        Flexible(
          child: BezierChart(
            bezierChartScale: BezierChartScale.MONTHLY,
            fromDate: _fromDate,
            toDate: _toDate,
            series: dataPointLines.isEmpty
                ? [_getDefaultEmptyLine()]
                : [
                    for (int i = 0; i < dataPointLines.length; i++)
                      BezierLine(
                          data: dataPointLines[i],
                          lineColor: colors[i],
                          label: labels[i]),
                  ],
            config: BezierChartConfig(
              displayYAxis: true,
              pinchZoom: allowPinchAndZoom,
              verticalIndicatorStrokeWidth: 3.0,
              verticalIndicatorColor: Colors.black26,
              showVerticalIndicator: true,
              verticalIndicatorFixedPosition: false,
            ),
          ),
        ),
      ],
    );
  }

  BezierLine _getDefaultEmptyLine() {
    return BezierLine(data: []);
  }
}
