import 'package:flutter/material.dart';
import 'package:call_analyzer/models/chart_data.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:charts_common/common.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;

class TimeSeriesChartWrapper extends StatelessWidget {
  final double chartAreaOpacity = 0.18;
  final double verticalGridLineOpacity = 0.25;
  final double horizontalGridLineOpacity = 0.45;

  List<charts.Series<ChartData, DateTime>> _dataSeries;
  final String id;
  final bool includePoints;
  final bool addDistinctiveDashes;
  final Duration animationDuration;

  TimeSeriesChartWrapper(List<List<ChartData>> givenChartData, this.id,
      {this.includePoints = true,
      this.addDistinctiveDashes = true,
      this.animationDuration = defaultChartAnimationDuration}) {
    int index = 0;
    _dataSeries = new List<charts.Series<ChartData, DateTime>>();

    List<TypedAccessorFn<ChartData, List<int>>> dashesPatternFunctions;

    if (addDistinctiveDashes) {
      dashesPatternFunctions =
          _getDashPatternFunctionsList(givenChartData.length);
    } else {
      dashesPatternFunctions = List.filled(givenChartData.length, null);
    }

    // Add every line to the chart
    for (List<ChartData> lineData in givenChartData) {
      final int finalIndex = index;
      _dataSeries.add(charts.Series<ChartData, DateTime>(
        id: id,
        dashPatternFn: dashesPatternFunctions[finalIndex],
        colorFn: (ChartData data, _) => fromNormalColorToChartColor(data.color),
        domainFn: (ChartData data, _) => data.pos,
        measureFn: (ChartData data, _) => data.value,
        data: lineData,
      ));
      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 13,
          child: charts.TimeSeriesChart(
            _dataSeries,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            behaviors: [
              charts.LinePointHighlighter(
                  showHorizontalFollowLine:
                      common.LinePointHighlighterFollowLineType.all,
                  showVerticalFollowLine:
                      common.LinePointHighlighterFollowLineType.all),
              charts.SeriesLegend(),
              charts.PanAndZoomBehavior()
            ],
            defaultRenderer: charts.LineRendererConfig(
                includeArea: true,
                includePoints: includePoints,
                stacked: false,
                areaOpacity: chartAreaOpacity),
            animationDuration: animationDuration,
            animate: true,
            domainAxis: _getDateTimeCustomizedAxisSpeC(
                verticalGridLineOpacity, context),
            primaryMeasureAxis: _getNumericCustomizedAxisSpex(
                horizontalGridLineOpacity, context),
            secondaryMeasureAxis: _getNumericCustomizedAxisSpex(0.0, context),
          ),
        ),
      ],
    );
  }

  charts.DateTimeAxisSpec _getDateTimeCustomizedAxisSpeC(
      double opacity, BuildContext context) {
    return charts.DateTimeAxisSpec(
        renderSpec: new charts.GridlineRendererSpec(
      lineStyle: new charts.LineStyleSpec(
          color: fromNormalColorToChartColor(
              getTextColor(context).withOpacity(opacity))),
      // Tick and Label styling here.
      labelStyle: new charts.TextStyleSpec(
          color: fromNormalColorToChartColor(getTextColor(context))),
    ));
  }

  charts.NumericAxisSpec _getNumericCustomizedAxisSpex(
      double opacity, BuildContext context) {
    return charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
      lineStyle: charts.LineStyleSpec(
          color: fromNormalColorToChartColor(
              getTextColor(context).withOpacity(opacity))),
      // Tick and Label styling here.
      labelStyle: charts.TextStyleSpec(
          color: fromNormalColorToChartColor(getTextColor(context))),
    ));
  }

  List<TypedAccessorFn<ChartData, List<int>>> _getDashPatternFunctionsList(
      int dataLineAmount) {
    List<TypedAccessorFn<ChartData, List<int>>> ans =
        List<TypedAccessorFn<ChartData, List<int>>>();

    List<List<int>> dashesPattern = _getDashPatternsFor(dataLineAmount);

    // For first return no dash function
    ans.add(null);

    // For all other return dash functions
    for (int i = 1; i < dataLineAmount; i++) {
      ans.add((_, __) => dashesPattern[i]);
    }

    return ans;
  }

  List<List<int>> _getDashPatternsFor(int dataLineAmount) {
    List<List<int>> ans = List<List<int>>();
    int dash;
    final int multiplier = 6;

    // Generate dashed list like this - [n, 2n, 3n, 4n...]
    // Show a decreasing pattern density as the list goes(will be reversed later)
    for (int i = 0; i < (dataLineAmount - 1); i++) {
      dash = (i + 1) * multiplier;
      ans.add([dash, dash]);
    }

    // Do not show pattern at all for the first
    ans.add(null);

    return ans.reversed.toList();
  }
}
