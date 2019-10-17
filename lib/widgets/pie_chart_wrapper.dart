import 'package:call_analyzer/models/chart_data.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../widgets/chart_top_title.dart';

class PieChartWrapper extends StatelessWidget {
  // Data Members
  final List<ChartData> _givenChartData;
  List<charts.Series<ChartData, int>> _dataSeries;
  final String _id;
  final Duration animationDuration;
  final bool withLabels;

  PieChartWrapper(this._givenChartData, this._id,
      {this.animationDuration = defaultChartAnimationDuration,
      this.withLabels = false}) {
    _dataSeries = <charts.Series<ChartData, int>>[
      new charts.Series<ChartData, int>(
        id: _id,
        domainFn: (ChartData data, _) => data.pos,
        measureFn: (ChartData data, _) => data.value,
        colorFn: (ChartData data, _) => fromNormalColorToChartColor(data.color),
        data: _givenChartData,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (ChartData row, _) => '${row.caption}: ${row.value}',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThereAnyData()) {
      return Text("Not Enough Data For $_id");
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ChartTopTitle(_id),
          ),
          Expanded(
              flex: 10,
              child: new charts.PieChart(_dataSeries,
                  animationDuration: animationDuration,
                  animate: true,
                  defaultRenderer: _getDefaultRenderer(context))),
          Expanded(
              flex: 3,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: SingleChildScrollView(
                      child: Wrap(
                    direction: Axis.vertical,
                    children: _getLegend(_dataSeries[0].data),
                  ))))
        ],
      );
    }
  }

  List<Widget> _getLegend(List<ChartData> chartData) {
    return [
      for (ChartData data in chartData)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 12.0,
              height: 12.0,
              child: Container(
                color: data.color,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2 * defaultPadding),
              child: Text('${data.caption}: ${data.value}${data.suffix}'),
            )
          ],
        )
    ];
  }

  charts.ArcRendererConfig _getDefaultRenderer(BuildContext context) {
    Color textColor = Theme.of(context).textTheme.body1.color;
    return charts.ArcRendererConfig(
        strokeWidthPx: 0.0,
        arcWidth: 40,
        arcRendererDecorators: withLabels
            ? [
                charts.ArcLabelDecorator(
                    labelPosition: charts.ArcLabelPosition.auto,
                    insideLabelStyleSpec: charts.TextStyleSpec(
                        color: fromNormalColorToChartColor(textColor),
                        fontSize: (normalFontSize - 2).floor()),
                    outsideLabelStyleSpec: charts.TextStyleSpec(
                        color: fromNormalColorToChartColor(textColor),
                        fontSize: (normalFontSize - 2).floor()))
              ]
            : null);
  }

  bool _isThereAnyData() {
    for (ChartData data in _givenChartData) {
      if (data.value != 0) {
        return true;
      }
    }
    return false;
  }
}
