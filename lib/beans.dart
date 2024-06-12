import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';
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

class User {
  // 正确初始化后不为空
  LCObject? lco;
  String? id;
  String? name;
  Clas? clas;

  static User parse(LCObject obj) {
    var u = User();
    u.lco = obj;
    u.id = obj.objectId;
    u.name = obj['name'];
    u.clas = Clas.parse(obj['clas']);
    return u;
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

  static School parse(LCObject obj) {
    School school = School();
    school.lco = obj;
    school.id = obj.objectId;
    school.name = obj['name'];
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
