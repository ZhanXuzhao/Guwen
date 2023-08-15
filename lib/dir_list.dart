// ignore_for_file: unused_import, avoid_print

import 'dart:io';

import 'package:f05/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'models.dart';

class FileListPageArg {
  final String path;

  FileListPageArg(this.path);
}

// file list page
// ignore: must_be_immutable
class FileListPage extends StatefulWidget {
  // Requiring the list of todos.
  FileListPage(
      {super.key, required this.dirPath, this.showAddMoreWidget = false});
  String dirPath;
  bool showAddMoreWidget = false;

  static void launch(
      BuildContext context, String path, bool showAddMoreWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FileListPage(dirPath: path, showAddMoreWidget: showAddMoreWidget),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _FileListPage(
        dirPath: dirPath, showAddMoreWidget: showAddMoreWidget);
  }
}

class _FileListPage extends State<FileListPage> {
  _FileListPage({required this.dirPath, this.showAddMoreWidget = false});
  bool showAddMoreWidget = false;
  String dirPath = "";
  var pathList = <String>[];
  var appModel = AppModel();
  var extralPathController = TextEditingController();

  void addDirContent(String dirPath) {
    if (!isDir(dirPath)) {
      print("invalid dir path: $dirPath");
      return;
    }
    listDir(dirPath).forEach((path) {
      if (!pathList.contains(path)) {
        if (isDir(path)) {
          pathList.add(path);
        } else {
          if (isTxt(path)) {
            pathList.add(path);
          } else {
            print("not txt: $path");
          }
        }
      }
    });
    updateUI();
  }

  void addExternalDir(String dirPath) {
    if (!isDir(dirPath)) {
      print("invalid dir path: $dirPath");
      return;
    }
    appModel.addExternalDir(dirPath);
    pathList.add(dirPath);
    updateUI();
  }

  void updateUI() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    addDirContent(dirPath);
    if (showAddMoreWidget) {
      for (var path in appModel.externalDirs) {
        addExternalDir(path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择文件'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          children: [
            // 追加数据路径
            if (showAddMoreWidget)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '语料路经',
                      ),
                      controller: extralPathController,
                      // onChanged: (value) {
                      //   appModel.setYuliaoPath(value);
                      //   print("onChange $value");
                      // },
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  ElevatedButton(
                    child: const Text('追加数据'),
                    onPressed: () {
                      addExternalDir(extralPathController.text);
                    },
                  ),
                ],
              ),

            Expanded(
                child: ListView.builder(
              itemCount: pathList.length,
              itemBuilder: (context, index) {
                var path = pathList[index];
                var isF = isFile(path);
                return Row(
                  children: [
                    // icon and title
                    Expanded(
                        child: ListTile(
                      leading: Icon(isF ? Icons.text_snippet : Icons.folder),
                      title: Text(basename(path)),
                      onTap: () {
                        if (!isF) {
                          FileListPage.launch(context, pathList[index], false);
                        }
                      },
                    )),

                    Checkbox(
                      value: appModel.contains(path),
                      onChanged: (value) {
                        if (value == true) {
                          appModel.add(path);
                        } else {
                          appModel.remove(path);
                        }
                        updateUI();
                      },
                    ),

                    Container(
                      width: 16,
                    )
                  ],
                );
              },
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MyHomePage.goHome(context);
        },
        tooltip: 'confirm',
        child: const Icon(Icons.check),
      ),
    );
  }
}
