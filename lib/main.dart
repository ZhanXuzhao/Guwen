// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:io';

import 'package:f05/ClassManageScreen.dart';
import 'package:f05/DebugScreen.dart';
import 'package:f05/models.dart';
import 'package:f05/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dir_list.dart';
import 'profileScreen.dart';
import 'staticScreen.dart';

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

  // final regController = TextEditingController();
  // final extralPathController = TextEditingController();
  // final exportPathController = TextEditingController();

  // var regStr = "";

  // var assetsPath = TextFilePath;
  AppModel appModel = AppModel();

  // var searchedTextList = <String>[];
  // var searchProgress = 0;
  // var searchTotalFiles = 0;
  // var totalLineCount = 0;
  // bool showProgressUI = false;
  // var searchProgressText = "";
  // var searchResultStaticText = "";
  // var searchDurationText = "";
  // var exampleSearchText = ['之', '之.者', '之.*者', '之.{1,4}者'];

  RegExp badLineReg = RegExp('([a-z]|[A-Z])|语料');
  late RegExp exp;

  var navBarIndex = 0;

  @override
  void dispose() {
    // regController.dispose();
    // extralPathController.dispose();
    // exportPathController.dispose();
    super.dispose();
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

  // void exportSearchResult() async {
  //   var dp = (await getApplicationDocumentsDirectory()).path;
  //   var path = '$dp\\古汉语搜索结果';
  //   var dir = Directory(path);
  //   if (!dir.existsSync()) {
  //     dir.createSync(recursive: true);
  //   }
  //
  //   // appModel.setExportPath(path);
  //   var file = File("$path/${getExportFileName()}.txt");
  //   file.create(recursive: true);
  //   print('export file $file');
  //   for (var line in searchedTextList) {
  //     // print('write $line');
  //     file.writeAsStringSync("$line\r", mode: FileMode.append, encoding: utf8);
  //     // file.writeAsStringSync('\r', mode: FileMode.append, encoding: utf8);
  //   }
  //
  //   print('export success');
  //   showMessage("导出成功 $path");
  // }

  // String getExportFileName() {
  //   var timeStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  //   var hws = appModel.highlightWords.join("_");
  //
  //   var s = "${timeStr}_$hws";
  //   return s;
  // }

  @override
  void initState() {
    super.initState();
    print('main init state');
    print('curSearchTab: $curSearchTab');
    // curSearchTab = appModel.curYuliaoType;
    print('curSearchTab update: $curSearchTab');

    // appModel.init().then((onValue) {
    // var rs = appModel.getRegStr();
    // regController.text = rs == ".*" ? "" : rs;
    // extralPathController.text = appModel.getYuliaoPath();
    // exportPathController.text = appModel.getExportPathStr();
    // appModel.initYuliaoType();

    // initDb();
    // });
    // searchData();
  }

  int? curSearchTab = 0;

  var searchTabs = ["古代汉语", "近代汉语", "现代汉语", "指定文献"];

  // var searchTabs = ["古代汉语", "近代报刊", "现代汉语", "外部文献", "指定文献"];

  //page build
  @override
  Widget build(BuildContext context) {
    mContext = context;

    print("ui build");
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   titleTextStyle:
      //       TextStyle(color: Colors.white, fontSize: 32, fontFamily: "楷体"),
      //   automaticallyImplyLeading: false,
      // ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navBarIndex,
        onTap: (index) {
          setState(() {
            navBarIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索-',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: '我的',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '校务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Test',
          ),
        ],
      ),

      // body: SearchScreen2(),

      body: [
        //
        // const SearchScreen2(),
        SearchScreen2(),
        StaticScreen(),
        ProfileScreen2(),
        ClassManageScreen(),
        DebugScreen(),
      ][navBarIndex],

// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
