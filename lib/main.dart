// ignore_for_file: prefer_const_constructors

import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:f05/models.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'dir_list.dart';

void main() {
  // runApp(const MyApp());
  // runApp(
  //   ChangeNotifierProvider(
  //     create: (context) => FileListModel(),
  //     child: const MyApp(),
  //   ),
  // );

  runApp(
    // ChangeNotifierProvider(
    //   create: (context) => FileListModel(),
    //   child: MaterialApp(
    //     title: 'Material app title',
    //     initialRoute: '/',
    //     routes: {
    //       RouterAddress.homePage: (context) => MyHomePage(title: "ghy",),
    //       '/f': (context) =>  FileListPage(),
    //     },
    //   ),
    // ),

    ChangeNotifierProvider(
      create: (context) => FileListModel(),
      child: MyApp(),
    ),
  );
}

class RouterAddress {
  static const String homePage = '/';
  static const String fileListPage = '/fileListPage';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Title',
      initialRoute: '/',
      routes: {
        RouterAddress.homePage: (context) => MyHomePage(
              title: "古汉语搜索器",
            ),
        RouterAddress.fileListPage: (context) => FileListPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: '古汉语搜索器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static void goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, RouterAddress.homePage, ModalRoute.withName('/'));
  }

  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final myController = TextEditingController();
  var regStr = "";
  var assetsPath = "/Users/zhanxuzhao/Dev/FlutterProjects/f05/assets";
  FileListModel fileListModel = FileListModel();

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
    print("read file: $path");
    if (!path.endsWith('.txt')) {
      return;
    }
    File file = File(path);
    var badLineReg = RegExp('([a-z]|[A-Z])|语料');
    try {
      var count = 0;
      var lineIndex = 0;
      var exp = RegExp(regStr);
      await file
          .openRead()
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .forEach((line) {
        if (count < max) {
          if (exp.hasMatch(line) && !badLineReg.hasMatch(line)) {
            var s1 = basename(file.path).replaceAll(RegExp("\\d|.txt"), "");
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

  List<String> searchData() {
    regStr = myController.text;
    var path = assetsPath;

    // clear pre data

    setState(() {
      outStrList.clear();
    });

    fileListModel.getAll().forEach((element) {
      fullListDir(element);
    });
    return outStrList;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    searchData();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // late Future<List<String>> data;

  @override
  void initState() {
    super.initState();
    searchData();
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
                // shaixuan button
                ElevatedButton(
                  child: const Text('范围'),
                  onPressed: () {
                    FileListPage.launch(context, assetsPath);
                    // Navigator.pushNamed(context, RouterAddress.fileListPage
                    //     ,
                    //     arguments: <String, String>{
                    //       'dirPath': assetsPath,
                    //     }
                    //     );
                  },
                ),
                Container(
                  width: 8,
                ),
                // search button
                ElevatedButton(
                    child: const Text('搜索'), onPressed: onSearchButtonClick),
              ],
            ),
            DataListView(outStrList: outStrList),
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

class DataListView extends StatelessWidget {
  const DataListView({
    super.key,
    required this.outStrList,
  });

  final List<String> outStrList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: outStrList.length,
            itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.all(4),
                child: Text("${outStrList[index]}"))));
  }
}
