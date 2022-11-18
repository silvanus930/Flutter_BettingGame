import 'package:flutter/material.dart';
import 'package:flutter_betting_app/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'Utils/loginAction.dart';
import '../config/defaultConfig.dart' as config;
import 'package:webview_flutter/webview_flutter.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class LiveChat extends StatefulWidget {
  const LiveChat({Key? key}) : super(key: key);
  @override
  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  void initState() {
    super.initState();

    WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(config.imageLocation + "logo/logo_header.png",
            fit: BoxFit.contain, height: 32),
        /*leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),*/
        actions: <Widget>[
          LoginAction(),
        ],
      ),
      body: new WebView(
        initialUrl: config.tawkDirectChatLink,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
