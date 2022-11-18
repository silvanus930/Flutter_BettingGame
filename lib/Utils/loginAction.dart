import 'package:flutter/material.dart';
import 'package:flutter_betting_app/profile/wallet/myWallet.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'getBalance.dart';
import '../login_page.dart';
import '../config/defaultConfig.dart' as config;

class LoginAction extends StatefulWidget {
  const LoginAction({Key? key}) : super(key: key);

  @override
  LoginActionState createState() => LoginActionState();
}

class LoginActionState extends State<LoginAction> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Padding(
              padding: EdgeInsets.only(right: 20.0, top: 10.0, bottom: 10.0),
              child: GestureDetector(
                  onTap: () {},
                  child: state.authorization == false
                      ? TextButton.icon(
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.onSurface),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          icon: Icon(Icons.account_circle,
                              color: Theme.of(context).indicatorColor),
                          label: Text(LocaleKeys.login.tr(),
                              style:
                                  Theme.of(context).primaryTextTheme.bodyText2))
                      : TextButton(
                          style: TextButton.styleFrom(
                              alignment: Alignment.center,
                              backgroundColor:
                                  Theme.of(context).colorScheme.onSurface),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyWallet()),
                            );
                          },
                          child: config.showCurrencyLogo
                              ? Row(children: [
                                  Image.asset(
                                      config.imageLocation +
                                          "logo/currency_logo.png",
                                      height: 25,
                                      width: 25,
                                      fit: BoxFit.fill),
                                  GetBalance()
                                ])
                              : GetBalance())));
        });
  }
}
