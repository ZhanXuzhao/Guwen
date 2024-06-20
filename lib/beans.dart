import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:leancloud_storage/leancloud.dart';
// part 'user.g.dart';

//
// demo LCObject
// {
// "__type":"Pointer",
// "className":"Hello",
// "objectId":"6666a5b8830451028079ba22",
// "createdAt":"2024-06-10 15:05:28.196",
// "updatedAt":"2024-06-10 15:05:28.196",
// "intValue":123
// }

class UserInfo {
  static const TABLE = "UserInfo";

  // 正确初始化后不为空
  LCObject? lco;
  String? id;
  String? name;
  Clas? clas;
  String? lcUserId;
  int type = 0; // 0 student, 1 teacher
  int admin = 0; // 0 非admin, 1 admin

  static UserInfo? parse(LCObject? obj) {
    if (obj == null) {
      return null;
    }
    var u = UserInfo();
    u.lco = obj;
    u.id = obj.objectId;
    u.name = obj['name'];
    u.type = obj['type'] ?? 0;
    u.admin = obj['admin'] ?? 0;
    var lcUserObj = obj['lcUser'];
    if (lcUserObj != null) {
      u.lcUserId = lcUserObj['objectId'];
    }
    if (obj['clas'] != null) {
      u.clas = Clas.parse(obj['clas']);
    }
    return u;
  }

  static UserInfo? decode(String? jsonString) {
    if (jsonString == null || jsonString == "null") {
      return null;
    }
    Map<String, dynamic> data = jsonDecode(jsonString);
    UserInfo result = UserInfo();
    data.forEach((String key, dynamic value) {
      if (key == 'id') {
        result.id = value;
      } else if (key == 'name') {
        result.name = value;
      } else if (key == 'clas') {
        result.clas = value;
      } else if (key == 'lcUserId') {
        result.lcUserId = value;
      }
    });
    return result;
  }

  String getCurTypeString() {
    return getTypeString(type);
  }

  static String getTypeString(int type) {
    if (type == 0) {
      return "学生";
    } else if (type == 1) {
      return "老师";
    } else if (type == 100) {
      return "管理员";
    } else {
      return "其它";
    }
  }
}

class StaffApplication {
  static const TABLE = "StaffApplication";

  LCObject? lco;
  String? id;
  String? userId; // 申请人 userId
  String? name;
  String? email;
  int? targetType;
  int status = 0; // 0 unresolved, 1 approved, 2 denied, 3 timeout
  String? msg;

  static StaffApplication parse(LCObject obj) {
    StaffApplication data = StaffApplication();
    data.lco = obj;
    data.id = obj.objectId;
    data.userId = obj['userId'];
    data.email = obj['email'];
    data.name = obj['name'];
    data.targetType = obj['targetType'];
    data.status = obj['status'] ?? 0;
    data.msg = obj['msg'];
    return data;
  }
}

class Clas {
  LCObject? lco;
  String? id;
  String? name;
  String? schoolId;
  String? schoolName;

  static Clas parse(LCObject obj) {
    Clas clas = Clas();
    clas.lco = obj;
    clas.id = obj.objectId;
    clas.name = obj['name'];
    clas.schoolId = obj['schoolId'];
    clas.schoolName = obj['schoolName'];
    return clas;
  }
}

class School {
  LCObject? lco;

  String? get id => lco?.objectId;

  String? get name => lco?['name'];

  int get clasCount => lco?['clasCount'] ?? 0;

  static School parse(LCObject obj) {
    School school = School();
    school.lco = obj;
    return school;
  }
}

class SearchRequest {
  static const TABLE = 'SearchRequest';

  String? id;
  String? reg;
  String? userId;
  String? userName;
  String? clasId;
  String? clasName;
  String? time;

  // String get reg => this['reg'];
  //
  // set reg(String value) => this['reg'] = value;
  //
  // String? get userId => this['userId'];
  //
  // set userId(String? value) => this['userId'] = value;
  //
  // String? get clasId => this['clasId'];
  //
  // String? get userName => this['userName'];
  //
  // set userName(String? value) => this['userName'] = value;
  //
  // set clasId(String? value) => this['clasId'] = value;
  //
  // String? get clasName => this['clasName'];
  //
  // set clasName(String? value) => this['clasName'] = value;
  //
  // SearchRequest() : super('SearchRequest');

  static parse(LCObject lco) {
    var sr = SearchRequest();
    sr.id = lco.objectId ?? "";
    sr.reg = lco['reg'];
    sr.userId = lco['userId'];
    sr.userName = lco['userName'];
    sr.clasId = lco['clasId'];
    sr.clasName = lco['clasName'];
    sr.time = DateFormat('yyyy-MM-dd kk:mm').format(lco.createdAt!);
    return sr;
  }
}

class DataUtil {
  static init() {}

  static Future<List<LCObject>?> queryStudentByName(String name) {
    LCQuery<LCObject> query = LCQuery('Student');
    query.whereEqualTo('name', name);
    Future<List<LCObject>?> find = query.find();
    return find;
  }
}
