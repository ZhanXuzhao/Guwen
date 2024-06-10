// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:f05/models.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'dir_list.dart';

void main() {
  // init app module
  AppModel();

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
              title: "汉语溯源",
            ),
        RouterAddress.fileListPage: (context) => FileListPage(dirPath: ""),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        fontFamily: Platform.isWindows ? "微软雅黑" : null,
      ),
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
  BuildContext? mContext;
  final regController = TextEditingController();
  final extralPathController = TextEditingController();
  final exportPathController = TextEditingController();

  var regStr = "";

  // var assetsPath = TextFilePath;
  AppModel appModel = AppModel();
  var searchedTextList = <String>[];
  var searchProgress = 0;
  var searchTotalFiles = 0;
  var totalLineCount = 0;
  bool showProgressUI = false;
  var searchProgressText = "";
  var searchResultStaticText = "";
  var searchDurationText = "";
  var exampleSearchText = ['之', '之.者', '之.*者', '之.{1,4}者'];

  RegExp badLineReg = RegExp('([a-z]|[A-Z])|语料');
  late RegExp exp;

  @override
  void dispose() {
    regController.dispose();
    extralPathController.dispose();
    exportPathController.dispose();
    super.dispose();
  }

  Future<void> searchData() async {
    var hasReg = processSearchReg();
    if (!hasReg) {
      clearPreSearchData();
      showProgressUI = false;
      updateUI();
      showMessage("请输入搜索条件");
      return;
    }
    var startTime = DateTime.now().millisecondsSinceEpoch;
    clearPreSearchData();

    // ex path
    var txtList = filterTextFiles(appModel.getAllTxtFile());

    searchTotalFiles = txtList.length;
    searchProgress = 0;
    for (var element in txtList) {
      var readResult = await readFile(element);
      print(readResult);

      searchProgress++;

      // 搜索进度 cal time cost
      showProgressUI = true;
      var endTime = DateTime.now().millisecondsSinceEpoch;
      double timeCost = 1.0 * (endTime - startTime) / 1000;
      searchDurationText = "耗时: $timeCost s";
      // var percent = NumberFormat("###.#", "en_US")
      //     .format(100 * searchProgress / searchTotalFiles);
      searchProgressText = "搜索进度: $searchProgress/$searchTotalFiles";
      searchResultStaticText =
          "匹配句数: ${searchedTextList.length} \t 总句数: $totalLineCount";

      updateUI();
    }

    print(
        "search finished  $searchTotalFiles files get $searchProgress sentence");
    updateUI();
    showMessage("搜索完成");
  }

  void clearPreSearchData() {
    searchDurationText = "";
    searchedTextList.clear();
  }

  Future<String> readFile(String path) async {
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
            // print('line: $line');
          }
          totalLineCount++;
        }
      }
      print('File is now closed.');
      // updateUI();
    } catch (e) {
      print('Error: $e');
      return "fail: $e";
    }
    return "success";
  }

  String getFileDirLocation(String filePath) {
    for (var rootPath in appModel.externalDirs) {
      filePath = filePath.replaceAll(rootPath, "");
    }
    return filePath.replaceAll(RegExp("\\d|.txt"), "");
  }

  void showMessage(String msg) {
    var snackBar = SnackBar(
      content: Text(msg),
    );
    if (mContext == null) {
      print('mContext is null');
    } else {
      ScaffoldMessenger.of(mContext!).showSnackBar(snackBar);
    }
  }

  void updateUI() {
    print("update ui");
    setState(() {});
  }

  bool processSearchReg() {
    regStr = regController.text;
    appModel.setRegStr(regStr);
    if (regStr == "") {
      // regStr = ".*";
      print('no search regex');
      return false;
    } else {
      // appModel.setRegStr(regStr);
    }
    exp = RegExp(regStr);
    var rs = regStr.replaceAll(RegExp('[^\u4e00-\u9fa5]+'), ",");
    // var hanziList = rs.split(RegExp(',+'));
    var hanziList = rs.split(',');
    appModel.highlightWords = hanziList;
    return true;
  }

  void exportSearchResult() async {
    var dp = (await getApplicationDocumentsDirectory()).path;
    var path = '$dp\\古汉语搜索结果';
    var dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // appModel.setExportPath(path);
    var file = File("$path/${getExportFileName()}.txt");
    file.create(recursive: true);
    print('export file $file');
    for (var line in searchedTextList) {
      // print('write $line');
      file.writeAsStringSync("$line\r", mode: FileMode.append, encoding: utf8);
      // file.writeAsStringSync('\r', mode: FileMode.append, encoding: utf8);
    }

    print('export success');
    showMessage("导出成功 $path");
  }

  String getExportFileName() {
    var timeStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    var hws = appModel.highlightWords.join("_");

    var s = "${timeStr}_$hws";
    return s;
  }

  @override
  void initState() {
    super.initState();
    print('main init state');
    print('curSearchTab: $curSearchTab');
    curSearchTab=appModel.curYuliaoType;
    print('curSearchTab update: $curSearchTab');

    appModel.initSp().then((onValue) {
      var rs = appModel.getRegStr();
      regController.text = rs == ".*" ? "" : rs;
      extralPathController.text = appModel.getYuliaoPath();
      exportPathController.text = appModel.getExportPathStr();
      appModel.initYuliaoType();
    });
    // searchData();
  }

  int? curSearchTab = 0;
  // var searchTabs = ["现代汉语", "近代汉语", "古汉语", "指定文献"];
  var searchTabs = ["古代汉语", "近代报刊", "现代汉语","外部文献", "指定文献"];

  //page build
  @override
  Widget build(BuildContext context) {
    mContext = context;

    print("ui build");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 32,
            fontFamily: "楷体"),
        automaticallyImplyLeading: false,
      ),
      // homepage body
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                      hintText: '输入搜索正则表达式，如: 之.*者',
                    ),
                    onChanged: (value) {
                      // appModel.setRegStr(value);
                      print("onChange $value");
                    },
                    controller: regController,
                  ),
                ),
                // Container(
                //   width: 8,
                // ),
                // ElevatedButton(
                //   child: const Text('选择搜索范围'),
                //   onPressed: () {
                //     FileListPage.launch(context, textFilePath, true);
                //   },
                // ),

                Container(
                  width: 8,
                ),
                ElevatedButton(onPressed: searchData, child: const Text('搜索')),

                // search button
              ],
            ),

            Container(
              height: 8,
            ),

            // search tabs 现代汉语、近代汉语、古汉语、指定文献
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.start,
              children: List<Widget>.generate(
                searchTabs.length,
                (int index) {
                  return ChoiceChip(
                    label: Text(searchTabs[index]),
                    selected: curSearchTab == index,
                    onSelected: (bool selected) {
                      setState(() {
                        curSearchTab = selected ? index : curSearchTab;
                        appModel.setYuliaoType(index);
                        if (curSearchTab == searchTabs.length - 1) {
                          FileListPage.launch(context, textFilePath, true);
                        }
                      });
                    },
                  );
                },
              ).toList(),
            ),


            Container(
              height: 8,
            ),

            // example 示例
            if (!showProgressUI)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "搜索说明：",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Text("a..b 匹配a、b间有2个任意字符;"
                      "\na.*b 匹配a、b间有任意个字符;"
                      "\na.{m,n}b 匹配a、b间有m-n个字符;"
                      "\n更多搜索语法可以百度正则表达式进行了解;"),
                  Text(
                    "示例（可点击）：",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Container(
                    height: 8,
                  ),
                  Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: List<Widget>.generate(exampleSearchText.length,
                        (int index) {
                      // return Text(exampleSearchText[index]);
                      return ActionChip(
                        label: Text(exampleSearchText[index]),
                        onPressed: () {
                          regController.text = exampleSearchText[index];
                        },
                      );
                    }),
                  )
                ],
              ),

            // search progress row
            if (showProgressUI)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(searchProgressText),
                  Text(searchDurationText),
                  Text(searchResultStaticText),
                ],
              ),

            // 搜索结果 date list
            DataListView(textList: searchedTextList),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: exportSearchResult,
        tooltip: '下载',
        child: const Icon(Icons.download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
      "————": HighlightedWord(textStyle: highlightTextStyle)
    };
    for (String w in AppModel().highlightWords) {
      if (w.isEmpty) {
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
