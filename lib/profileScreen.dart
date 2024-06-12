import 'dart:math';

import 'package:f05/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<StatefulWidget> {
  late AppModel appModel;

  @override
  void initState() {
    appModel = AppModel();
    // appModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          ElevatedButton(
              onPressed: () {
                appModel.clearCache();
              },
              child: Text("Clear Cache")),
          ElevatedButton(
              onPressed: () {
                appModel.initUser();
              },
              child: Text("init user")),
          ElevatedButton(
              onPressed: () {
                appModel.setUserClass();
              },
              child: Text("setUserClass")),
          ElevatedButton(
              onPressed: () {
                appModel.sendSearchRequest("user test ${Random().nextInt(1000)}");
              },
              child: Text("sendSearchRequest")),
        ],
      ),
    );
  }
}
