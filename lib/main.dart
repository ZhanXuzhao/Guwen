// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:f05/models.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:intl/intl.dart';
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
      create: (context) => AppModel(),
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
              title: "汉语历时搜索系统",
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

// home page state
class _MyHomePageState extends State<MyHomePage> {
  late BuildContext mContext;
  final regController = TextEditingController();
  final extralPathController = TextEditingController();
  final exportPathController = TextEditingController();

  var regStr = "";
  var assetsPath = "/Users/zhanxuzhao/Dev/FlutterProjects/f05/assets/guwen";
  AppModel appModel = AppModel();
  var searchProgress = 0;
  var searchProgressText = "";
  var searchTotalFiles = 0;
  var searchStatus = "";
  var searchedTextList = <String>[];
  var searchResultStaticText = "";
  var totalLineCount = 0;

  RegExp badLineReg = RegExp('([a-z]|[A-Z])|语料');
  late RegExp exp;

  @override
  void dispose() {
    regController.dispose();
    extralPathController.dispose();
    exportPathController.dispose();
    super.dispose();
  }

  void onSearchButtonClick() {
    searchData();
  }

  Future<void> searchData() async {
    getReg();
    var startTime = DateTime.now().millisecondsSinceEpoch;
    searchStatus = "";
    searchedTextList.clear();

    // ex path
    var txtList = filterTextFiles(appModel.getAllTxtFile());

    searchTotalFiles = txtList.length;
    searchProgress = 0;
    for (var element in txtList) {
      // var result = await readFile(element);
      var result = await readFile(element);

      searchProgress++;

      // cal time cost
      var endTime = DateTime.now().millisecondsSinceEpoch;
      double timeCost = 1.0 * (endTime - startTime) / 1000;
      searchStatus = "耗时: $timeCost s";
      var percent = NumberFormat("###.#", "en_US")
          .format(100 * searchProgress / searchTotalFiles);
      searchProgressText =
          "文件读取进度: $searchProgress/$searchTotalFiles   $percent%";
      searchResultStaticText =
          "匹配句数: ${searchedTextList.length} \t 总句数: $totalLineCount";
      updateUI();
    }

    print(
        "search finished  $searchTotalFiles files get $searchProgress sentence");
    updateUI();
  }

  Future<int> readFile(String path) async {
    print("read file: $path");
    File file = File(path);
    Stream<String> lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(LineSplitter()); // Convert stream to individual lines.
    try {
      await for (var longLine in lines) {
        var subLines = longLine.split(RegExp('。'));
        for (var line in subLines) {
          bool isMatch = exp.hasMatch(line) && !badLineReg.hasMatch(line);
          // bool isMatch = exp.hasMatch(line);

          if (isMatch) {
            // print("reg $regStr ${exp.hasMatch(line)} $lineIndex");
            var fileName = getFileDirLocation(file.path);
            // basename(file.path).replaceAll(RegExp("\\d|.txt"), "");
            var s = "$line —— $fileName";
            searchedTextList.add(s);
            print('line: $line');
          }
          totalLineCount++;
        }
      }
      print('File is now closed.');
      // updateUI();
    } catch (e) {
      print('Error: $e');
    }
    return 1;
  }

  String getFileDirLocation(String filePath) {
    return filePath
        .replaceAll(assetsPath, "")
        .replaceAll(extralPathController.text, "")
        .replaceAll(RegExp("\\d|.txt"), "");
  }

  void showMessage(String msg) {
    var snackBar = SnackBar(
      content: Text(msg),
    );
    ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
  }

  void updateUI() {
    print("update ui");
    setState(() {});
  }

  void getReg() {
    regStr = regController.text;
    if (regStr == "") {
      regStr = ".*";
    } else {
      appModel.regStr = regStr;
    }
    exp = RegExp(regStr);
    var rs = regStr.replaceAll(RegExp('[^\u4e00-\u9fa5]+'), ",");
    // var hanziList = rs.split(RegExp(',+'));
    var hanziList = rs.split(',');
    appModel.highlightWords = hanziList;
  }

  void exportSearchResult() async {
    var path = exportPathController.text;
    if (path.isEmpty) {
      showMessage("请指定导出路径");
      return;
    }
    appModel.exportPath = path;
    var file = File("$path/${getExportFileName()}.txt");
    file.create(recursive: true);
    print('export file $file');
    for (var line in searchedTextList) {
      print('write $line');
      file.writeAsStringSync("$line\r", mode: FileMode.append, encoding: utf8);
      // file.writeAsStringSync('\r', mode: FileMode.append, encoding: utf8);
    }

    print('export success');
    showMessage("导出成功");
  }

  String getExportFileName() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    searchData();
  }

  //page build
  @override
  Widget build(BuildContext context) {
    mContext = context;
    regController.text = appModel.regStr == ".*" ? "" : appModel.regStr;
    extralPathController.text = appModel.extralPath;
    exportPathController.text = appModel.exportPath;
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
            // 外部路径
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '输入外部路径（可选）',
                    ),
                    controller: extralPathController,
                    onChanged: (value) {
                      appModel.extralPath = value;
                      print("onChange $value");
                    },
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
                    },
                  ),
                )
              ],
            ),

            // 正则表达式
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
                    onChanged: (value) {
                      appModel.regStr = value;
                      print("onChange $value");
                    },
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

            // 导出路径
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
                      hintText: '导出路径',
                    ),
                    onChanged: (value) {
                      appModel.regStr = value;
                      print("onChange $value");
                    },
                    controller: exportPathController,
                  ),
                ),

                Container(
                  width: 8,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                      onPressed: exportSearchResult, child: const Text('导出')),
                )
                // search button
              ],
            ),

            Container(
              height: 8,
            ),
            // seach info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(searchProgressText),
                Text(searchStatus),
                Text(searchResultStaticText),
              ],
            ),

            // date list
            DataListView(textList: searchedTextList),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: updateUI,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.search),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// list view
class DataListView extends StatelessWidget {
  const DataListView({
    super.key,
    required this.textList,
  });

  final List<String> textList;

  @override
  Widget build(BuildContext context) {
    print("build text list view1");
    var highlightTextStyle = TextStyle(
      // You can set the general style, like a Text()
      // fontSize: 20.0,
      color: Colors.red,
    );

    Map<String, HighlightedWord> hightWords = {
      "----": HighlightedWord(textStyle: highlightTextStyle)
    };
    for (String w in AppModel().highlightWords) {
      if(w.isEmpty){
        continue;
      }
      var entry = MapEntry(
          w,
          HighlightedWord(
            onTap: () {
              print("tap $w");
            },
            textStyle: highlightTextStyle,
          ));
      hightWords.addEntries([entry]);
    }
    print("build text list view2");
    return Expanded(
        child: ListView.builder(
            itemCount: textList.length,
            itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.all(4),
                child: TextHighlight(
                  text: textList[index],
                  words: hightWords,
                ))));

    // return Expanded(
    //     child: ListView.builder(
    //         itemCount: textList.length,
    //         itemBuilder: (context, index) => Padding(
    //             padding: EdgeInsets.all(4),
    //             child: Text(
    //               textList[index],
    //             ))));


  }
}
