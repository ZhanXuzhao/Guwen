import 'dart:convert';

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
  // 正确初始化后不为空
  LCObject? lco;
  String? id;
  String? name;
  Clas? clas;
  String? lcUserId;

  static UserInfo? parse(LCObject? obj) {
    if (obj == null) {
      return null;
    }
    var u = UserInfo();
    u.lco = obj;
    u.id = obj.objectId;
    u.name = obj['name'];
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
    if (jsonString == null || jsonString=="null") {
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
  String? id;
  String? name;
  int clasCount = 0;

  static School parse(LCObject obj) {
    School school = School();
    school.lco = obj;
    school.id = obj.objectId;
    school.name = obj['name'];
    school.clasCount = obj['clasCount'] ?? 0;
    return school;
  }
}

class SearchRequest extends LCObject {
  String get reg => this['reg'];

  set reg(String value) => this['reg'] = value;

  String? get userId => this['userId'];

  set userId(String? value) => this['userId'] = value;

  String? get clasId => this['clasId'];

  String? get userName => this['userName'];

  set userName(String? value) => this['userName'] = value;

  set clasId(String? value) => this['clasId'] = value;

  String? get clasName => this['clasName'];

  set clasName(String? value) => this['clasName'] = value;

  SearchRequest() : super('SearchRequest');
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
