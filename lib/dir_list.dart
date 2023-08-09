import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:f05/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'models.dart';

class FileListPageArg {
  final String path;

  FileListPageArg(this.path);
}

class FileListPage extends StatelessWidget {
  // Requiring the list of todos.
  FileListPage({super.key});

  String dirPath = "";
  var fileList = <FileData>[];

  static void launch(BuildContext context, String path) {
    Navigator.pushNamed(context, RouterAddress.fileListPage,
        arguments: FileListPageArg(path));
  }

  @override
  Widget build(BuildContext context) {
    var arg = ModalRoute.of(context)!.settings.arguments as FileListPageArg;
    dirPath = arg.path;
    if (dirPath == null || dirPath.isEmpty) {
      print('error, dirPath not set');
      // throw Exception('error, dirPath not set');
    }
    var dir = Directory(dirPath);
    var subs = <String>[];
    // dir.listSync().forEach(
    //   (element) {
    //   subs.add(element.path);
    // });

    dir.listSync().forEach((element) {
      var subPath = element.path;
      subs.add(subPath);
      var name = basename(subPath);
      var fileData = FileData(basename(subPath), subPath,
          File(subPath).statSync().type == FileSystemEntityType.file);
      fileList.add(fileData);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dir List'),
      ),
      body: Column(
        children: <Widget>[
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   child: const Text('Go back!'),
          // ),
          Expanded(child: DirListView(fileList: fileList))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //go home
          // Navigator.pushNamedAndRemoveUntil(
          //   context,
          //   RouterAddress.homePage,ModalRoute.withName('/')
          // );
          MyHomePage.goHome(context);
        },
        tooltip: 'confirm',
        child: const Icon(Icons.check),
      ),
    );
  }
}

class DirListView extends StatefulWidget {
  const DirListView({
    super.key,
    required this.fileList,
  });

  final List<FileData> fileList;

  @override
  State<StatefulWidget> createState() => DirListViewState(fileList: fileList);
}

class DirListViewState extends State<StatefulWidget> {
  DirListViewState({
    required this.fileList,
  });
  final List<FileData> fileList;
  // List<String> selectedPathList = <String>[];
  late FileListModel fileListModel;

  @override
  Widget build(BuildContext context) {
    fileListModel = Provider.of<FileListModel>(context, listen: false);

    return ListView.builder(
      itemCount: fileList.length,
      itemBuilder: (context, index) {
        var path = fileList[index].path;
        return Stack(
          children: [
            ListTile(
              leading: Icon(
                  fileList[index].isFile ? Icons.text_snippet : Icons.folder),
              title: Text(fileList[index].name),
              onTap: () {
                if (!fileList[index].isFile) {
                  FileListPage.launch(context, fileList[index].path);
                }
              },
            ),
            Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 32),
                child: Checkbox(
                  value: fileListModel.contains(fileList[index].path),
                  onChanged: (value) {
                    if (value == true) {
                      fileListModel.add(path);
                    } else {
                      fileListModel.remove(path);
                    }
                    setState(() {});
                  },
                ))
          ],
        );
      },
    );
  }
}
