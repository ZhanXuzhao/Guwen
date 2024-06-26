import 'dart:developer';

import 'package:f05/models.dart';
import 'package:flutter/material.dart';

import 'beans.dart';
import 'profileScreen.dart';

class ClassManageScreen extends StatefulWidget {
  const ClassManageScreen({super.key});

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

  String? createSchoolMsg = "";
  String? createClassMsg = "";

  var classNewUpdateTime = 0;

  @override
  void initState() {
    appModel = AppModel();
    // appModel.init();
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

            const TitleTextWithBg(
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
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      var schoolName = schoolController.text;
                      if (schoolName.isEmpty) {
                        log("school name can't be empty");
                        createSchoolMsg = "请输入学校名称";
                        setState(() {});
                        return;
                      }
                      // setState(() {});
                      appModel.createSchool(schoolName).then((v) {
                        createSchoolMsg = "学校创建成功";
                      }).catchError((e) {
                        createSchoolMsg = "学校创建失败 $e";
                      }).whenComplete(() {
                        setState(() {});
                      });
                    },
                    child: const Text("创建学校")),
                const SizedBox(
                  width: 8,
                ),
                Text("$createSchoolMsg"),
              ],
            ),

            const SizedBox(
              height: 32,
            ),

            // create class
            const TitleTextWithBg(title: "创建班级"),
            const SizedBox(
              height: 8,
            ),
            const Text("学校列表：（点击设为班级所在学校）"),
            const SizedBox(
              height: 8,
            ),
            SchoolListWrap(
                defaultSelectIndex: 0,
                onDataLoad: (list) {
                  if (curSchool == null && list.isNotEmpty) {
                    curSchool = list.first;
                    setState(() {});
                  }
                },
                onValueSet: (value) {
                  curSchool = value;
                  setState(() {});
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
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      var className = classController.text;
                      if (className.isEmpty) {
                        log("class name can't be empty");
                        createClassMsg = "请输入班级名称";
                        setState(() {});
                        return;
                      }
                      appModel.createClass(className, curSchool).then((v) {
                        log("createClass success");
                        createClassMsg = "创建班级成功";
                        classNewUpdateTime =
                            DateTime.now().millisecondsSinceEpoch;
                      }).catchError((e) {
                        createClassMsg = "创建班级失败 $e";
                        log("createClass fail: $e");
                      }).whenComplete(() {
                        setState(() {});
                      });
                    },
                    child: const Text("创建班级")),
                const SizedBox(
                  width: 8,
                ),
                Text("$createClassMsg"),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            const Text("班级列表："),
            const SizedBox(
              height: 8,
            ),
            ClassListWidget(
                schoolId: curSchool?.id,
                newUpdateTime: classNewUpdateTime,
                onClasSet: (v) {}),
            const SizedBox(
              height: 32,
            ),
            if (AppModel.instance.isAdmin())
              const TitleTextWithBg(title: '人员审批'),
            if (AppModel.instance.isAdmin()) const StaffApplicationManageWidget(),
          ],
        ));
  }

  void updateUI() {
    setState(() {});
  }
}

class StaffApplicationManageWidget extends StatefulWidget {
  const StaffApplicationManageWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StaffApplicationManageWidgetState();
  }
}

class _StaffApplicationManageWidgetState
    extends State<StaffApplicationManageWidget> {
  List<StaffApplication> dataList = [];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) {
      return const Text("暂无申请");
    } else {
      return Expanded(
          child: ListView.builder(
              // fix bug Cannot hit test a render box that has never been laid out.
              shrinkWrap: true,
              itemCount: dataList.length,
              itemBuilder: (context, index) => Row(children: [
                    Text(dataList[index].name ?? ""),
                    // Text('(${dataList[index].email ?? ""})'),
                    const Text(' 申请成为：'),
                    Text(UserInfo.getTypeString(dataList[index].targetType!)),
                    Expanded(child: Container()),
                    IconButton(
                        onPressed: () {
                          AppModel.instance
                              .updateStaffApplications(dataList[index].id, 1)
                              .then((v) {
                            dataList.removeAt(index);
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.check)),
                    IconButton(
                        onPressed: () {
                          AppModel.instance
                              .updateStaffApplications(dataList[index].id, 2)
                              .then((v) {
                            dataList.removeAt(index);
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.close)),
                  ])));
    }
  }

  void loadData() {
    AppModel.instance.loadStaffApplications().then((list) {
      dataList = list;
      setState(() {});
    });
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
      color: Theme.of(context).primaryColor,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
