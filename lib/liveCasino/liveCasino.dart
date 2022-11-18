import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import 'package:flutter_betting_app/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../config/defaultConfig.dart' as config;
import 'package:webview_flutter/webview_flutter.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/storage_service.dart';

class LiveCasino extends StatefulWidget {
  const LiveCasino({Key? key}) : super(key: key);
  @override
  _LiveCasinoState createState() => _LiveCasinoState();
}

class _LiveCasinoState extends State<LiveCasino> {
  late WebViewController _controller;

  var code = '';
  _LiveCasinoState() {
    final StorageService _storageService = StorageService();
    _storageService.readSecureData('gbCode').then((val) => setState(() {
          code = val!;
        }));
  }

  void initState() {
    super.initState();
    WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (oldViewModel?.authorization != viewModel.authorization) {
            _controller.reload();
          }
        },
        builder: (context, state) {
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
            body: !state.authorization && code.length > 0
                ? WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _controller.loadFlutterAsset(
                          'assets/html/${config.flavorName}/tvBet.html');
                    },
                    onPageFinished: (String url) {
                      _controller.runJavascript(
                          "window.TvbetFrame({'lng': 'en','clientId': '${config.tvBetClientId}','tokenAuth': 'false','server': '${config.tvbetIframeUrl}','floatTop': '#fTop', 'containerId': 'tvbet-game'});");
                    },
                  )
                : WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                      _controller.loadFlutterAsset(
                          'assets/html/${config.flavorName}/tvBet.html');
                    },
                    onPageFinished: (String url) {
                      _controller.runJavascript(
                          "window.TvbetFrame({'lng': 'en','clientId': '${config.tvBetClientId}','tokenAuth': '$code','server': '${config.tvbetIframeUrl}','floatTop': '#fTop', 'containerId': 'tvbet-game'});");
                    },
                  ),
          );
        });
  }
}
