import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'beans.dart';

bool isDir(String path) {
  return File(path).statSync().type == FileSystemEntityType.directory;
}

bool isFile(String path) {
  return File(path).statSync().type == FileSystemEntityType.file;
}

bool isTxt(String path) {
  return path.endsWith('.txt') || path.endsWith('.TXT');
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

const String textFilePathDebug = "D:\\Projects\\GHY\\语料\\01先秦"; // 默认外部预料路径
var innerYuliaoPathDebug = 'D:/Projects/GHY/汉语语例溯源系统库'; // 内置预料目录列表 test
var innerYuliaoPathRelease = '/data/yl/汉语语例溯源系统库'; // 内置预料目录列表 release

class AppModel extends ChangeNotifier {
  static final AppModel _instance = AppModel._internal();

  factory AppModel() {
    return _instance;
  }

  AppModel._internal() {
    // addRootDir(textFilePath);
    // initSp(); // async
  }

  late SharedPreferences sp;
  final List<String> selectedFiles = <String>[];
  var regStr = "";
  var yuliaoPath = "";
  var curYuliaoType = 0;
  var exportPath = "";
  List<String> highlightWords = <String>[];
  LinkedHashSet<String> externalDirs = LinkedHashSet();

  //student
  int? userType = 0; //0 undefine, 1 student, 2 teacher
  late User user;
  Student? student;
  Teacher? teacher;

  Future<bool> init() async {
    sp = await SharedPreferences.getInstance();
    initUser();

    return true;
  }

  Future<void> initUser() async {
    userType = sp.getInt("user_type") ?? 0;
    if (userType == 0) {
      user = User();
      await user.save();
      setUserId(user.objectId);
      log("user $user");
      return;
    }
    var userId = getUserId();
    user = (await LCQuery("User").whereEqualTo("objectId", userId).first())
        as User;
    if (userType == 1) {
      student = (await LCQuery("Student")
          .whereEqualTo("id", user.student.id)
          .first()) as Student?;
    } else {
      teacher = (await LCQuery("Student").whereEqualTo("id", user.teacher.id))
          as Teacher?;
    }
    log("init user $user");

    // user.toJson();
  }

  String getUserId() {
    return sp.getString("userId") ?? "";
  }

  void setUserId(String? id) {
    sp.setString("userId", id ?? "");
  }

  void addExternalDir(String path) {
    externalDirs.add(path);
  }

  void removeExternalDir(String path) {
    externalDirs.remove(path);
  }

  void setRegStr(String s) {
    regStr = s;
    sp.setString("RegStr", s);
  }

  String getRegStr() {
    if (regStr.isEmpty) {
      sp.getString("RegStr");
    }
    return regStr;
  }

  void setYuliaoPath(String s) {
    yuliaoPath = s;
    sp.setString("YuliaoPath", s);
  }

  void initYuliaoType() {
    if (selectedFiles.isEmpty) {
      setYuliaoType(0);
    }
  }

  // 设置语料类型
  void setYuliaoType(int type) {
    print("set yuliao type: $type");
    curYuliaoType = type;
    selectedFiles.clear();
    var path = "";
    if(kReleaseMode){
      path = Directory.current.path + innerYuliaoPathRelease;
    } else {
      path = innerYuliaoPathDebug;
    }
    var fileList = listDir(path);
    if (type < fileList.length ) {
      var dir = fileList[type];
      selectedFiles.add(dir);
    }
  }

  String getYuliaoPath() {
    if (yuliaoPath.isEmpty) {
      sp.getString("YuliaoPath");
    }
    return yuliaoPath;
  }

  void setExportPath(String s) {
    exportPath = s;
    sp.setString("ExportPath", s);
  }

  String getExportPathStr() {
    if (exportPath.isEmpty) {
      sp.getString("ExportPath");
    }
    return exportPath;
  }

  /**
   * 增加选中的文件或目录
   */
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

  /**
   * 移除选中的文件或目录
   */
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
    for (var element in selectedFiles) {
      getAllFiles(element, filePathList);
    }
    // 外部文件
    getAllFiles(yuliaoPath, filePathList);
    var txtList = filterTextFiles(filePathList);
    return txtList;
  }

  void saveQuery(String queryReg) {}
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
  return list
      .where((element) => element.endsWith('.txt') || element.endsWith('.TXT'))
      .toList();
}
