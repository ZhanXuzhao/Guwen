import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
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
var innerYuliaoPathDebug =
    'D:\\Projects\\GHY\\语料\\汉语语例溯源系统库short'; // 内置预料目录列表 test
var innerYuliaoPathRelease = '/data/yl/汉语语例溯源系统库'; // 内置预料目录列表 release
const String spKeyUserInfo = 'sp_user_info';

class DbCons {
  static const String appId = "VK6ZRvXfLOpuaColXhtwMnMq-gzGzoHsz";
  static const String appKey = "i99dklDAq3xbCPMU468evvhj";
  static const String server = "https://vk6zrvxf.lc-cn-n1-shared.com";

  static const String userInfoTable = "UserInfo";
  static const String userInfoName = "name";
  static const String userInfoLcUser = "lcUser";
}

class AppModel extends ChangeNotifier {
  static final AppModel instance = _instance;
  static final AppModel _instance = AppModel._internal();
  final List<AppModelCallbacks> _AppModelListeners = [];

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
  late UserInfo userInfo;
  LCUser? lcUser;

  Future<bool> init() async {
    sp = await SharedPreferences.getInstance();
    initDb();
    return true;
  }

  Future<void> initUser() async {
    lcUser = await LCUser.getCurrent();
    if (lcUser == null) {
      // 未登录用户，创建匿名账号
      await createAnonymousUser();
    } else {
      // 已登录， 初始化 userInfo
      // load sp
      // var usp = await loadUserInfoFromSp();
      // 每次在线查询
      UserInfo? usp;
      // load database
      var uo = await LCQuery(UserInfo.TABLE)
          .whereEqualTo(DbCons.userInfoLcUser, lcUser)
          .first();
      if (uo != null) {
        userInfo = UserInfo.parse(uo)!;
      } else {
        // create userInfo in database when no data there
        userInfo = await createUserInfoInDb(lcUser: lcUser);
        cacheUserInfoToSp(userInfo);
      }
    }
    await initUserClass();
    for (var l in _AppModelListeners) {
      l.onUserInit();
    }
    log("initUser: $userInfo");
  }

  Future<void> initUserClass() async {
    if (userInfo.clas != null) {
      var co = await LCQuery("Clas").get(userInfo.clas!.id ?? "");
      userInfo.clas = Clas.parse(co!);
    }
  }

  Future<void> createAnonymousUser() async {
    lcUser = await LCUser.loginAnonymously();
    userInfo = await createUserInfoInDb(lcUser: lcUser);
    cacheUserInfoToSp(userInfo);
  }

  Future<void> cacheUserInfoToSp(UserInfo? userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = jsonEncode(userInfo);
    log("cacheUserInfoToSp $userData");
    await prefs.setString(spKeyUserInfo, userData);
  }

  Future<UserInfo?> loadUserInfoFromSp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserInfo? userInfo = UserInfo.decode(prefs.getString(spKeyUserInfo));
    log("loadUserInfoFromSp $userInfo");
    return userInfo;
  }

  bool isAnonymous() {
    return lcUser != null && lcUser!.isAnonymous;
  }

  // Future<UserInfo> createUserInfoDb() async {
  //   LCObject uo = await createUserInfoInDb();
  //   UserInfo user = UserInfo.parse(uo);
  //   return user;
  // }

  Future<UserInfo> createUserInfoInDb({String? name, LCUser? lcUser}) async {
    var uo = LCObject(UserInfo.TABLE);
    if (name == null) {
      var timeStr = DateFormat('yyyyMMddhhmm').format(DateTime.now());
      name = "User-$timeStr";
    }
    uo[DbCons.userInfoName] = name;
    uo[DbCons.userInfoLcUser] = lcUser;
    // user.save()后才会生产objectID
    await uo.save();
    UserInfo user = UserInfo.parse(uo)!;
    return user;
  }

  // Future<LCObject?> queryUser(String id) async {
  //   return await LCQuery(UserInfo.TABLE).get(id);
  // }

  void initDb() {
    LeanCloud.initialize(DbCons.appId, DbCons.appKey,
        server: DbCons.server,
        queryCache: LCQueryCache() // optional, enable cache
        );
    LCLogger.setLevel(LCLogger.DebugLevel);
    DataUtil.init();
  }

  void testDb(bool test) {
    if (!test) {
      return;
    }
    LCQuery<LCObject> query = LCQuery<LCObject>('UserInfo');
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
    request.userId = userInfo.id;
    request.userName = userInfo.name;
    var clas = userInfo.clas;
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
    if (userInfo.lco == null) {
      log("setUserClass fail, user.lco is null");
      return;
    }
    if (co.lco == null) {
      log("setUserClass fail, co.lco is null");
      return;
    }
    userInfo.lco!['clas'] = co.lco;
    userInfo.clas = co;
    await userInfo.lco!.save();
  }

  _updateUserDb(String key, dynamic value) async {
    var obj = await LCQuery(UserInfo.TABLE).get(userInfo.id!);
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

  Future<List<School>> getSchools({bool showEmptySchool = true}) async {
    var query = LCQuery("School");
    query.orderByAscending('name');
    if (!showEmptySchool) {
      query.whereGreaterThan("clasCount", 0);
    }
    var findResult = await query.find();
    List<School> list = [];
    for (var i in findResult!) {
      var clas = School.parse(i);
      list.add(clas);
    }
    return list;
  }

  Future<void> updateAllSchoolClassCount() async {
    var query = LCQuery("School");
    query.orderByAscending('name');
    var findResult = await query.find();
    for (var i in findResult!) {
      var count =
          await LCQuery("Clas").whereEqualTo('schoolId', i.objectId).count();
      i['clasCount'] = count;
    }
    LCObject.saveAll(findResult);
  }

  Future<void> increaseSchoolClassCount(String? schoolId, int amount) async {
    log("increaseSchoolClassCount school id: $schoolId");
    if (schoolId == null || schoolId.isEmpty) {
      return;
    }
    var query = LCQuery("School");
    var school = await query.get(schoolId);
    log("increaseSchoolClassCount school: $school");
    school?.increment('clasCount', amount);
    school?.save();
  }

  // Future<List<LCObject>?> getClasLCOList() async {
  //   var query = LCQuery("Clas");
  //   var classes = await query.find();
  //   return classes;
  // }

  Future<void> createClass(String className, School? school) async {
    var query = LCQuery("Clas");
    query.whereEqualTo('name', className);
    if (school == null) {
      log("create fail, school null");
      throw Exception("未选择学校");
    } else {
      query.whereEqualTo('schoolId', school.id);
    }
    var lco = await query.first();
    if (lco == null) {
      var clas = LCObject('Clas');
      clas['name'] = className;
      clas['schoolId'] = school.id;
      clas['schoolName'] = school.name;
      await clas.save();
      increaseSchoolClassCount(school.id, 1);
    } else {
      log("create fail, name duplicate");
      throw Exception("已存在同名班级");
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
      throw Exception("已存在同名学校");
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
      var oldSchoolId = lco['schoolId'];
      lco['schoolId'] = school.id;
      lco['schoolName'] = school.name;
      await lco.save();
      increaseSchoolClassCount(oldSchoolId, -1);
      increaseSchoolClassCount(lco['schoolId'].schoolId, 1);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      // 登录成功
      LCUser user = LCUser();
      user.username = email;
      user.password = password;
      user.email = email;
      await user.signUp();
      initUser();
    } on LCException catch (e) {
      log('signUp fail: ${e.code} : ${e.message}');
    }
  }

  Future<void> login(String username, String password) async {
    await LCUser.login(username, password);
    initUser();
    // for (var l in _AppModelListeners) {
    //   l.onLogin();
    // }
  }

  void logout() {
    LCUser.logout();
    lcUser = null;
    cacheUserInfoToSp(null);
    initUser();
    // for (var l in _AppModelListeners) {
    //   l.onLogout();
    // }
  }

  Future<void> createStaffApplications(int targetType) async {
    // set old application as timeout
    // updateStaffApplications(lcUser!.objectId, 3);
    var result = await LCQuery(StaffApplication.TABLE)
        .whereEqualTo("userId", lcUser!.objectId)
        .find();
    if (result != null) {
      for (var obj in result) {
        obj['status'] = 3;
      }
      LCObject.saveAll(result);
    }

    // create new application
    var v = LCObject(StaffApplication.TABLE);
    v['userId'] = lcUser!.objectId;
    v['name'] = userInfo.name;
    v['email'] = lcUser!.email ?? "";
    v['targetType'] = targetType;
    v['status'] = 0;
    v.save();
  }

  // status 1 approved, 2 deny, 3 timeout
  Future<void> updateStaffApplications(String? appId, int status) async {
    if (appId == null) {
      return;
    }
    var obj = await LCQuery(StaffApplication.TABLE).get(appId);
    if (obj == null) {
      return;
    }

    obj['status'] = status;
    obj.save();

    var app = StaffApplication.parse(obj);
    var lcUser = await LCUser.getQuery().get(app.userId!);
    if (status == 1) {
      var userInfo =
          await LCQuery(UserInfo.TABLE).whereEqualTo('lcUser', lcUser).first();
      // UserInfo.parse(obj);
      if (userInfo == null) {
        return;
      }
      userInfo['type'] = app.targetType;
      userInfo.save();
    }
  }

  Future<List<StaffApplication>> loadStaffApplications() async {
    var query = LCQuery(StaffApplication.TABLE);
    query.whereEqualTo('status', 0);
    var results = await query.find();
    List<StaffApplication> list = [];
    if (results != null) {
      for (var i in results) {
        list.add(StaffApplication.parse(i));
      }
    }
    return list;
  }

  Future<void> updateUsername(String text) async {
    await _updateUserDb('name', text);
    userInfo.name = text;
  }

  Future<void> updateUserType(int type) async {
    await _updateUserDb('type', type);
  }

  bool hasLogin() {
    return lcUser != null && !lcUser!.isAnonymous;
  }

  // bool isStudent(){
  //   return hasLogin() && userInfo.type == 0;
  // }

  bool isTeacher() {
    return hasLogin() && userInfo.type == 1;
  }

  bool isAdmin() {
    return hasLogin() && userInfo.admin == 1;
  }

  void registerCallback(AppModelCallbacks cb) {
    _AppModelListeners.add(cb);
  }

  void unregisterCallback(AppModelCallbacks cb) {
    _AppModelListeners.remove(cb);
  }

  // tabType 0 home, 1 profile
  void changeTab(int tabType) {
    var tabIndex = 0;
    if (tabType == 0) {
      tabIndex = 0;
    } else if (tabType == 1) {
      if (AppModel.instance.isTeacher()) {
        tabIndex = 3;
      } else {
        tabIndex = 0;
      }
    }
    for (var l in _AppModelListeners) {
      l.changeTab(tabIndex);
    }
  }

  /// type 0 search result, 1 static result
  Future<void> pickDirAndExportData(List<String> data, int type,
      ValueSetter<double>? progressListener) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      // User canceled the picker
      log("dir path: $selectedDirectory");
      var dir = Directory(selectedDirectory);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      var timeStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      var hws = highlightWords.join("_");
      var fileName = type == 0 ? "搜索结果 $hws $timeStr" : "搜索统计 $timeStr";
      var filePath = "$selectedDirectory/$fileName.txt";
      await Isolate.run(() async {
        await writeToFile(filePath, data);
      });
    } else {
      throw Exception("未选择导出路径");
    }
  }

  static Future<void> writeToFile(String filePath, List<String> data) async {
    var file = File(filePath);
    file.create(recursive: true);
    log('export file $file');
    for (var line in data) {
      file.writeAsStringSync("$line\r",
          mode: FileMode.append, encoding: utf8);
    }
  }

  String getExportFileName(String fileNameSuffix) {
    var timeStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    var hws = highlightWords.join("_");

    var s = "${timeStr}_$hws";
    return s;
  }

  void setAsAdmin(String? objectId) {
    _updateUserDb('admin', 1);
  }
}

abstract class AppModelCallbacks {
// mixin AppModelCallbacks {
  void onUserInit();

  void onLogout();

  void onLogin();

  void changeTab(int tabIndex);
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
