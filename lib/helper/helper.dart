import 'package:flutter/foundation.dart';

typedef extractCompareByFromElement<Element, Comparer> = Comparer Function(
    Element element);

formatPhoneNumber(String phoneNumber) {
  return phoneNumber == null ? null : phoneNumber.replaceAll('-', '');
}

Future<List<Element>> asyncSort<Element, Comparer>(
    List<Element> originalList,
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
