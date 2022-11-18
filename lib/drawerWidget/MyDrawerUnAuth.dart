import 'package:flutter/material.dart';
import 'package:flutter_betting_app/goldenRace/goldenRace.dart';
import 'package:flutter_betting_app/liveCasino/liveCasino.dart';
import 'package:flutter_betting_app/superJackpot/superJackpot.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import '../promo/promo.dart';
import '../lang_view.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/defaultConfig.dart' as config;
import '../rules/rules.dart';

class MyDrawerUnAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Drawer(
            child: Container(
                child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryVariant,
                  ),
                  accountName: Text(LocaleKeys.guest.tr(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryVariant)),
                  accountEmail: Text(
                      LocaleKeys.welcomeTo.tr(args: [config.appTitle]),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryVariant)),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    child: Text(
                      "G",
                      style: TextStyle(fontSize: 40.0, color: Colors.black87),
                    ),
                  ),
                ),
                config.goldenRaceEnabled && !config.goldenRaceOnlyAuth
                    ? ListTile(
                        leading: Icon(Icons.casino,
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(config.goldenRaceMenuTitle,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
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
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text(LocaleKeys.superJackpot.tr(),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
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
                            color: Theme.of(context).colorScheme.onPrimary),
                        title: Text("Live Casino",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
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
                  leading: Icon(Icons.local_offer,
                      color: Theme.of(context).colorScheme.onPrimary),
                  title: Text(LocaleKeys.promo.tr(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Promo(from: 1)),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.gavel,
                      color: Theme.of(context).colorScheme.onPrimary),
                  title: Text(LocaleKeys.rules.tr(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Rules()),
                    );
                  },
                ),
                /*ListTile(
                  leading: Icon(Icons.contact_support, color: Colors.white),
                  title:
                      Text("Contact us", style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),*/
                Container(
                    height: 40,
                    margin: EdgeInsets.only(left: 10.0),
                    alignment: Alignment.centerLeft,
                    child: LanguageView())
              ],
            )),
          );
        });
  }
}
