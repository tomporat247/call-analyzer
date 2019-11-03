import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

String formatPhoneNumber(String phoneNumber) {
  return phoneNumber == null
      ? null
      : phoneNumber.replaceAll('-', '').replaceAll(' ', '');
}

String getNumberWithCommas(num number) {
  return number.toString().replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

String stringifyNumber(num number, [numbersAfterDecimalPoint = 2]) {
  String numberString = (number.isNaN ? 0 : number).toString();
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

String stringifyDateTime(DateTime dateTime, {bool withTime = false}) {
  DateFormat formatter = DateFormat('MMM dd yyyy ${withTime ? 'HH:mm' : ''}');
  return formatter.format(dateTime);
}

charts.Color fromNormalColorToChartColor(Color color) {
  return new charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

Color fromChartColorToNormalColor(charts.Color color) {
  return new Color.fromARGB(color.a, color.r, color.g, color.b);
}

bool contactHasPhoneNumber(Contact contact, String phoneNumber) {
  return contact.phones
      .map((phone) => formatPhoneNumber(phone.value))
      .contains(formatPhoneNumber(phoneNumber));
}

void unfocus(BuildContext context) {
  FocusScope.of(context).requestFocus(new FocusNode());
}

void focus(BuildContext context, FocusNode node) {
  unfocus(context);
  FocusScope.of(context).requestFocus(node);
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
