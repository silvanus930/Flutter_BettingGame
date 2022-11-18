import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import 'package:flutter_betting_app/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/defaultConfig.dart' as config;
import 'package:webview_flutter/webview_flutter.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/storage_service.dart';

class GoldenRace extends StatefulWidget {
  const GoldenRace({Key? key}) : super(key: key);
  @override
  _GoldenRaceState createState() => _GoldenRaceState();
}

class _GoldenRaceState extends State<GoldenRace> {
  late WebViewController _controller;
  String authHashCode = "";
  String error = "";

  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (StoreProvider.of<AppState>(context).state.authorization) {
        getHashCode();
      }
    });

    WebView.platform = SurfaceAndroidWebView();
  }

  void getHashCode() async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/v2/security/gr-hash'));

      await http.post(
        url,
        headers: {
          "content-type": "application/json",
          "Authorization": accessToken,
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          setState(() {
            authHashCode = result['response']['hash'];
            error = "";
          });
        } else {
          setState(() {
            error = "Failed to load user token";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (viewModel.authorization != oldViewModel!.authorization &&
              viewModel.authorization) {
            getHashCode();
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
            body: state.authorization && error != ""
                ? Center(
                    child: Text(error,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)))
                : state.authorization && authHashCode == ""
                    ? Center(child: CircularProgressIndicator())
                    : WebView(
                        initialUrl:
                            "https://${config.versionUrl}/static/goldenRace.html",
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _controller = webViewController;
                        },
                        onPageFinished: (String url) {
                          _controller.runJavascript(
                              "window.grMobileLoader({${state.authorization && authHashCode != "" ? "onlineHash: '$authHashCode'" : "hwId: '${config.goldenRaceUnAuthId}'"}});");
                        },
                        navigationDelegate: (NavigationRequest request) {
                          if (request.url.contains('.pdf')) {
                            launch(request.url);
                          }
                          return NavigationDecision.prevent;
                        },
                      ),
          );
        });
  }
}
