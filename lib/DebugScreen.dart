import 'dart:math' as math;

import 'package:f05/models.dart';
import 'package:flutter/material.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DebugScreenState();
  }
}

class _DebugScreenState extends State<StatefulWidget> {
  late AppModel appModel;

  @override
  void initState() {
    appModel = AppModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
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
                    appModel.updateAllSchoolClassCount();
                  },
                  child: const Text("updateSchoolClassCount")),
              ElevatedButton(
                  onPressed: () {
                    appModel.initUser();
                  },
                  child: const Text("init user")),
              ElevatedButton(
                  onPressed: () {
                    appModel.login('649912323@qq.com', '123');
                  },
                  child: const Text("登录 6499")),
              ElevatedButton(
                  onPressed: () {
                    appModel.logout();
                  },
                  child: const Text("logout")),
              ElevatedButton(
                  onPressed: () {
                    appModel.sendSearchRequest(
                        "user test ${math.Random().nextInt(1000)}");
                  },
                  child: const Text("sendSearchRequest")),
              ElevatedButton(
                  onPressed: () {
                    appModel.createStaffApplications(0);
                  },
                  child: const Text("createStaffApplications")),
              ElevatedButton(
                  onPressed: () {
                    appModel.exportData(['hi'],(p){});
                  },
                  child: const Text("export")),
            ],
          ),
        ],
      ),
    );
  }
}
