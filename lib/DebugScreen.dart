import 'dart:math' as math;

import 'package:f05/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DebugScreen extends StatefulWidget {
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
                    appModel.clearCache();
                  },
                  child: const Text("Clear Cache")),
              ElevatedButton(
                  onPressed: () {
                    appModel.initUser();
                  },
                  child: const Text("init user")),
              // ElevatedButton(
              //     onPressed: () {
              //       appModel.initUserClass();
              //     },
              //     child: const Text("setUserClass")),
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
    );
  }
}
