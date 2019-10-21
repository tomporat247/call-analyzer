import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';

class CallLogInfo {
  final Contact contact;
  final String name;
  String number;
  String formattedNumber;
  final CallType callType;
  final Duration duration;
  final DateTime dateTime;

  CallLogInfo({
    this.contact,
    this.name,
    this.formattedNumber,
    this.number,
    this.callType,
    this.duration,
    this.dateTime,
  }) {
    if (number == null && formattedNumber == null) {
      number = 'Unkown';
      formattedNumber = 'Unkown';
    }
  }
}
