import 'dart:developer';

import 'package:f05/models.dart';
import 'package:flutter/material.dart';

import 'beans.dart';

class ClassManageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ClassManageState();
  }
}

class _ClassManageState extends State<StatefulWidget> {
  late AppModel appModel;
  late List<Clas> classList = [];
  int? curClassChipIndex;
  String? curClassId;

  var classController = TextEditingController();
  var schoolController = TextEditingController();

  School? curSchool;
  bool showClassList = false;
  var showSchoolList = false;
  var showSchoolList2 = true;
  var showClassList2 = true;

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
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // direction: Axis.vertical,
          // spacing: 8,
          // runSpacing: 8,
          children: [

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
                    showSchoolList2 = false;
                    // setState(() {});
                    appModel.createSchool(schoolName).then((v) {
                      updateUI();
                    }).whenComplete(() {
                      showSchoolList2 = true;
                      setState(() {});
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
              color: Theme
                  .of(context)
                  .primaryColor,
            ),

            const SizedBox(
              height: 8,
            ),
            const Text("学校列表：（点击设为班级所在学校）"),
            const SizedBox(
              height: 8,
            ),
            if (showSchoolList2)
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
                    showClassList2 = false;
                    appModel.createClass(className, curSchool).then((v) {
                      log("createClass success");
                    }).catchError((e) {
                      log("createClass fail: $e");
                    }).whenComplete(() {
                      showClassList2 = true;
                      setState(() {});
                    });
                  });
                },
                child: const Text("创建班级")
            ),
            const SizedBox(
              height: 8,
            ),

            const Text("班级列表："),
            const SizedBox(
              height: 8,
            ),
            if (showClassList2)
              ClassListWrap(onClasSet: (v) {}),

          ],
        ));
  }

  void updateUI() {
    setState(() {});
  }
}

class TitleTextWithBg extends StatelessWidget {
  const TitleTextWithBg({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // final String t = title;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Theme
          .of(context)
          .primaryColor,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

class SchoolListWrap extends StatefulWidget {
  const SchoolListWrap({super.key, required this.onValueSet});

  final ValueSetter<School> onValueSet;

  @override
  State<StatefulWidget> createState() {
    return _SchoolWrapState();
  }
}

class _SchoolWrapState extends State<SchoolListWrap> {
  // _SchoolWrapState({required this.onValueSet}) {
  //   // super(key:super.key);
  // }

  late List<School> dataList = [];
  int? curIndex;
  AppModel appModel = AppModel();

  // ValueSetter<School> onValueSet;

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
                // var clas = dataList[curIndex!].lco;
                widget.onValueSet(dataList[curIndex!]);
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
        if (list[i].id == appModel.userInfo.clas?.schoolId) {
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
  const ClassListWrap({super.key, required this.onClasSet});

  final ValueSetter<Clas> onClasSet;

  @override
  State<StatefulWidget> createState() {
    return _ClassListWrapState();
  }
}

class _ClassListWrapState extends State<ClassListWrap> {
  late List<Clas> classList = [];
  int? curIndex;
  AppModel appModel = AppModel();

  // ValueSetter<Clas> onClasSet;

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
                // var clas = classList[curIndex!].lco;
                widget.onClasSet(classList[curIndex!]);
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
        if (list[i].id == (appModel.userInfo.clas?.id)) {
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
