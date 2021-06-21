import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

/// Plugin that allows Flutter to communicate with a native WebView.
/// Warning: The webview is not integrated in the widget tree, it is a native
/// view on top of the flutter view. You won't be able see snackbars, dialogs,
/// or other flutter widgets that would overlap with the region of the screen
/// taken up by the webview.
class FlutterWebviewPluginPage extends StatelessWidget {
  final String url;
  const FlutterWebviewPluginPage({
    Key key,
    @required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      appBar: AppBar(title: Text('FlutterWebviewPlugin')),
    );
  }
}
