import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewFlutterPage extends StatefulWidget {
  final String url;
  const WebviewFlutterPage({
    Key key,
    @required this.url,
  }) : super(key: key);

  @override
  _WebviewFlutterPageState createState() => _WebviewFlutterPageState();
}

class _WebviewFlutterPageState extends State<WebviewFlutterPage> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebviewFlutter')),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
