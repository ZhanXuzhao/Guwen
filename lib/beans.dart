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
@JsonSerializable()
class User extends LCObject {
  // 由于objectID不能set，为了便于其它操作，手动设置 id = objectID
  String? get id => this['id'];

  set id(String? value) => this['id'] = value;

  String get name => this['name'];

  set name(String value) => this['name'] = value;

  // int get type => this['type'] ?? 0;
  //
  // set type(int? value) => this['type'] = value;

  Clas? get clas => this['clas'];

  set clas(Clas? value) => this['clas'] = value;

  Student? get student => this['student'] ;

  set student(Student? value) => this['student'] = value;

  Teacher? get teacher => this['teacher'];

  set teacher(Teacher? value) => this['teacher'] = value;

  User() : super('AppUser');

  static User parse(LCObject obj) {
    var u = User();
    u.id = obj.objectId;
    u.name = obj['name'];
    u.clas = obj['clas'];
    u.student = obj['student'];
    u.teacher = obj['teacher'];
    return u;
  }

// factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
// Map<String, dynamic> toJson() => _$UserToJson(this);
}

class Student extends LCObject {
  // equal to objectId
  String? get id => this['id'];

  set id(String? value) => this['id'] = value;

  // 教务系统中的student id
  String? get studentId => this['studentId'];

  set studentId(String? value) => this['studentId'] = value;

  String? get userId => this['userId'];

  set userId(String? value) => this['userId'] = value;

  // String get name => this['name'];
  // set name(String value) => this['name'] = value;

  Clas? get clas => this['Clas'];

  set clas(Clas? value) => this['Clas'] = value;

  Student() : super('Student');
}

class Teacher extends LCObject {
  String get id => this['id'];

  set id(String value) => this['id'] = value;

  // String get name => this['name'];
  // set name(String value) => this['name'] = value;

  Teacher() : super('Teacher');
}

class Clas extends LCObject {
  String get id => this['id'] ?? objectId;

  set id(String? value) => this['id'] = value;

  String? get name => this['name'];

  set name(String? value) => this['name'] = value;

  School get school => this['School'];

  set school(School value) => this['School'] = value;

  Clas() : super('Clas');

  static Clas parse(LCObject obj) {
    Clas clas = Clas();
    clas.id = obj.objectId;
    clas.name = obj['name'];
    clas.school = obj['School'];
    return clas;
  }
}

class School extends LCObject {
  String get name => this['name'];

  set name(String value) => this['name'] = value;

  School() : super('School');
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
  static init() {
    LCObject.registerSubclass<Student>('AppUser', () => User());
    LCObject.registerSubclass<Student>('Student', () => Student());
    LCObject.registerSubclass<Student>('Teacher', () => Teacher());
    LCObject.registerSubclass<Student>('Clas', () => Clas());
    LCObject.registerSubclass<Student>('School', () => School());
    LCObject.registerSubclass<Student>('SearchRequest', () => SearchRequest());
  }

  static Future<List<LCObject>?> queryStudentByName(String name) {
    LCQuery<LCObject> query = LCQuery('Student');
    query.whereEqualTo('name', name);
    Future<List<LCObject>?> find = query.find();
    return find;
  }
}
