import 'dart:developer';

import 'package:f05/beans.dart';
import 'package:f05/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leancloud_storage/leancloud.dart';

class StaticScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StaticScreenState();
  }
}

class _StaticScreenState extends State<StatefulWidget> {
  var timeClipTexts = [
    "1天",
    "7天",
    "30天",
    "全部",
    "自定义时间",
  ];

  var curTimeClipIndex = 0;
  late AppModel appModel;
  Map<String, int> searchMap = {};

  @override
  void initState() {
    appModel = AppModel();
    super.initState();
    onDateTabClick(0, context);
  }

  @override
  Widget build(BuildContext context) {
    var container = Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
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

          // ui search list
          Expanded(
            child: ListView.builder(
                // fix bug Cannot hit test a render box that has never been laid out.
                shrinkWrap: true,
                itemCount: searchMap.entries.length,
                itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      "${searchMap.keys.elementAt(index)} ——"
                      " ${searchMap.values.elementAt(index)} 次",
                    ))),
          )
        ],
      ),
    );
    return container;
  }

  void onDateTabClick(int index, BuildContext context) {
    if (index < 3) {
      late DateTime start;
      // DateTime dateTime = DateTime.now().add(Duration(days: 30));

      if (index == 0) {
        start = DateTime.now().subtract(Duration(days: 1));
      } else if (index == 1) {
        start = DateTime.now().subtract(Duration(days: 7));
      } else {
        start = DateTime.now().subtract(Duration(days: 30));
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
    appModel.getSearchHistory(start, end).then((map) {
      searchMap = map;
      setState(() {});
    });
  }

  void querySearchHistoryAll() {
    querySearchHistory(DateTime.now().subtract(const Duration(days: 3000)), DateTime.now());
  }
}
