// ignore_for_file: prefer_const_constructors

import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Title',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ' 古汉语搜索器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  var regStr = "";
  var assetsPath = "/Users/zhanxuzhao/Dev/FlutterProjects/f05/assets";

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void onSearchButtonClick() {
    searchData();
  }

  var sub;

  void loadData(String path, {int max = 10000}) async {
    var count = 0;
    var lineIndex = 0;
    var exp = RegExp(regStr);
    print(path);
    File file = File(path);
    try {
      await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) {
      if (count < max) {
        if (exp.hasMatch(line)) {
          var s1 = basename(file.path).replaceAll(RegExp("\\d|.txt"),"");
          var fileName = s1;
          // format string
          var s = "$line —— $fileName";
          outStrList.add(s);
          print(s);
          count++;
        }
        lineIndex++;
      } else {
        sub.cancel();
        print("cancel");
      }
    });
    setState(() {});
    } catch (e) {
      print("error ${e.toString()} @file:$path");
    }
    
  }

  void searchData() {
    regStr = myController.text;
    var path = assetsPath;

    // clear pre data

    setState(() {
      outStrList.clear();
    });
    fullListDir(path);
  }

  List<String> outStrList = <String>[];

  void fullListDir(String path) async {
    print("fullListDir $path");
    var f = File(path);
    if (!f.existsSync()) {
      print('file $f NOT exist');
    }
    if (f.statSync().type == FileSystemEntityType.file) {
      loadData(path);
    } else {
      // load dir
      var dir = Directory(path);
      List<String> pList = <String>[];
      // dir.list().forEach((element) {
      //   pList.add(element.path);
      // });

      await for (var entity in dir.list(recursive: false, followLinks: false)) {
        // print(entity.path);
        pList.add(entity.path);
      }

      pList.sort();
      pList.forEach((element) {
        fullListDir(element);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // homepage body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '请输入搜索正则表达式',
                    ),
                    controller: myController,
                  ),
                ),
                Container(
                  width: 8,
                ),
                ElevatedButton(
                  child: const Text('范围'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DirListPage(dirPath: assetsPath)),
                    );
                  },
                ),
                Container(
                  width: 8,
                ),
                ElevatedButton(
                    child: const Text('搜索'), onPressed: onSearchButtonClick),
              ],
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: outStrList.length,
                    itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("${outStrList[index]}")))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onSearchButtonClick,
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class FileData {
  final String name;
  final String path;
  final bool isFile;

  const FileData(this.name, this.path, this.isFile);
}

class DirListPage extends StatelessWidget {
  // Requiring the list of todos.
  DirListPage({super.key, required this.dirPath});

  final String dirPath;
  var fileList = <FileData>[];

  @override
  Widget build(BuildContext context) {
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
          // Navigator.push(
          //   context,
          //   MyApp(),
          // );
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
  List<String> selectedPathList = <String>[];

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
              // trailing: Icon(selectedPathList.contains(fileList[index].path)
              //     ? Icons.check_box
              //     : Icons.check_box_outline_blank),
              title: Text(fileList[index].name),
              onLongPress: () {
                if (!fileList[index].isFile) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DirListPage(dirPath: fileList[index].path)));
                }
              },
              onTap: () {
                // if (selectedPathList.contains(path)) {
                //   selectedPathList.remove(path);
                // } else {
                //   selectedPathList.add(path);
                // }
                // setState(() {});
                if (!fileList[index].isFile) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DirListPage(dirPath: fileList[index].path)));
                }
              },
            ),
            Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 32),
                child: Checkbox(
                  value: selectedPathList.contains(fileList[index].path),
                  onChanged: (value) {
                    if (value == true) {
                      selectedPathList.add(path);
                    } else {
                      selectedPathList.remove(path);
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
