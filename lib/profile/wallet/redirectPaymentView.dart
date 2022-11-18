import 'package:flutter/material.dart';
import '../../config/defaultConfig.dart' as config;
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final redirectUrl;
  const PaymentWebView({Key? key, this.redirectUrl}) : super(key: key);
  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
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
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: new WebView(
        initialUrl: widget.redirectUrl,
        navigationDelegate: (NavigationRequest request) {
            Navigator.of(context).pop();
            return NavigationDecision.prevent;
          },
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
