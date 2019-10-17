import 'package:flutter/material.dart';

class ChartData {
  static int staticCounter = 0;
  final captionLimit = 20;
  String caption;
  num value;
  int counter;
  Color color;
  String collectionID;
  String suffix;

  // CTor
  ChartData(this.collectionID, this.caption, this.value, this.color,
      {this.suffix = '', int counter, limitCaption = false}) {
    if (counter == null) {
      this.counter = ChartData.staticCounter++;
    } else {
      this.counter = counter;
    }
    if (limitCaption && caption.length > captionLimit) {
      caption = caption.substring(0, captionLimit - 3) + '...';
    }
  }

  ChartData.alter(ChartData other,
      {String newCaption,
      num newValue,
      int newCounter,
      Color newColor,
      String newCollectionID}) {
    this.caption = newCaption ?? other.caption;
    this.value = newValue ?? other.value;
    this.counter = newCounter ?? other.counter;
    this.color = newColor ?? other.color;
    this.collectionID = newCollectionID ?? other.collectionID;
  }
}
