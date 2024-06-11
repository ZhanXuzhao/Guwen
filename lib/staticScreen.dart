import 'dart:developer';

import 'package:f05/beans.dart';
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
    "自定义时间",
  ];

  var curTimeClipIndex = 0;

  @override
  Widget build(BuildContext context) {
    // var list =
    return Container(
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
                      if (curTimeClipIndex < 3) {
                        // todo

                        querySearchHistory(DateTime.now(), DateTime.now());
                      } else {
                        // pickTime()
                        onDatePickPressed(context, 1);
                      }
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
                itemCount: 100,
                itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      "search reg -- $index",
                    ))),
          )
        ],
      ),
    );
  }

  //https://api.flutter.dev/flutter/material/showDateRangePicker.html
  onDatePickPressed(BuildContext context, int i) {
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

  void querySearchHistory(DateTime dateTime, DateTime dateTime2) {

  }
}
