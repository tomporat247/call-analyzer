import 'dart:math';

import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/cupertino.dart';

enum BatchBy { DAY, MONTH }

List<List<DataPoint<DateTime>>> _batchLineDataBy(
    {@required List<List<DataPoint<DateTime>>> lines,
    @required BatchBy batchBy}) {
  if (batchBy == BatchBy.DAY || batchBy == null) {
    return lines;
  } else {
    List<List<DataPoint<DateTime>>> batched =
        new List<List<DataPoint<DateTime>>>();
    lines.forEach((List<DataPoint<DateTime>> line) {
      double currBatchTotal = 0;
      DateTime dateTime = line[0].xAxis;
      List<DataPoint<DateTime>> currBatchPoints =
          new List<DataPoint<DateTime>>();
      line.forEach((DataPoint<DateTime> point) {
        if (dateTime.month == point.xAxis.month) {
          currBatchTotal += point.value;
        } else {
          currBatchPoints
              .add(DataPoint<DateTime>(value: currBatchTotal, xAxis: dateTime));
          currBatchTotal = 0;
        }
        dateTime = point.xAxis;
      });
      if (currBatchTotal != 0) {
        currBatchPoints
            .add(DataPoint<DateTime>(value: currBatchTotal, xAxis: dateTime));
      }
      batched.add(currBatchPoints);
    });
    return batched;
  }
}

double getMaxValueFromChartLines(
    {@required List<List<DataPoint<DateTime>>> lines,
    @required BatchBy batchBy}) {
  return _batchLineDataBy(lines: lines, batchBy: batchBy).fold<double>(
      0,
      (double previous, List<DataPoint<DateTime>> line) => line.fold(previous,
          (double prev, DataPoint<DateTime> point) => max(prev, point.value)));
}
