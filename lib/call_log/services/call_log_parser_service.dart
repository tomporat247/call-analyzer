import 'package:call_log/call_log.dart';

class CallLogParserService {
  final String _name = 'n';
  final String _callType = 'c';
  final String _duration = 'd';
  final String _timeStamp = 't';

  dynamic callLogEntryToMap(dynamic callLogEntry) {
    return {
      _name: callLogEntry.name,
      _callType: callLogEntry.callType.index,
      _duration: callLogEntry.duration,
      _timeStamp: callLogEntry.timestamp
    };
  }

  CallLogEntry callLogEntryFromMap(dynamic value) {
    return CallLogEntry(
        name: value[_name],
        callType: CallType.values[value[_callType]],
        duration: value[_duration],
        timestamp: value[_timeStamp]);
  }
}
