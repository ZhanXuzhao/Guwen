import 'dart:io';

import 'package:flutter/foundation.dart';

class FileData {
  final String name;
  final String path;
  final bool isFile;

  const FileData(this.name, this.path, this.isFile);
}

bool isDir(String path) {
  File file = File(path);
  return file.statSync().type == FileSystemEntityType.directory;
}

List<String> listDir(String path) {
  var dir = Directory(path);
  List<String> subs = <String>[];
  dir.listSync().forEach((element) {
    subs.add(element.path);
  });
  return subs;
}

class FileListModel extends ChangeNotifier {
  static final FileListModel _instance = FileListModel._internal();
  factory FileListModel() {
    return _instance;
  }
  FileListModel._internal() {}

  final List<String> selectedFiles = <String>[];

  void add(String path, {bool notify = true}) {
    if (!contains(path)) {
      selectedFiles.add(path);
    }

    if (isDir(path)) {
      listDir(path).forEach((element) {
        add(element, notify: false);
      });
    }

    notifyListeners();
  }

  void remove(String path, {bool notify = true}) {
    selectedFiles.remove(path);
    if (isDir(path)) {
      listDir(path).forEach((element) {
        remove(element, notify: false);
      });
    }
    notifyListeners();
  }

  bool contains(String path) {
    return selectedFiles.contains(path);
  }

  void removeAll() {
    selectedFiles.clear();
    notifyListeners();
  }

  List<String> getAll() {
    return selectedFiles;
  }
}
