import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

typedef extractCompareByFromElement<Element, Comparer> = Comparer Function(
    Element element);

formatPhoneNumber(String phoneNumber) {
  return phoneNumber == null ? null : phoneNumber.replaceAll('-', '');
}

getNumberWithCommas(num number) {
  return number.toString().replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

String stringifyNumber(num number, [numbersAfterDecimalPoint = 4]) {
  String numberString = number.toString();
  return numberString.substring(
      0,
      !numberString.contains('.')
          ? null
          : min(numberString.length,
              numberString.indexOf('.') + numbersAfterDecimalPoint + 1));
}

String stringifyDuration(Duration duration) {
  String durationString = duration.toString();
  durationString = durationString.substring(0, durationString.indexOf('.'));
  List<String> parts = durationString.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(parts[2]);
  return '${hours}h ${minutes}m ${seconds}s';
}

charts.Color fromNormalColorToChartColor(Color color) {
  return new charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

Color fromChartColorToNormalColor(charts.Color color) {
  return new Color.fromARGB(color.a, color.r, color.g, color.b);
}

Future<List<Element>> asyncSort<Element, Comparer>(List<Element> originalList,
    extractCompareByFromElement<Element, Comparer> compareBy) async {
  return (await compute(
          _getSortedIndexes, originalList.map<Comparer>(compareBy).toList()))
      .map((dynamic index) => originalList[index])
      .toList();
}

List<int> _getSortedIndexes<T>(List<T> list) {
  String valueKey = 'val';
  String indexKey = 'idx';
  int indexCounter = 0;

  List<dynamic> sortedListWithIndexes = list
      .map((T item) => {valueKey: item, indexKey: indexCounter++})
      .toList()
        ..sort((dynamic one, dynamic two) =>
            two[valueKey].compareTo(one[valueKey]));

  return sortedListWithIndexes
      .map((dynamic item) => item[indexKey])
      .cast<int>()
      .toList();
}
