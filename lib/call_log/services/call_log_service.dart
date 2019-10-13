import 'dart:convert';

import 'package:call_analyzer/call_log/services/call_log_parser_service.dart';
import 'package:call_analyzer/storage/services/storage_service.dart';
import 'package:call_log/call_log.dart';

class CallLogService {
  final StorageService _storageService;
  final CallLogParserService _parserService;
  List<CallLogEntry> _callLogs;
  final String callLogFileName = 'callLogs.json';

  List<CallLogEntry> get callLogs => _callLogs;

  CallLogService(this._storageService, this._parserService);

  Future<void> init() async {
    if (await _storageService.fileExists(callLogFileName)) {
      _callLogs = await _getCallLogsFromAllSources();
    } else {
      _callLogs = await _getAllDeviceCallLogs();
    }
    _updateCallLogFile();
  }

  Future<List<CallLogEntry>> _getCallLogsFromAllSources() async {
    List<CallLogEntry> callLogs = new List<CallLogEntry>();
    DateTime lastModified =
        await _storageService.getLastModified(callLogFileName);
    List<List<CallLogEntry>> callLogsFromAllSources = await Future.wait(
        [_getCallLogsFromFile(), _getDeviceCallLogsFromDate(lastModified)]);
    callLogsFromAllSources.forEach((calls) => callLogs.addAll(calls));
    return callLogs;
  }

  Future<List<CallLogEntry>> _getAllDeviceCallLogs() async {
    return (await CallLog.get()).toList();
  }

  Future<List<CallLogEntry>> _getDeviceCallLogsFromDate(DateTime from) async {
    return (await CallLog.query(
            dateFrom: from.millisecondsSinceEpoch,
            dateTo: DateTime.now().millisecondsSinceEpoch))
        .toList();
  }

  Future<List<CallLogEntry>> _getCallLogsFromFile() async {
    String data = await _storageService.readFromFile(callLogFileName);
    return (jsonDecode(data) as List)
        .map(_parserService.callLogEntryFromMap)
        .toList();
  }

  Future<void> _updateCallLogFile() async {
    await _storageService.writeToFile(callLogFileName,
        json.encode(_callLogs, toEncodable: _parserService.callLogEntryToMap));
  }
}
