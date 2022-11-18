import 'package:flutter/material.dart';
import 'package:flutter_betting_app/config/global_config.dart';
import 'package:flutter_betting_app/goldenRace/goldenRace.dart';
import 'package:flutter_betting_app/liveCasino/liveCasino.dart';
import 'package:flutter_betting_app/superJackpot/superJackpot.dart';
import '../models/storage_item.dart';
import '../profile/wallet/myWallet.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import '../profile/myAccount.dart';
import '../profile/myBets/myBets.dart';
import '../profile/myBetsJackpot/myBets.dart';
import '../profile/transaction/transaction.dart';
import '../promo/promo.dart';
import '/redux/actions.dart';
import '../lang_view.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../rules/rules.dart';
import '../services/storage_service.dart';
import '../config/defaultConfig.dart' as config;

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          handleLogout() async {
            final StorageService _storageService = StorageService();
            await _storageService.writeSecureData(StorageItem('token', ''));
            await _storageService.writeSecureData(StorageItem('userId', ''));
            await StoreProvider.of<AppState>(context)
                .dispatch(SetAuthorizationAction(authorization: false));
            Navigator.pop(context);
          }

          Future<void> _showDialog() async {
            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(LocaleKeys.logout.tr()),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(LocaleKeys.Logout_Dialog.tr()),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(LocaleKeys.no.tr()),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text(LocaleKeys.yes.tr()),
                      onPressed: () {
                        handleLogout();
                      },
                    ),
                  ],
                );
              },
            );
          }

          return state.userData.length > 0
              ? Drawer(
                  child: Container(
                      child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryVariant,
                        ),
                        accountName: Text(
                            '${state.userData[0]['firstname']} ${state.userData[0]['lastname']}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryVariant)),
                        accountEmail: Text(
                            state.userData[0]['email'] != null
                                ? state.userData[0]['email']
                                : state.userData[0]['username'] != null
                                    ? state.userData[0]['username']
                                    : "",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryVariant)),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).secondaryHeaderColor,
                          child: Text(
                            state.userData[0]['firstname'] != ""
                                ? state.userData[0]['firstname'][0]
                                    .toUpperCase()
                                : state.userData[0]['email'] != null
                                    ? state.userData[0]['email'][0]
                                        .toUpperCase()
                                    : state.userData[0]['username'][0],
                            style: TextStyle(
                                fontSize: 40.0, color: Colors.black87),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.account_circle,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.myAccount.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyAccount()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.stars,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.myBets.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyBets()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.stars,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.myBetsJackpot.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyBetsJackpot()),
                          );
                        },
                      ),
                      config.goldenRaceEnabled
                          ? ListTile(
                              leading: Icon(Icons.casino,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              title: Text(config.goldenRaceMenuTitle,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GoldenRace()),
                                );
                              },
                            )
                          : SizedBox(),
                      config.superJackpotEnabled
                          ? ListTile(
                              leading: Icon(Icons.casino,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              title: Text(LocaleKeys.superJackpot.tr(),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SuperJackpot()),
                                );
                              },
                            )
                          : SizedBox(),
                      config.tvBetEnabled
                          ? ListTile(
                              leading: Icon(Icons.casino,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              title: Text("Live Casino",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LiveCasino()),
                                );
                              },
                            )
                          : SizedBox(),
                      ListTile(
                        leading: Icon(Icons.receipt_long,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.transaction.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Transaction()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.account_balance_wallet,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.myWallet.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyWallet()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.local_offer,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.promo.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Promo(from: 1)),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.gavel,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.rules.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Rules()),
                          );
                        },
                      ),
                      /*
                      ListTile(
                        leading:
                            Icon(Icons.contact_support, color: Theme.of(context).colorScheme.onPrimary),
                        title: Text("Contact us",
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {},
                      ),*/
                      ListTile(
                        leading: Icon(Icons.logout,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.logout.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        onTap: () {
                          _showDialog();
                        },
                      ),
                      Container(
                          height: 40,
                          margin: EdgeInsets.only(left: 10.0),
                          alignment: Alignment.centerLeft,
                          child: LanguageView())
                    ],
                  )),
                )
              : SizedBox();
        });
  }
}
