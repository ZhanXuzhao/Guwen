import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
var innerYuliaoPathDebug = 'D:/Projects/GHY/汉语语例溯源系统库short'; // 内置预料目录列表 test
var innerYuliaoPathRelease = '/data/yl/汉语语例溯源系统库'; // 内置预料目录列表 release

class AppModel extends ChangeNotifier {
  static final AppModel _instance = AppModel._internal();

  factory AppModel() {
    return _instance;
  }

  AppModel._internal() {
    // init
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
  LCUser? lcUser;

  Future<bool> init() async {
    sp = await SharedPreferences.getInstance();
    initDb();
    initUser();
    return true;
  }

  void clearCache() {
    cacheUserId("");
  }

  Future<void> initUser() async {
    lcUser = await LCUser.getCurrent();
    userType = sp.getInt("user_type") ?? 0;
    var userId = sp.getString("userId") ?? "";
    log("initUser userId: $userId");
    if (userId == "") {
      user = await createUserDb();
      cacheUserId(user.id);
      log("initUser create: $user");
    } else {
      var uo = (await LCQuery("AppUser").get(userId))!;
      user = User.parse(uo);
      log("initUser from cloud: $user");
    }
    if (user.clas != null) {
      var co = await LCQuery("Clas").get(user.clas!.id ?? "");
      user.clas = Clas.parse(co!);
    }
    // student=user.student;
    // teacher=user.teacher;

    log("initUser at last: $user");
  }

  Future<User> createUserDb() async {
    var uo = LCObject("AppUser");
    var timeStr = DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
    uo['name'] = "Jack from $timeStr";
    // user.save()后才会生产objectID
    await uo.save();
    // set user.lco
    User user = User.parse(uo);
    // initUserClass();
    return user;
  }

  Future<LCObject?> queryUser(String id) async {
    return await LCQuery("AppUser").get(id);
  }

  void initDb() {
    LeanCloud.initialize(
        'VK6ZRvXfLOpuaColXhtwMnMq-gzGzoHsz', 'i99dklDAq3xbCPMU468evvhj',
        server: 'https://vk6zrvxf.lc-cn-n1-shared.com',
        // to use your own custom domain
        queryCache: LCQueryCache() // optional, enable cache
        );
    LCLogger.setLevel(LCLogger.DebugLevel);
    DataUtil.init();
  }

  void testDb(bool test) {
    if (!test) {
      return;
    }
    LCQuery<LCObject> query = LCQuery<LCObject>('AppUser');
    query.limit(10);
    query.find();
    query.find().then((list) {
      if (list == null) {
        log('empty');
      }
      for (var l in list!) {
        log("l in list  $l - ${l['intValue']}\n");
      }
    });

    // initStudent();
    // testDbAsync();
  }

  sendSearchRequest(String reg) {
    var request = SearchRequest();
    request.reg = reg;
    request.userId = user.id;
    request.userName = user.name;
    var clas = user.clas;
    if (clas != null) {
      request.clasId = clas.id;
      log('clas $clas');
      request.clasName = clas.name;
    }
    request.save();

    // var sr = LCObject("SearchRequest");
    // sr['reg'] = reg;
    // sr['user'] = user;
    // sr.save();
  }

  getSearchHistory(DateTime start, DateTime end, String? classId) async {
    var query = LCQuery("SearchRequest");
    query.whereGreaterThan('createdAt', start);
    query.whereLessThan("createdAt", end);
    log("getSearchHistory $start $end $classId");
    if (classId != null && classId != "") {
      query.whereEqualTo("clasId", classId);
    }
    query.limit(1000);
    List<LCObject>? list = await query.find();

    // void main() {
    //   var temp= {
    //     'A' : 3,
    //     'B' : 1,
    //     'C' : 2
    //   };
    //
    //   var sortedKeys = temp.keys.toList(growable:false)
    //     ..sort((k1, k2) => temp[k1].compareTo(temp[k2]));
    //   LinkedHashMap sortedMap = new LinkedHashMap
    //       .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);
    //   print(sortedMap);
    // }

    Map<String, int> map = {};
    for (var sr in list!) {
      var reg = sr['reg'];
      var cur = map[reg] ?? 0;
      map[reg] = cur + 1;
    }
    var sortedByValueMap = Map.fromEntries(
        map.entries.toList()..sort((e1, e2) => -e1.value.compareTo(e2.value)));
    log("Search history: $sortedByValueMap");

    return sortedByValueMap;
  }

  Future<void> testDbAsync() async {
    // initStudent();
    var query = LCQuery("Student");
    var student = await query.first();
    log(student.toString());
  }

  // initUserClass() {
  //   setUserClass(null);
  // }

  Future<void> setUserClass(Clas co) async {
    if (user.lco == null) {
      log("setUserClass fail, user.lco is null");
      return;
    }
    if (co.lco == null) {
      log("setUserClass fail, co.lco is null");
      return;
    }
    user.lco!['clas'] = co.lco;
    user.clas = co;
    await user.lco!.save();
  }

  updateUserDb(String key, dynamic value) async {
    var obj = await LCQuery("AppUser").get(user.id ?? "");
    obj![key] = value;
    obj.save();
    log("updateDb: $obj");
  }

  // void initStudent() {
  //   School school = new School();
  //   school.name = "school-001";
  //   school.save();
  //
  //   Clas clas = Clas();
  //   clas.school = school;
  //   clas.name = "class-001";
  //   clas.save();
  //
  //   Student student = Student();
  //   student.id = "test_001";
  //   student.save();
  //
  //   Teacher teacher = Teacher();
  //   teacher.save();
  //
  //   User user = User();
  //   user.name = "Jack1";
  //   user.type = 2;
  //   user.student = student;
  //   user.teacher = teacher;
  //   user.save();
  //
  //   log('init student success');
  // }

  String getUserId() {
    return sp.getString("userId") ?? "";
  }

  void cacheUserId(String? id) {
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
    log("set yuliao type: $type");
    curYuliaoType = type;
    selectedFiles.clear();
    var path = "";
    if (kReleaseMode) {
      path = Directory.current.path + innerYuliaoPathRelease;
    } else {
      path = innerYuliaoPathDebug;
    }
    var fileList = listDir(path);
    if (type < fileList.length) {
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

  /// 增加选中的文件或目录
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

  /// 移除选中的文件或目录
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

  Future<List<Clas>> getClasses({String? schoolId}) async {
    var query = LCQuery("Clas");
    query.orderByAscending('name');
    if (schoolId != null && schoolId.isNotEmpty) {
      query.whereEqualTo("schoolId", schoolId);
    }
    var findResult = await query.find();
    List<Clas> list = [];
    for (var c in findResult!) {
      log("class data: $c");
      var clas = Clas.parse(c);
      list.add(clas);
    }
    return list;
  }

  Future<List<School>> getSchools() async {
    var query = LCQuery("School");
    query.orderByAscending('name');
    var findResult = await query.find();
    List<School> list = [];
    for (var i in findResult!) {
      var clas = School.parse(i);
      list.add(clas);
    }
    return list;
  }

  // Future<List<LCObject>?> getClasLCOList() async {
  //   var query = LCQuery("Clas");
  //   var classes = await query.find();
  //   return classes;
  // }

  Future<void> createClass(String className, School? school) async {
    var lco = await LCQuery("Clas").whereEqualTo('name', className).first();
    if (lco == null) {
      if (school == null) {
        log("create fail, school null");
        return;
      }
      var clas = LCObject('Clas');
      clas['name'] = className;
      clas['schoolId'] = school.id;
      clas['schoolName'] = school.name;
      await clas.save();
    } else {
      log("create fail, name duplicate");
    }
  }

  Future<void> createSchool(String schoolName) async {
    var school =
        await LCQuery("School").whereEqualTo('name', schoolName).first();
    if (school == null) {
      school = LCObject("School");
      school['name'] = schoolName;
      await school.save();
    } else {
      log("create fail, name duplicate");
    }
  }

  setClassSchool(Clas? clas, School school) async {
    var className = clas?.name;
    if (className == null) {
      log("set fail, class name is empty");
      return;
    }
    var lco = await LCQuery("Clas").whereEqualTo('name', className).first();
    if (lco == null) {
      log("create fail, class:$className not exist");
    } else {
      lco['schoolId'] = school.id;
      lco['schoolName'] = school.name;
      await lco.save();
    }
  }

  Future<void> login(String username, String password) async {
    LCUser lcu = await LCUser.login(username, password);
    lcUser = lcu;
    // LCUser.getCurrent();
    // LCUser.logout();
  }

  Future<void> signUp(String email, String password) async {
    try {
      // 登录成功
      LCUser user = LCUser();
      user.username = email;
      user.password = password;
      user.email = email;
      await user.signUp();
    } on LCException catch (e) {
      log('signUp fail: ${e.code} : ${e.message}');
    }
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
  return list
      .where((element) => element.endsWith('.txt') || element.endsWith('.TXT'))
      .toList();
}
