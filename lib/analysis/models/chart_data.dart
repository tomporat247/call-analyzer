import 'package:flutter/material.dart';

class ChartData<T> {
  static int staticCounter = 0;
  final captionLimit = 20;
  String caption;
  num value;
  T pos;
  Color color;
  String collectionID;
  String suffix;

  // CTor
  ChartData(this.collectionID, this.caption, this.value, this.color,
      {this.suffix = '', T pos, limitCaption = false}) {
    if (pos == null) {
      this.pos = ChartData.staticCounter++ as T;
    } else {
      this.pos = pos;
    }
    if (limitCaption && caption.length > captionLimit) {
      caption = caption.substring(0, captionLimit - 3) + '...';
    }
  }

  ChartData.alter(ChartData other,
      {String newCaption,
      num newValue,
      T newPos,
      Color newColor,
      String newCollectionID}) {
    this.caption = newCaption ?? other.caption;
    this.value = newValue ?? other.value;
    this.pos = newPos ?? other.pos;
    this.color = newColor ?? other.color;
    this.collectionID = newCollectionID ?? other.collectionID;
  }
}
