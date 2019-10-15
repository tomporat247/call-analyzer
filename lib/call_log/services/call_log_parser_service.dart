import 'package:call_log/call_log.dart';

class CallLogParserService {
  final String _name = 'nm';
  final String _callType = 'c';
  final String _duration = 'd';
  final String _timeStamp = 't';
  final String _number = 'n';
  final String _formattedNumber = 'fn';

  dynamic callLogEntryToMap(dynamic callLogEntry) {
    return {
      _name: callLogEntry.name,
      _callType: callLogEntry.callType.index,
      _duration: callLogEntry.duration,
      _timeStamp: callLogEntry.timestamp,
      _number: callLogEntry.number,
      _formattedNumber: callLogEntry.formattedNumber
    };
  }

  CallLogEntry callLogEntryFromMap(dynamic value) {
    return CallLogEntry(
        name: value[_name],
        callType: CallType.values[value[_callType]],
        duration: value[_duration],
        timestamp: value[_timeStamp],
        number: value[_number],
        formattedNumber: value[_formattedNumber]);
  }
}
