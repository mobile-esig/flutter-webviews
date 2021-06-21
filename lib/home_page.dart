import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webviews_test/constants.dart';
import 'package:webviews_test/webview_pages/flutter_inappwebview_page.dart';
import 'package:webviews_test/webview_pages/flutter_webview_plugin_page.dart';
import 'package:webviews_test/webview_pages/webview_flutter_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double padding = 50;
  String dropdownCurrentValue;
  List<DropdownMenuItem<String>> dropdownMenuItens;
  final Map<String, String> urls = {
    'DOWNLOAD_IMG': DOWNLOAD_IMG,
    'DOWNLOAD_PDF': DOWNLOAD_PDF,
    'UPLOAD_IMG': UPLOAD_IMG,
    'COMPLEX_PAGE': COMPLEX_PAGE
  };

  @override
  void initState() {
    dropdownCurrentValue = urls.entries.first.value;
    dropdownMenuItens = urls.entries
        .map(
          (e) => DropdownMenuItem<String>(
            value: e.value,
            child: Text(e.key),
          ),
        )
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Webviews'),
      ),
      body: FutureBuilder(
        future: initApp(),
        builder: (context, snapshot) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Choose what to test:'),
                DropdownButton<String>(
                  value: dropdownCurrentValue,
                  items: dropdownMenuItens,
                  onChanged: (newValue) {
                    setState(() {
                      dropdownCurrentValue = newValue;
                    });
                  },
                ),
                SizedBox(height: padding),
                ElevatedButton(
                  child: Text('webview_flutter (oficial)'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            WebviewFlutterPage(url: dropdownCurrentValue),
                      ),
                    );
                  },
                ),
                SizedBox(height: padding),
                ElevatedButton(
                  child: Text('flutter_webview_plugin'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FlutterWebviewPluginPage(url: dropdownCurrentValue),
                      ),
                    );
                  },
                ),
                SizedBox(height: padding),
                ElevatedButton(
                  child: Text('flutter_inappwebview'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            InAppWebviewPage(url: dropdownCurrentValue),
                      ),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future initApp() async {
    await requestStoragePermission();
    await initFlutterDownloader();
  }

  Future requestStoragePermission() async {
    await Permission.storage.request();
  }

  Future initFlutterDownloader() async {
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
  }
}
