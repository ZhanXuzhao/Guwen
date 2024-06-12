import 'dart:developer';
import 'dart:math' as math;

import 'package:f05/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'beans.dart';

class ProfileScreen2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<StatefulWidget> {
  late AppModel appModel;
  late List<Clas> classList = [];
  int? curClassChipIndex;
  String? curClassId;
  bool showClassList = false;

  var classController = TextEditingController();
  var schoolController = TextEditingController();

  School? curSchool;

  var showSchoolList = false;

  @override
  void initState() {
    appModel = AppModel();
    appModel.init();
    // loadClasses();
    // appModel.init();
    super.initState();
  }

  @override
  void dispose() {
    classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // direction: Axis.vertical,
          // spacing: 8,
          // runSpacing: 8,
          children: [
            // SizedBox(
            //   height: 8,
            // ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              direction: Axis.vertical,
              children: [
                const Text("用户信息"),
                Text("姓名: ${appModel.user.name ?? "未设置"}"),
                // class
                Row(
                  children: [
                    Text("班级: ${appModel.user.clas?.name ?? "未设置"}"),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          showClassList = !showClassList;
                          showSchoolList = false;
                          setState(() {});
                        },
                        child: const Text("设置班级")),
                  ],
                ),

                // school
                Row(
                  children: [
                    Text("学校: ${appModel.user.clas?.schoolName ?? "未设置"}"),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          showSchoolList = !showSchoolList;
                          showClassList = false;
                          setState(() {});
                        },
                        child: const Text("修改班级所在学校")),
                  ],
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            // class list
            if (showClassList)
              ClassListWrap(onClasSet: (clas) {
                appModel.setUserClass(clas).then((_) {
                  showClassList = false;
                  setState(() {});
                });
              }),

            // school list
            if (showSchoolList)
              SchoolListWrap(onValueSet: (value) {
                appModel.setClassSchool(appModel.user.clas, value).then((_) {
                  showSchoolList = false;
                  setState(() {});

                  // update user.clas info and notify ui change
                  appModel.initUser().then((v) {
                    setState(() {});
                  });
                });
              }),

            const SizedBox(
              height: 8,
            ),

            // create school
            // const Text("创建学校"),

            TitleTextWithBg(
              title: "创建学校",
            ),
            const SizedBox(
              height: 8,
            ),
            // cr
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '输入学校名称',
                    ),
                    onChanged: (value) {
                      // appModel.setRegStr(value);
                      print("onChange $value");
                    },
                    controller: schoolController,
                  ),
                ),

                Container(
                  width: 8,
                ),

                // search button
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    var schoolName = schoolController.text;
                    if (schoolName.isEmpty) {
                      log("school name can't be empty");
                      return;
                    }
                    appModel.createSchool(schoolName).then((v) {
                      updateUI();
                    });
                  });
                },
                child: const Text("创建学校")),
            const SizedBox(
              height: 32,
            ),

            // create class
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: const Text(
                "创建班级",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              color: Theme.of(context).primaryColor,
            ),

            const SizedBox(
              height: 8,
            ),
            const Text("学校列表：（点击设为班级所在学校）"),
            const SizedBox(
              height: 8,
            ),
            SchoolListWrap(onValueSet: (value) {
              curSchool = value;
            }),

            const SizedBox(
              height: 8,
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '输入班级名称',
                    ),
                    onChanged: (value) {
                      // appModel.setRegStr(value);
                      print("onChange $value");
                    },
                    controller: classController,
                  ),
                ),
                //
                // ClassListWrap(onClasSet: (clas){
                //
                // }),
                Container(
                  width: 8,
                ),

                // search button
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    var className = classController.text;
                    if (className.isEmpty) {
                      log("class name can't be empty");
                      return;
                    }
                    appModel.createClass(className, curSchool).then((v) {
                      log("createClass success");
                    }).catchError((e) {
                      log("createClass fail: $e");
                    });
                  });
                },
                child: const Text("创建班级")),
            const SizedBox(
              height: 8,
            ),

            const Text("班级列表："),
            const SizedBox(
              height: 8,
            ),
            ClassListWrap(onClasSet: (v) {}),
          ],
        ));
  }

  void updateUI() {
    setState(() {});
  }
}

class TitleTextWithBg extends StatelessWidget {
  TitleTextWithBg({super.key, required this.title});

  String title;

  @override
  Widget build(BuildContext context) {
    // final String t = title;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      color: Theme.of(context).primaryColor,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

class SchoolListWrap extends StatefulWidget {
  SchoolListWrap({super.key, required this.onValueSet});

  ValueSetter<School> onValueSet;

  @override
  State<StatefulWidget> createState() {
    return _SchoolWrapState(onValueSet: onValueSet);
  }
}

class _SchoolWrapState extends State<StatefulWidget> {
  _SchoolWrapState({required this.onValueSet}) {
    // super(key:super.key);
  }

  late List<School> dataList = [];
  int? curIndex;
  AppModel appModel = AppModel();
  ValueSetter<School> onValueSet;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: List<Widget>.generate(
        dataList.length,
        (int index) {
          return ChoiceChip(
            label: Text(dataList[index].name ?? ""),
            selected: curIndex == index,
            onSelected: (bool selected) {
              if (selected) {
                curIndex = index;
                // curClassId = classList[curClassChipIndex].id;
                // querySearchHistory(curStarDate, curEndDate);
                var clas = dataList[curIndex!].lco;
                onValueSet(dataList[curIndex!]);
              }
              setState(() {});
            },
          );
        },
      ).toList(),
    );
  }

  void loadData() {
    appModel.getSchools().then((list) {
      dataList = list;
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == appModel.user.clas?.schoolId) {
          curIndex = i;
          break;
        }
      }
      setState(() {});
    }).catchError((onError) {
      log("load schools error: $onError");
    });
  }
}

class ClassListWrap extends StatefulWidget {
  ClassListWrap({super.key, required this.onClasSet});

  ValueSetter<Clas> onClasSet;

  @override
  State<StatefulWidget> createState() {
    return _ClassListWrapState(onClasSet: onClasSet);
  }
}

class _ClassListWrapState extends State<StatefulWidget> {
  _ClassListWrapState({required this.onClasSet}) {
    // super(key:super.key);
  }

  late List<Clas> classList = [];
  int? curIndex = null;
  AppModel appModel = AppModel();
  ValueSetter<Clas> onClasSet;

  @override
  void initState() {
    loadClasses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: List<Widget>.generate(
        classList.length,
        (int index) {
          return ChoiceChip(
            label: Text(classList[index].name ?? ""),
            selected: curIndex == index,
            onSelected: (bool selected) {
              if (selected) {
                curIndex = index;
                // curClassId = classList[curClassChipIndex].id;
                // querySearchHistory(curStarDate, curEndDate);
                var clas = classList[curIndex!].lco;
                onClasSet(classList[curIndex!]);
              }
              setState(() {});
            },
          );
        },
      ).toList(),
    );
  }

  void loadClasses() {
    appModel.getClasses().then((list) {
      classList = list;
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == (appModel.user.clas?.id)) {
          curIndex = i;
          break;
        }
      }
      setState(() {});
    }).catchError((onError) {
      log("load classes 2 error: $onError");
    });
  }
}
