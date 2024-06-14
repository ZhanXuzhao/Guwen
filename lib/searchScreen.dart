import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:f05/models.dart';
import 'package:f05/profileScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'dir_list.dart';

class SearchScreen2 extends StatefulWidget {
  const SearchScreen2({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<StatefulWidget> {
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
  int? curSearchTab = 0;
  var searchTabs = ["古代汉语", "现代汉语", "近代报刊", "指定文献", "国学大师", "汉字全息资源应用系统"];
  var showExportButton = false;

  RegExp badLineReg = RegExp('([a-z]|[A-Z])|语料');
  late RegExp exp;

  var navBarIndex = 0;

  @override
  void initState() {
    super.initState();
    print('main init state');
    print('curSearchTab: $curSearchTab');
    curSearchTab = appModel.curYuliaoType;
    print('curSearchTab update: $curSearchTab');

    appModel.init().then((onValue) {
      var rs = appModel.getRegStr();
      regController.text = rs == ".*" ? "" : rs;
      extralPathController.text = appModel.getYuliaoPath();
      exportPathController.text = appModel.getExportPathStr();
      appModel.initYuliaoType();
    });
  }

  @override
  void dispose() {
    regController.dispose();
    extralPathController.dispose();
    exportPathController.dispose();
    // appModel.dispose();
    super.dispose();
  }

  //page build
  @override
  Widget build(BuildContext context) {
    mContext = context;

    return Column(
      children: [
        Stack(
          children: [
            const GuwenAppBar(title: "汉语溯源"),
            Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ],
                )),
          ],
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //搜索条件 正则表达式
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
                        suffixIcon: regController.text.length > 0
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_outlined,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  regController.clear();
                                  showProgressUI = false;
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: regController,
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: searchData, child: const Text('搜索')),
                ],
              ),

              Container(
                height: 8,
              ),

              // search tabs 现代汉语、近代汉语、古汉语、指定文献
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
                            FileListPage.launch(context,
                                kDebugMode ? textFilePathDebug : "", true);
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
                    const Text("a..b 匹配a、b间有2个任意字符;"
                        "\na.*b 匹配a、b间有任意个字符;"
                        "\na.{m,n}b 匹配a、b间有m-n个字符;"
                        "\n更多搜索语法可以百度正则表达式进行了解;"),
                    Text(
                      "示例（可点击）：",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),

                    // Text(
                    //   "cur path：${Directory.current.path}",
                    //   style: TextStyle(color: Theme.of(context).primaryColor),
                    // ),

                    Container(
                      height: 8,
                    ),

                    // search example clip
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
                            setState(() {

                            });
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

              const SizedBox(
                height: 8,
              ),
              // DataListView(textList: searchedTextList),
              if (showProgressUI)
                Expanded(
                  child: Stack(
                    children: [
                      // bg, make Stack expend
                      const SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        // color: Colors.green,
                      ),

                      // list of search result
                      Positioned.fill(
                        child: DataListView(textList: searchedTextList),
                      ),

                      // export button
                      if (showExportButton)
                        Positioned(
                          bottom: 32,
                          right: 32,
                          child: FloatingActionButton(
                            onPressed: exportSearchResult,
                            tooltip: '下载',
                            child: const Icon(Icons.download),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> searchData() async {
    showExportButton = false;
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
    log("search finished  $searchTotalFiles files get $searchProgress sentence");
    showExportButton = true;
    updateUI();
    appModel.sendSearchRequest(regStr);
    // showMessage("搜索完成");
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
        .transform(const LineSplitter()); // Convert stream to individual lines.
    try {
      await for (var longLine in lines) {
        var subLines = longLine.split(RegExp('。'));
        for (var line in subLines) {
          bool isMatch = exp.hasMatch(line) && !badLineReg.hasMatch(line);
          // bool isMatch = exp.hasMatch(line);

          if (isMatch) {
            // print("reg $regStr ${exp.hasMatch(line)} $lineIndex");
            var fileName = getFileDirLocation(file.path);
            // 消除绝对路径的父路径
            if (kReleaseMode) {
              fileName = fileName.replaceFirst(
                  "${Directory.current.path}$innerYuliaoPathRelease\\", "");
            } else {
              fileName = fileName.replaceFirst("$innerYuliaoPathDebug\\", "");
            }
            // 消除路径中的数字、小数点
            fileName = fileName.replaceAll(RegExp("\\d|\\.|.txt"), "");
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
    return filePath;
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
    var highlightTextStyle = const TextStyle(
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
    // print("build text list view2");

    return ListView.builder(
        // fix bug Cannot hit test a render box that has never been laid out.
        shrinkWrap: true,
        itemCount: textList.length,
        itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(4),
            child: TextHighlight(
              text: textList[index],
              words: hightWords,
            )));
  }
}
