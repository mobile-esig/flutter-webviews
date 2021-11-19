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
  final _webViewKey = GlobalKey();

  late InAppWebViewController _webViewController;
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

  late PullToRefreshController _pullToRefreshController;
  String url = '';
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    _pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController.reload();
        } else if (Platform.isIOS) {
          _webViewController.loadUrl(
            urlRequest: URLRequest(
              url: await _webViewController.getUrl(),
            ),
          );
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
                      key: _webViewKey,
                      initialUrlRequest: URLRequest(
                        url: Uri.parse(
                            'https://testes-quarkclinic-ng.esig.com.br/'),
                      ),
                      initialOptions: options,
                      pullToRefreshController: _pullToRefreshController,
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onLoadStart: _onLoadStart,
                      androidOnPermissionRequest: _androidOnPermissionRequest,
                      shouldOverrideUrlLoading: _showOverrideUrlLoading,
                      onLoadStop: _onLoadStop,
                      onLoadError: _onLoadError,
                      onProgressChanged: _onProgressChanged,
                      onUpdateVisitedHistory: _onUpdateVisitedHistory,
                      onConsoleMessage: _onConsoleMessage,
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

  void _onConsoleMessage(controller, consoleMessage) {
    print('consoleMessage: $consoleMessage');
  }

  void _onLoadError(controller, url, code, message) {
    _pullToRefreshController.endRefreshing();
  }

  void _onLoadStart(controller, url) {
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
            _webViewController.goBack();
          },
        ),
        ElevatedButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () {
            _webViewController.goForward();
          },
        ),
        ElevatedButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            _webViewController.reload();
          },
        ),
      ],
    );
  }

  void _onUpdateVisitedHistory(controller, url, androidIsReload) {
    setState(() {
      this.url = url.toString();
      urlController.text = this.url;
    });
  }

  void _onProgressChanged(controller, progress) {
    if (progress == 100) {
      _pullToRefreshController.endRefreshing();
    }
    setState(() {
      this.progress = progress / 100;
      urlController.text = url;
    });
  }

  void _onLoadStop(controller, url) async {
    _pullToRefreshController.endRefreshing();
    setState(() {
      this.url = url.toString();
      urlController.text = this.url;
    });

    await _webViewController.evaluateJavascript(
      source:
          "alert(`localstorage: \${window.localStorage.getItem('quarkclinic.token.v2')}`)",
    );
  }

  Future<NavigationActionPolicy?> _showOverrideUrlLoading(
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

  Future<PermissionRequestResponse?> _androidOnPermissionRequest(
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
        _webViewController.loadUrl(urlRequest: URLRequest(url: url));
      },
    );
  }
}
