import 'dart:developer';

import 'package:f05/models.dart';
import 'package:flutter/material.dart';
import 'package:leancloud_storage/leancloud.dart';

import 'beans.dart';

class ProfileScreen2 extends StatefulWidget {
  const ProfileScreen2({super.key});

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

  var classController = TextEditingController();
  var schoolController = TextEditingController();

  // login controller
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var emailController = TextEditingController();
  var verifyCodeController = TextEditingController();

  School? curSchool;
  bool showClassList = false;
  var showSchoolList = false;
  var showSchoolList2 = true;
  var showClassList2 = true;

  var showLoginMsg = false;
  var loginMsg = "";

  var curSchoolId;

  // SchoolIdSteam schoolIdSteam = SchoolIdSteam();

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
            if (appModel.lcUser != null && !appModel.isAnonymous())
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  const TitleTextWithBg(title: "用户信息"),

                  const SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    direction: Axis.vertical,
                    children: [
                      Text("账户: ${appModel.lcUser?.email ?? "未登录"}"),
                      Text("姓名: ${appModel.userInfo.name ?? "未设置"}"),
                      Row(
                        children: [
                          Text(
                              "学校: ${appModel.userInfo.clas?.schoolName ?? "未设置"}"),
                          const SizedBox(
                            width: 8,
                          ),
                          Text("班级: ${appModel.userInfo.clas?.name ?? "未设置"}"),
                          const SizedBox(
                            width: 8,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                showClassList = !showClassList;
                                showSchoolList = false;
                                setState(() {});
                              },
                              child: const Text("修改")),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // school and class
                  if (showClassList)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("选择学校："),
                        SchoolListWrap(
                            showEmptySchool: false,
                            onDataLoad: (list) {
                              // if (list.isNotEmpty) {
                              //   curSchoolId = list.first.id;
                              //   setState(() {
                              //
                              //   });
                              // }
                            },
                            onValueSet: (value) {
                              curSchoolId = value.id;
                              setState(() {});
                            }),

                        // class list
                        const Text("选择班级："),
                        ClassListWrap(
                            schoolId: curSchoolId,
                            onClasSet: (clas) {
                              appModel.setUserClass(clas).then((_) {
                                showClassList = false;
                                setState(() {});
                              });
                            }),
                      ],
                    ),

                  const SizedBox(
                    height: 8,
                  ),
                ],
              ))
            else
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleTextWithBg(title: "登录注册"),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '邮箱',
                    ),
                    controller: emailController,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '密码',
                    ),
                    controller: passwordController,
                  ),
                  // TextField(
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     hintText: '邮箱',
                  //   ),
                  //   controller: emailController,
                  // ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            appModel
                                .login(emailController.text,
                                    passwordController.text)
                                .then((v) {
                              loginMsg = "登陆成功";
                            }).catchError((e) {
                              if (e is LCException) {
                                if (e.code == 211) {
                                  loginMsg = '账号未注册，请先完成注册';
                                }
                              } else {
                                loginMsg = '登录失败 ${e.code} : ${e.message}';
                              }
                              showLoginMsg = true;
                            }).whenComplete(() {
                              setState(() {});
                            });
                          },
                          child: const Text("登录")),
                      const SizedBox(
                        width: 8,
                      ),
                      // sign up
                      // 649912323@qq.com
                      ElevatedButton(
                          onPressed: () {
                            appModel
                                .signUp(emailController.text,
                                    passwordController.text)
                                .then((v) {
                              loginMsg = "注册成功，请完成邮箱验证，之后即可正常登录";
                            }).catchError((e) {
                              // 如果收到 202 错误码，意味着已经存在使用同一 username 的账号，
                              // 此时应提示用户换一个用户名。
                              // 除此之外，每个用户的 email 和 mobilePhoneNumber 也需要保持唯一性，
                              // 否则会收到 203 或 214 错误。
                              // 可以考虑在注册时把用户的 username 设为与 email 相同，
                              // 这样用户可以直接 用邮箱重置密码。
                              if (e is LCException) {
                                if (e.code == 202) {
                                  loginMsg = "该邮箱已注册";
                                }
                              } else {
                                log("login fail: $e");
                                loginMsg = e;
                              }
                              showLoginMsg = true;
                            }).whenComplete(() {
                              setState(() {});
                            });
                          },
                          child: const Text("注册")),
                      const SizedBox(
                        width: 8,
                      ),

                    ],
                  ),
                  if (showLoginMsg) Text(loginMsg),
                ],
              )),
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
      color: Theme.of(context).primaryColor,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

class SchoolListWrap extends StatefulWidget {
  SchoolListWrap(
      {super.key,
      this.defaultSelectIndex,
      this.onDataLoad,
      required this.onValueSet,
      this.showEmptySchool = true});

  int? defaultSelectIndex;
  final ValueSetter<List<School>>? onDataLoad;
  final ValueSetter<School> onValueSet;
  bool showEmptySchool = true;

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
    curIndex = widget.defaultSelectIndex;
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
    appModel.getSchools(showEmptySchool: widget.showEmptySchool).then((list) {
      dataList = list;
      if (widget.onDataLoad != null) {
        widget.onDataLoad!(list);
      }
      // for (int i = 0; i < list.length; i++) {
      //   if (list[i].id == appModel.userInfo.clas?.schoolId) {
      //     curIndex = i;
      //     break;
      //   }
      // }
      setState(() {});
    }).catchError((onError) {
      log("load schools error: $onError");
    });
  }
}

class ClassListWrap extends StatefulWidget {
  ClassListWrap(
      {super.key,
      this.schoolId,
      this.newUpdateTime = 0,
      required this.onClasSet});

  final ValueSetter<Clas> onClasSet;
  String? schoolId;
  int newUpdateTime = 0;

  @override
  State<StatefulWidget> createState() {
    return _ClassListWrapState();
  }
}

class _ClassListWrapState extends State<ClassListWrap> {
  late List<Clas> classList = [];
  int? curIndex;
  AppModel appModel = AppModel();
  int lastUpdateTime = 0;

  // ValueSetter<Clas> onClasSet;

  @override
  void initState() {
    loadClasses();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ClassListWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    var needUpdate = widget.newUpdateTime > lastUpdateTime;
    if (needUpdate || oldWidget.schoolId != widget.schoolId) {
      loadClasses();
      lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (classList.isEmpty)
          if (widget.schoolId == null)
            const Text('未选择学校')
          else
            const Text('该学校未设置班级'),
        Wrap(
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
        ),
      ],
    );
  }

  void loadClasses() {
    if (widget.schoolId == null) {
      classList = [];
      setState(() {});
      return;
    }
    appModel.getClasses(schoolId: widget.schoolId).then((list) {
      classList = list;
      // for (int i = 0; i < list.length; i++) {
      //   if (list[i].id == (appModel.userInfo.clas?.id)) {
      //     curIndex = i;
      //     break;
      //   }
      // }
      setState(() {});
    }).catchError((onError) {
      log("load classes 2 error: $onError");
    });
  }
}

class GuwenAppBar extends StatelessWidget {
  const GuwenAppBar(
      {super.key, required this.title, this.alignment = Alignment.center});

  final String title;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: alignment,
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).primaryColor,
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 32, fontFamily: "楷体"),
      ),
    );
  }
}
