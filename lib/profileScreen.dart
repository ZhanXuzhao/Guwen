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

  @override
  void initState() {
    appModel = AppModel();
    loadClasses();
    // appModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
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
              ],
            ),

            // SizedBox(
            //   height: 8,
            // ),
            // class chips
            Row(
              children: [
                Text("班级: ${appModel.user.clas?.name ?? "未设置"}"),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                    onPressed: () {
                      showClassList = true;
                      setState(() {});
                    },
                    child: const Text("设置班级")),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            // class list
            if (showClassList)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("班级列表：(点击班级完成修改)"),
                  SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: List<Widget>.generate(
                      classList.length,
                      (int index) {
                        return ChoiceChip(
                          label: Text(classList[index].name ?? ""),
                          selected: curClassChipIndex == index,
                          onSelected: (bool selected) {
                            if (selected) {
                              curClassChipIndex = index;
                              // curClassId = classList[curClassChipIndex].id;
                              // querySearchHistory(curStarDate, curEndDate);
                              var clas = classList[curClassChipIndex!].lco;
                              appModel.setUserClass(clas).then((_) {
                                showClassList = false;
                                setState(() {});
                              });
                            }
                            setState(() {});
                          },
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),

            // debug utils
            if (kDebugMode)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Debug Utils"),
                  const SizedBox(
                    height: 8,
                  ),

                  // debug buttons
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    direction: Axis.horizontal,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            appModel.clearCache();
                          },
                          child: const Text("Clear Cache")),
                      ElevatedButton(
                          onPressed: () {
                            appModel.initUser();
                          },
                          child: const Text("init user")),
                      ElevatedButton(
                          onPressed: () {
                            appModel.initUserClass();
                          },
                          child: const Text("setUserClass")),
                      ElevatedButton(
                          onPressed: () {
                            appModel.sendSearchRequest(
                                "user test ${math.Random().nextInt(1000)}");
                          },
                          child: const Text("sendSearchRequest")),
                    ],
                  ),
                ],
              ),
          ],
        ));
  }

  void loadClasses() {
    appModel.getClasses().then((list) {
      classList = list;
      var i = 0;
      for (var c in list) {
        if (c.id == appModel.user.clas?.id) {
          curClassChipIndex = i;
        }
      }
      setState(() {});
    }).catchError((onError) {
      log("load classes error: $onError");
    });
  }
}
