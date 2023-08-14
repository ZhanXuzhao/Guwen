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
  subs.sort();
  return subs;
}

class AppModel extends ChangeNotifier {
  static final AppModel _instance = AppModel._internal();
  factory AppModel() {
    return _instance;
  }
  AppModel._internal() {}

  final List<String> selectedFiles = <String>[];
  var regStr = "";
  var extralPath = "";
  var exportPath = "";
  List<String> highlightWords=<String>[];

  void add(String path, {bool notify = true}) {
    if (!contains(path)) {
      selectedFiles.add(path);
    }

    if (isDir(path)) {
      listDir(path).forEach((element) {
        add(element, notify: false);
      });
    }

    // notifyListeners();
  }

  void remove(String path, {bool notify = true}) {
    selectedFiles.remove(path);
    if (isDir(path)) {
      listDir(path).forEach((element) {
        remove(element, notify: false);
      });
    }
    // notifyListeners();
  }

  bool contains(String path) {
    return selectedFiles.contains(path);
  }

  void removeAll() {
    selectedFiles.clear();
    // notifyListeners();
  }

  List<String> getAll() {
    return selectedFiles;
  }

  List<String> getAllTxtFile() {
    var filePathList = <String>[];
    selectedFiles.forEach((element) => getAllFiles(element, filePathList));
    // 外部文件
    getAllFiles(extralPath, filePathList);
    var txtList = filterTextFiles(filePathList);
    return txtList;
  }
}

void getAllFiles(String path, List<String> list) {
  if (isDir(path)) {
    listDir(path).forEach((element) {
      getAllFiles(element, list);
    });
  } else {
    list.add(path);
  }
}

List<String> filterTextFiles(List<String> list) {
  return list.where((element) => element.endsWith('.txt')).toList();
}
