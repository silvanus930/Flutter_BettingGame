import 'package:flutter/material.dart';
import 'package:flutter_betting_app/topTournaments/topTournaments.dart';
import 'Utils/loginAction.dart';
import 'races/races.dart';
import 'redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'prematch/prematchSports.dart';
import 'drawerWidget/MyDrawer.dart';
import 'drawerWidget/MyDrawerUnAuth.dart';
import 'topTournaments/topTournaments.dart';
import 'popularMatches/popularMatches.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/defaultConfig.dart' as config;
import 'package:flutter_betting_app/presentation/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class Prematch extends StatefulWidget {
  final store;

  const Prematch({Key? key, this.store}) : super(key: key);

  @override
  PrematchState createState() => PrematchState();
}

class PrematchState extends State<Prematch> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          List tabsList = [
            LocaleKeys.sport.tr(),
            LocaleKeys.popular.tr(),
            LocaleKeys.tournaments.tr(),
            "Races"
          ];
          return DefaultTabController(
              length: config.prematchTabs.length,
              initialIndex: state.racesSportName == ""
                  ? 0
                  : config.prematchTabs.indexWhere((e) => e == 3),
              child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                    leading: new IconButton(
                        icon: new Icon(Icons.menu),
                        onPressed: () =>
                            {_scaffoldKey.currentState!.openDrawer()}),
                    title: Image.asset(
                        config.imageLocation + "logo/logo_header.png",
                        fit: BoxFit.contain,
                        height: 32),
                    actions: <Widget>[
                      config.whatsappLinkUrl != ""
                          ? new IconButton(
                              icon: new Icon(AppIcons.whatsapp,
                                  color: Colors.green),
                              onPressed: () => {launch(config.whatsappLinkUrl)})
                          : SizedBox(),
                      LoginAction(),
                    ],
                    bottom: TabBar(
                      tabs: [
                        for (var item in config.prematchTabs)
                          Tab(text: tabsList[item])
                      ],
                    )),
                body: TabBarView(
                  children: [
                    for (var item in config.prematchTabs)
                      item == 0
                          ? Center(
                              child: PrematchSports(
                                  store: widget.store, locale: context.locale))
                          : item == 1
                              ? Center(
                                  child: PopularMatches(store: widget.store))
                              : item == 2
                                  ? Center(
                                      child:
                                          TopTournaments(store: widget.store))
                                  : Center(child: Races(store: widget.store))
                  ],
                ),
                drawer: !state.authorization ? MyDrawerUnAuth() : MyDrawer(),
              ));
        });
  }
}
