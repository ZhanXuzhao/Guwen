import 'dart:developer';

import 'package:f05/beans.dart';
import 'package:f05/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'profileScreen.dart';

class StaticScreen extends StatefulWidget {
  const StaticScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StaticScreenState();
  }
}

class _StaticScreenState extends State<StatefulWidget> {
  late AppModel appModel;
  var timeClipTexts = [
    "1天",
    "7天",
    "30天",
    "全部",
    "自定义时间",
  ];
  DateTime curStarDate = DateTime.now();
  DateTime curEndDate = DateTime.now();
  var curTimeClipIndex = 0;
  late List<Clas> classList = [];

  var curClassChipIndex = 0;
  String? curClassId;
  Map<String, int> searchMap = {};
  List<String> searchHistory = [];

  @override
  void initState() {
    appModel = AppModel();
    super.initState();
    loadClasses();
    onDateTabClick(0, context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GuwenAppBar(title: "数据统计"),
        Expanded(
            child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("选择统计时间范围："),
              const SizedBox(
                height: 8,
              ),
              // date duration chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: List<Widget>.generate(
                  timeClipTexts.length,
                  (int index) {
                    return ChoiceChip(
                      label: Text(timeClipTexts[index]),
                      selected: curTimeClipIndex == index,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            curTimeClipIndex = index;
                          }
                          onDateTabClick(curTimeClipIndex, context);
                        });
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(
                height: 8,
              ),

              const Text("选择班级："),

              const SizedBox(
                height: 8,
              ),
              // class chips
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
                          curClassId = classList[curClassChipIndex].id;
                          querySearchHistory(curStarDate, curEndDate);
                        }
                        setState(() {});
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(
                height: 8,
              ),

              // ui search list
              const Text("搜索记录统计："),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ListView.builder(
                          // fix bug Cannot hit test a render box that has never been laid out.
                          shrinkWrap: true,
                          itemCount: searchMap.entries.length,
                          itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                "${searchMap.keys.elementAt(index)} —— "
                                "${searchMap.values.elementAt(index)} 次",
                              ))),
                    ),
                    Positioned(
                      bottom: 32,
                      right: 32,
                      child: FloatingActionButton(
                        onPressed: () {
                          AppModel.instance
                              .pickDirAndExportData(searchHistory, 1, (v) {})
                              .then((v) {
                            showMessage('导出成功');
                          });
                        },
                        tooltip: '导出',
                        child: const Icon(Icons.download),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void onDateTabClick(int index, BuildContext context) {
    if (index < 3) {
      late DateTime start;
      // DateTime dateTime = DateTime.now().add(Duration(days: 30));

      if (index == 0) {
        start = DateTime.now().subtract(const Duration(days: 1));
      } else if (index == 1) {
        start = DateTime.now().subtract(const Duration(days: 7));
      } else {
        if (kDebugMode) {
          start = DateTime.now().subtract(const Duration(minutes: 10));
        } else {
          start = DateTime.now().subtract(const Duration(days: 30));
        }
      }
      querySearchHistory(start, DateTime.now());
    } else if (index == 3) {
      querySearchHistoryAll();
    } else {
      // pickTime()
      onDatePickPressed(context);
    }
  }

  //https://api.flutter.dev/flutter/material/showDateRangePicker.html
  onDatePickPressed(BuildContext context) {
    showDateRangePicker(
            context: context,
            firstDate: DateTime.parse('2024-01-01'),
            lastDate: DateTime.now())
        .then((DateTimeRange? range) {
      log("date time range:  ${range!.start.toString()} - ${range.end.toString()} duration: ${range.duration.inDays} 天");
    }).catchError((error) {
      log("pick date range failed: $error");
    });
  }

  void querySearchHistory(DateTime start, DateTime end) {
    curStarDate = start;
    curEndDate = end;
    appModel.getSearchHistory(start, end, curClassId).then((map) {
      searchMap = map;
      searchHistory.clear();
      for (var et in searchMap.entries) {
        searchHistory.add('${et.key} —— ${et.value}');
      }
      setState(() {});
    });
  }

  void querySearchHistoryAll() {
    querySearchHistory(
        DateTime.now().subtract(const Duration(days: 3000)), DateTime.now());
  }

  void updateUI() {
    setState(() {});
  }

  void loadClasses() {
    appModel.getClasses().then((list) {
      classList = list;
      var last = Clas();
      last.name = "全部班级";
      last.id = "";
      classList.add(last);
      // curClassId=classList[curClassChipIndex].id;
      curClassChipIndex = classList.length - 1;
      updateUI();
    }).catchError((onError) {
      log("load classes error: $onError");
    });
  }
}
