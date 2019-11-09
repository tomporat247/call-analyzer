import 'dart:convert';

import 'package:call_analyzer/services/call_log/call_log_parser_service.dart';
import 'package:call_analyzer/services/permission_service.dart';
import 'package:call_analyzer/services/storage_service.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';

class CallLogService {
  final StorageService _storageService;
  final CallLogParserService _parserService;
  final PermissionService _permissionService;
  final String callLogFileName = 'callLogs.json';
  final Duration _deviceCallLogRequestDelta = Duration(days: 1);

  CallLogService(
      this._storageService, this._parserService, this._permissionService);

  Future<List<CallLogEntry>> getUpdatedCallLogs() async {
    List<CallLogEntry> callLogs;
    bool storagePermissionGranted =
        await _permissionService.hasPermission(PermissionGroup.storage);
    bool fileExists = storagePermissionGranted &&
        await _storageService.fileExists(callLogFileName);

    if (storagePermissionGranted && fileExists) {
      callLogs = await _getCallLogsFromAllSources();
    } else {
      callLogs = await _getAllDeviceCallLogs();
    }
    if (storagePermissionGranted) {
      await _updateCallLogFile(callLogs);
    }
    return callLogs;
  }

  Future<List<CallLogEntry>> _getCallLogsFromAllSources() async {
    DateTime lastModified =
        await _storageService.getLastModified(callLogFileName);

    List<List<CallLogEntry>> callLogsFromAllSources = await Future.wait([
      _getDeviceCallLogsFromDate(
          lastModified.subtract(_deviceCallLogRequestDelta)),
      _getCallLogsFromFile()
    ]);

    return _mergeDeviceAndStorageCallLogs(
        callLogsFromAllSources[0], callLogsFromAllSources[1]);
  }

  List<CallLogEntry> _mergeDeviceAndStorageCallLogs(
      List<CallLogEntry> deviceCallLogs, List<CallLogEntry> storageCallLogs) {
    List<CallLogEntry> mergedCallLogs = new List<CallLogEntry>();

    int oldestDeviceCallLogTimestamp = deviceCallLogs.last.timestamp;
    int oldestDeviceCallLogIndexInStorageCallLogs = storageCallLogs.indexWhere(
        (CallLogEntry callLog) =>
            callLog.timestamp == oldestDeviceCallLogTimestamp);

    for (int i = 0; i <= oldestDeviceCallLogIndexInStorageCallLogs; i++) {
      CallLogEntry currCallLog = storageCallLogs[i];
      CallLogEntry matchingDeviceCallLog = deviceCallLogs.firstWhere(
          (CallLogEntry callLog) => callLog.timestamp == currCallLog.timestamp,
          orElse: () => null);
      if (matchingDeviceCallLog != null) {
        storageCallLogs[i] = matchingDeviceCallLog;
        deviceCallLogs.remove(matchingDeviceCallLog);
      }
    }

    mergedCallLogs.addAll(deviceCallLogs);
    mergedCallLogs.addAll(storageCallLogs);

    return mergedCallLogs;
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
