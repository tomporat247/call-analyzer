import 'dart:convert';

import 'package:call_analyzer/call_log/services/call_log_parser_service.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/storage/services/storage_service.dart';
import 'package:call_log/call_log.dart';

class CallLogService {
  final StorageService _storageService;
  final CallLogParserService _parserService;
  final String callLogFileName = 'callLogs.json';

  CallLogService(this._storageService, this._parserService);

  Future<List<CallLogEntry>> getUpdatedCallLogs() async {
    List<CallLogEntry> callLogs;
    if (await _storageService.fileExists(callLogFileName)) {
      callLogs = await _getCallLogsFromAllSources();
    } else {
      callLogs = await _getAllDeviceCallLogs();
    }
    _formatCallLogs(callLogs);
    await _updateCallLogFile(callLogs);
    return callLogs;
  }

  _formatCallLogs(List<CallLogEntry> callLogs) {
    callLogs.forEach((CallLogEntry callLog) {
      callLog.number = formatPhoneNumber(callLog.number);
      callLog.formattedNumber = formatPhoneNumber(callLog.formattedNumber);
    });
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

  Future<void> _updateCallLogFile(List<CallLogEntry> allCallLogs) async {
    await _storageService.writeToFile(
        callLogFileName,
        json.encode(allCallLogs,
            toEncodable: _parserService.callLogEntryToMap));
  }
}
