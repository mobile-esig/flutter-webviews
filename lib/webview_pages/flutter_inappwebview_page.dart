import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Exemplo retirado da documentação oficial do plugin.
/// https://pub.dev/packages/flutter_inappwebview/versions/4.0.0+4#inappwebview-class
class InAppWebviewPage extends StatefulWidget {
  final String url;
  const InAppWebviewPage({
    Key key,
    @required this.url,
  }) : super(key: key);

  @override
  _InAppWebviewPageState createState() => _InAppWebviewPageState();
}

class _InAppWebviewPageState extends State<InAppWebviewPage> {
  InAppWebViewController webView;
  String url = '';
  double progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('InAppWebView')),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + '...' : url}',
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: InAppWebView(
                    initialUrl: widget.url,
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        debuggingEnabled: true,
                      ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart:
                        (InAppWebViewController controller, String url) {
                      setState(() {
                        this.url = url;
                      });
                    },
                    onLoadStop:
                        (InAppWebViewController controller, String url) async {
                      setState(() {
                        this.url = url;
                      });
                    },
                    onProgressChanged:
                        (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    onDownloadStart:
                        (InAppWebViewController controller, String url) {
                      print('download: $url');
                    },
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (webView != null) {
                        webView.goBack();
                      }
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (webView != null) {
                        webView.goForward();
                      }
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      if (webView != null) {
                        webView.reload();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
