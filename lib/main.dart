// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:io';

import 'package:f05/ClassManageScreen.dart';
import 'package:f05/DebugScreen.dart';
import 'package:f05/models.dart';
import 'package:f05/searchScreen.dart';
import 'package:flutter/foundation.dart';
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
class _MyHomePageState extends State<MyHomePage> implements AppModelCallbacks {
  BuildContext? mContext;

  AppModel appModel = AppModel();
  RegExp badLineReg = RegExp('([a-z]|[A-Z])|语料');
  late RegExp exp;

  int? curSearchTab = 0;

  var searchTabs = ["古代汉语", "近代汉语", "现代汉语", "指定文献"];

  // var searchTabs = ["古代汉语", "近代报刊", "现代汉语", "外部文献", "指定文献"];
  var curNavBarIndex = 0;

  @override
  void initState() {
    super.initState();
    appModel.init().then((v) {
      appModel.initUser();
    });
    appModel.registerCallback(this);
  }

  @override
  void dispose() {
    // regController.dispose();
    // extralPathController.dispose();
    // exportPathController.dispose();
    super.dispose();
  }

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
        currentIndex: curNavBarIndex,
        onTap: (index) {
          if (index == 0) {
            appModel.initUser();
          }
          curNavBarIndex = index;
          setState(() {});
        },
        items: [
          if (appModel.hasLogin())
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '搜索',
            ),
          if (appModel.isTeacher())
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: '统计',
            ),
          if (appModel.isAdmin() || appModel.isTeacher())
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: '校务',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: '我的',
          ),
          if (kDebugMode)
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Debug',
            ),
        ],
      ),

      // body: SearchScreen2(),

      body: [
        //
        // const SearchScreen2(),
        if (appModel.hasLogin()) SearchScreen2(),
        if (appModel.isTeacher()) StaticScreen(),
        if (appModel.isAdmin() || appModel.isTeacher()) ClassManageScreen(),
        ProfileScreen2(),
        if (kDebugMode) DebugScreen(),
      ][curNavBarIndex],

// This trailing comma makes auto-formatting nicer for build methods.
    );
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

  @override
  void onUserInit() {
    curNavBarIndex = 0;
    setState(() {});
  }

  @override
  void onLogout() {
    curNavBarIndex = 0;
    setState(() {});
  }

  @override
  void onLogin() {
    curNavBarIndex = 0;
    setState(() {});
  }

  @override
  void changeTab(int tabIndex) {
    curNavBarIndex = tabIndex;
    setState(() {});
  }
}
