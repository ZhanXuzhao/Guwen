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
    if (dirPath.isEmpty) {
      print('error, dirPath not set');
      // throw Exception('error, dirPath not set');
    }
    var subs = <String>[];

    listDir(dirPath).forEach((path) {
      File file = File(path);

      subs.add(path);
      var fileData = FileData(basename(path), path,
          File(path).statSync().type == FileSystemEntityType.file);

      if (file.statSync().type == FileSystemEntityType.file) {
        if (path.endsWith('.txt') || path.endsWith('.TXT')) {
          fileList.add(fileData);
          
        } else {
          print('non txt file: $path');
        }
      } else {
        fileList.add(fileData);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择文件'),
      ),
      body: Column(
        children: <Widget>[Expanded(child: DirListView(fileList: fileList))],
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

class DirListView extends StatefulWidget {
  const DirListView({
    super.key,
    required this.fileList,
  });

  final List<FileData> fileList;

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => DirListViewState(fileList: fileList);
}

class DirListViewState extends State<StatefulWidget> {
  DirListViewState({
    required this.fileList,
  });
  final List<FileData> fileList;
  // List<String> selectedPathList = <String>[];
  late AppModel appModel = AppModel();

  @override
  Widget build(BuildContext context) {
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
                margin: const EdgeInsets.only(right: 32),
                child: Checkbox(
                  value: appModel.contains(fileList[index].path),
                  onChanged: (value) {
                    if (value == true) {
                      appModel.add(path);
                    } else {
                      appModel.remove(path);
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
