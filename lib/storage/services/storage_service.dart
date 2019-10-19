import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getFile(String fileName) async {
    final String path = await _localPath;
    return File('$path/$fileName');
  }

  Future<void> writeToFile(String fileName, String data) async {
    final file = await _getFile(fileName);
    await file.writeAsString(data);
  }

  Future<String> readFromFile(String fileName) async {
    try {
      final file = await _getFile(fileName);
      return await file.readAsString();
    } catch (e) {
      throw Exception("Couldn't read $fileName");
    }
  }

  Future<bool> fileExists(String fileName) async {
    return (await _getFile(fileName)).exists();
  }

  Future<DateTime> getLastModified(String fileName) async {
    return (await _getFile(fileName)).lastModified();
  }

  Future<void> deleteFile(String fileName) async {
    await (await _getFile(fileName)).delete();
  }
}
