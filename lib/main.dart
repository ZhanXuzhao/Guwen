// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

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
        '/': (context) => MyHomePage(
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

  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// home page state
class _MyHomePageState extends State<MyHomePage> {
  final regController = TextEditingController();
  final exPathController = TextEditingController();

  var regStr = "";
  var assetsPath = "/Users/zhanxuzhao/Dev/FlutterProjects/f05/assets";
  FileListModel fileListModel = FileListModel();
  var searchProgress = 0;
  var searchTotalFiles = 0;
  var searchStatus = "";
  var searchedTextList = <String>[];

  RegExp badLineReg = RegExp('([a-z]|[A-Z])|语料');
  late RegExp exp;

  @override
  void dispose() {
    regController.dispose();
    exPathController.dispose();
    super.dispose();
  }

  void onSearchButtonClick() {
    searchData();
  }

  Future<int> readFile(String path) async {
    print("read file: $path");
    File file = File(path);
    var lineIndex = 0;
    Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(LineSplitter()); // Convert stream to individual lines.
    try {
      await for (var line in lines) {
        // print('$line: ${line.length} characters');

        if (exp.hasMatch(line) && !badLineReg.hasMatch(line)) {
          print("reg $regStr ${exp.hasMatch(line)} $lineIndex");
          var fileName = basename(file.path).replaceAll(RegExp("\\d|.txt"), "");
          var s = "$line —— $fileName";
          searchedTextList.add(s);
        }
        lineIndex++;
      }
      print('File is now closed.');
      // updateUI();
    } catch (e) {
      print('Error: $e');
    }
    return 1;
  }

  void updateUI() {
    print("update ui");
    setState(() {});
  }

  Future<void> searchData() async {
    getReg();
    var startTime = DateTime.now().millisecondsSinceEpoch;
    searchStatus = "";
    var path = assetsPath;
    searchedTextList.clear();
    // updateUI();
    fileListModel.add(exPathController.text);
    var txtList = filterTextFiles(fileListModel.getAllTxtFile());
    searchTotalFiles = txtList.length;
    searchProgress = 0;
    for (var element in txtList) {
      var result = await readFile(element);
      searchProgress++;

      // cal time cost
      var endTime = DateTime.now().millisecondsSinceEpoch;
      double timeCost = 1.0 * (endTime - startTime) / 1000;
      searchStatus = "耗时: $timeCost s";

      updateUI();
    }

    print(
        "search finished  $searchTotalFiles files get $searchProgress sentence");
    updateUI();
  }

  void getReg() {
    regStr = regController.text;
    if (regStr == "") {
      print("reg empty");
      regStr = ".*";
    }
    exp = RegExp(regStr);
  }

  @override
  void initState() {
    super.initState();
    searchData();
  }

  @override
  Widget build(BuildContext context) {
    print("ui build");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      // homepage body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // ex path row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '输入外部路径（可选）',
                    ),
                    controller: exPathController,
                  ),
                ),

                Container(
                  width: 8,
                ),
                // shaixuan button
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    child: const Text('选择内部文件'),
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
                )
              ],
            ),
            Container(
              height: 8,
            ),
            // regex row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '请输入搜索正则表达式，如: 先.*后',
                    ),
                    controller: regController,
                  ),
                ),

                Container(
                  width: 8,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                      onPressed: onSearchButtonClick, child: const Text('搜索')),
                )
                // search button
              ],
            ),
            Container(
              height: 8,
            ),
            // seach info row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  child: Text("进度 $searchProgress/$searchTotalFiles"),
                ),
                SizedBox(
                  width: 100,
                  child: Text("$searchStatus"),
                ),
                SizedBox(
                  width: 150,
                  child: Text("总共找到 ${searchedTextList.length} 条数据"),

                  // child: Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Text("总共找到 ${searchedTextList.length} 条数据"),
                  // ),
                ),
              ],
            ),

            // date list
            DataListView(textList: searchedTextList),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: updateUI,
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DataListView extends StatelessWidget {
  const DataListView({
    super.key,
    required this.textList,
  });

  final List<String> textList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: textList.length,
            itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.all(4),
                child: Text("${textList[index]}"))));
  }
}
