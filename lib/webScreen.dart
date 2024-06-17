import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';

const webGgxds = 'https://www.guoxuedashi.net/';
const webQxk = 'https://qxk.bnu.edu.cn/';
final navigatorKey = GlobalKey<NavigatorState>();

class WebScreen extends StatefulWidget {
  WebScreen({super.key, required this.url});

  String url;

  static void launch(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebScreen(url: url),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _WebScreenState();
  }
}

class _WebScreenState extends State<WebScreen> {
  final _controller = WebviewController();
  final _textController = TextEditingController();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await _controller.initialize();
      _subscriptions.add(_controller.url.listen((url) {
        _textController.text = url;
      }));

      _subscriptions
          .add(_controller.containsFullScreenElementChanged.listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        // windowManager.setFullScreen(flag);
      }));

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl(widget.url);

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
                child: Stack(
              children: [
                Webview(
                  _controller,
                  permissionRequested: _onPermissionRequested,
                ),
                StreamBuilder<LoadingState>(
                    stream: _controller.loadingState,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data == LoadingState.loading) {
                        return LinearProgressIndicator();
                      } else {
                        return SizedBox();
                      }
                    }),
              ],
            )),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: StreamBuilder<String>(
        stream: _controller.title,
        builder: (context, snapshot) {
          return Text(
              snapshot.hasData ? snapshot.data! : 'WebView (Windows) Example');
        },
      )),
      body: Center(
        child: compositeView(),
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _controller.dispose();
    super.dispose();
  }
}
