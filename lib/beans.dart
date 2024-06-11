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
  // String get id => this['id'];
  // set id(String value) => this['id'] = value;

  String get name => this['name'];

  set name(String value) => this['name'] = value;

  int get type => this['type'];

  set type(int value) => this['type'] = value;

  Student get student => this['student'] ?? 0;

  set student(Student value) => this['student'] = value;

  Teacher get teacher => this['teacher'];

  set teacher(Teacher value) => this['teacher'] = value;

  User() : super('AppUser');

  // factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  // Map<String, dynamic> toJson() => _$UserToJson(this);


}

class Student extends LCObject {
  String get id => this['id'];

  set id(String value) => this['id'] = value;

  // String get name => this['name'];
  // set name(String value) => this['name'] = value;

  Clas get clas => this['Clas'];

  set clas(Clas value) => this['Clas'] = value;

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
  String get name => this['name'];

  set name(String value) => this['name'] = value;

  School get school => this['School'];

  set school(School value) => this['School'] = value;

  Clas() : super('Clas');
}

class School extends LCObject {
  String get name => this['name'];

  set name(String value) => this['name'] = value;

  School() : super('School');
}

class QueryRequest extends LCObject {
  String get reg => this['reg'];

  set reg(String value) => this['reg'] = value;

  Student get student => this['Student'];

  set student(Student value) => this['Student'] = value;

  QueryRequest() : super('QueryRequest');
}

class DataUtil {
  static init() {
    LCObject.registerSubclass<Student>('Student', () => new Student());
    LCObject.registerSubclass<Student>('Teacher', () => new Teacher());
    LCObject.registerSubclass<Student>('Clas', () => new Clas());
    LCObject.registerSubclass<Student>('School', () => new School());
    LCObject.registerSubclass<Student>('QueryRequest', () => new QueryRequest());
  }

  static Future<List<LCObject>?> queryStudentByName(String name) {
    LCQuery<LCObject> query = LCQuery('Student');
    query.whereEqualTo('name', name);
    Future<List<LCObject>?> find = query.find();
    return find;
  }

}
