import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// Exemplo retirado da documentação oficial do plugin.
/// https://pub.dev/packages/flutter_inappwebview/versions/4.0.0+4#inappwebview-class
class InAppWebviewPage extends StatefulWidget {
  final String url;
  const InAppWebviewPage({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _InAppWebviewPageState createState() => _InAppWebviewPageState();
}

class _InAppWebviewPageState extends State<InAppWebviewPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  final options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  String url = '';
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('InAppWebView'),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildURLBar(),
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(
                        url: Uri.parse(widget.url),
                      ),
                      initialOptions: options,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: onLoadStart,
                      androidOnPermissionRequest: androidOnPermissionRequest,
                      shouldOverrideUrlLoading: showOverrideUrlLoading,
                      onLoadStop: onLoadStop,
                      onLoadError: onLoadError,
                      onProgressChanged: onProgressChanged,
                      onUpdateVisitedHistory: onUpdateVisitedHistory,
                      onConsoleMessage: onConsoleMessage,
                    ),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
              _buildButtonBar(),
            ],
          ),
        ),
      ),
    );
  }

  void onConsoleMessage(controller, consoleMessage) {
    print('consoleMessage: $consoleMessage');
  }

  void onLoadError(controller, url, code, message) {
    pullToRefreshController.endRefreshing();
  }

  void onLoadStart(controller, url) {
    setState(() {
      this.url = url.toString();
      urlController.text = this.url;
    });
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            webViewController?.goBack();
          },
        ),
        ElevatedButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () {
            webViewController?.goForward();
          },
        ),
        ElevatedButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            webViewController?.reload();
          },
        ),
      ],
    );
  }

  void onUpdateVisitedHistory(controller, url, androidIsReload) {
    setState(() {
      this.url = url.toString();
      urlController.text = this.url;
    });
  }

  void onProgressChanged(controller, progress) {
    if (progress == 100) {
      pullToRefreshController.endRefreshing();
    }
    setState(() {
      this.progress = progress / 100;
      urlController.text = url;
    });
  }

  void onLoadStop(controller, url) async {
    pullToRefreshController.endRefreshing();
    setState(() {
      this.url = url.toString();
      urlController.text = this.url;
    });
  }

  Future<NavigationActionPolicy?> showOverrideUrlLoading(
      controller, navigationAction) async {
    var uri = navigationAction.request.url!;

    if (!['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about']
        .contains(uri.scheme)) {
      if (await canLaunch(url)) {
        // Launch the App
        await launch(url);
        // and cancel the request
        return NavigationActionPolicy.CANCEL;
      }
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<PermissionRequestResponse?> androidOnPermissionRequest(
      controller, origin, resources) async {
    return PermissionRequestResponse(
        resources: resources, action: PermissionRequestResponseAction.GRANT);
  }

  Widget _buildURLBar() {
    return TextField(
      decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
      controller: urlController,
      keyboardType: TextInputType.url,
      onSubmitted: (value) {
        var url = Uri.parse(value);
        if (url.scheme.isEmpty) {
          url = Uri.parse('https://www.google.com/search?q=' + value);
        }
        webViewController?.loadUrl(urlRequest: URLRequest(url: url));
      },
    );
  }
}
