import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_betting_app/betslip/BSForm.dart';
import 'Utils/loginAction.dart';
import 'generated/locale_keys.g.dart';
import 'redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'betslip/bookingCheck.dart';
import '../redux/actions.dart';
import 'package:easy_localization/easy_localization.dart';

class Betslip extends StatefulWidget {
  const Betslip({Key? key}) : super(key: key);
  @override
  State<Betslip> createState() => BetslipState();
}

class BetslipState extends State<Betslip> with TickerProviderStateMixin {
  bool multipleTab = false;
  bool systemTab = false;
  int tabsLength = 0;
  int bookingCodeLoaded = -1;
  bool racesCode = false;

  getArrayOdds() {
    final store = StoreProvider.of<AppState>(context);
    switch (StoreProvider.of<AppState>(context).state.racesSportName) {
      case "":
        return store.state.odds;
      case "horses":
        return store.state.horsesOdds;
      case "dogs":
        return store.state.dogsOdds;
      default:
        return store.state.odds;
    }
  }

  generateLetterArray(List odds, oddId) {
    List tournamentsBets = odds;
    if (oddId != null) {
      odds.map((e) => {e['oddId'] != oddId ? tournamentsBets.add(e) : null});
    }
    var letterHelper =
        new List.filled(tournamentsBets.length, "", growable: true);
    int delta = -1;

    tournamentsBets.asMap().entries.forEach((e) {
      var letterIndCounter = 1;

      List data = [];

      tournamentsBets.forEach((el) => {
            if (e.value['match'] == el['match'] &&
                e.value['betDomainId'] == el['betDomainId'])
              {data.add(1)}
            else
              {data.add(0)}
          });

      var countOfItems = data.where((e) => e == 1).length;

      if (countOfItems == 1) {
        delta += 1;
        letterHelper[e.key] = letterHelper[e.key] == ""
            ? String.fromCharCode(65 + delta)
            : letterHelper[e.key];
      } else if (countOfItems > 1) {
        delta += 1;
        data.asMap().entries.forEach((val) => {
              if (val.value == 1 && letterHelper[val.key] == "")
                {
                  letterHelper[val.key] = String.fromCharCode(65 + delta) +
                      "" +
                      letterIndCounter.toString(),
                  letterIndCounter += 1
                }
              else
                {letterHelper[e.key] = letterHelper[e.key]}
            });
      }

      // console.log("dATA", ind, " : ", data)
    });
    return letterHelper;
  }

  handleBookingCode(val) {
    setState(() {
      bookingCodeLoaded = val;
    });
  }

  addMatchesData(List matches, betType) {
    if ((matches[0]['sId'] == 100 || matches[0]['sId'] == 101) &&
        StoreProvider.of<AppState>(context).state.racesSportName == "") {
      setState(() {
        racesCode = true;
      });
      if (matches[0]['sId'] == 100) {
        StoreProvider.of<AppState>(context)
            .dispatch(SetRacesSportNameAction(racesSportName: "horses"));
      }
      if (matches[0]['sId'] == 101) {
        StoreProvider.of<AppState>(context)
            .dispatch(SetRacesSportNameAction(racesSportName: "dogs"));
      }
    }
    matches.forEach((e) {
      e['odds'].forEach((val) {
        if (e['sId'] == 100) {
          StoreProvider.of<AppState>(context)
              .dispatch(SetHorsesOddsAction(horsesOdds: {
            'match': e['matchId'],
            'betDomainId': e['betMarketId'],
            'sport': e['sId'],
            'oddId': val['id']
          }));
        } else if (e['sId'] == 101) {
          StoreProvider.of<AppState>(context)
              .dispatch(SetDogsOddsAction(dogsOdds: {
            'match': e['matchId'],
            'betDomainId': e['betMarketId'],
            'sport': e['sId'],
            'oddId': val['id']
          }));
        } else {
          StoreProvider.of<AppState>(context).dispatch(SetOddsAction(odds: {
            'match': e['matchId'],
            'betDomainId': e['betMarketId'],
            'sport': e['sId'],
            'oddId': val['id']
          }));
        }
      });
    });
    if (betType == "sng") {
      handleBookingCode(0);
    } else if (betType == "cmb" || betType == "cmp") {
      handleBookingCode(1);
    } else if (betType == "sys" || betType == "syp") {
      handleBookingCode(2);
    }
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 1);
    WidgetsBinding.instance?.addPostFrameCallback((_) => checkTabsIndex(false));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  checkTabsIndex(update) {
    if ((getArrayOdds().length > 0 &&
        getArrayOdds().any((element) =>
            getArrayOdds().any((e) =>
                element['betDomainId'] != e['betDomainId'] &&
                element['match'] == e['match']) ==
            true))) {
      setState(() {
        tabsLength = 1;
      });
    } else {
      if (getArrayOdds().length == 0) {
        setState(() {
          tabsLength = 0;
        });
      }

      if (getArrayOdds().length == 1) {
        setState(() {
          tabsLength = 1;
        });
      }

      if (getArrayOdds().length > 1) {
        List lettersArr = generateLetterArray(getArrayOdds(), null);
        int uniqeLettersLength = lettersArr
            .map((e) => e.substring(0, 1))
            .toList()
            .toSet()
            .toList()
            .length;

        final onlyLetters = new RegExp(r"\d+");
        int onlyLettersArrLength = lettersArr
            .where((element) => !onlyLetters.hasMatch(element))
            .toList()
            .length;

        if (getArrayOdds().length > 1 &&
            uniqeLettersLength > 1 &&
            onlyLettersArrLength <= 2) {
          setState(() {
            tabsLength = 2;
          });
        } else if (getArrayOdds().length > 2 && onlyLettersArrLength > 2) {
          setState(() {
            tabsLength = 3;
          });
        } else {
          setState(() {
            tabsLength = 1;
          });
        }
      }
    }

    _tabController = TabController(
        vsync: this,
        length: tabsLength == 0 ? 1 : tabsLength,
        initialIndex: (tabsLength == 0 || tabsLength == 1)
            ? 0
            : tabsLength > 1 && update && _tabController.index == 0
                ? 0
                : tabsLength > 1 && _tabController.index == 0
                    ? 1
                    : tabsLength == 2 && _tabController.index == 2
                        ? 1
                        : _tabController.index);

    if (bookingCodeLoaded != -1) {
      setState(() {
        _tabController.index = bookingCodeLoaded;
        bookingCodeLoaded = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (viewModel.odds.length != oldViewModel!.odds.length) {
            checkTabsIndex(true);
          }
          if (viewModel.horsesOdds.length != oldViewModel.horsesOdds.length) {
            checkTabsIndex(true);
          }
          if (viewModel.dogsOdds.length != oldViewModel.dogsOdds.length) {
            checkTabsIndex(true);
          }
        },
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                  title: Text(LocaleKeys.betslip.tr()),
                  leading: new IconButton(
                      icon: new Icon(Icons.arrow_back),
                      onPressed: () => {
                            if (racesCode)
                              {
                                StoreProvider.of<AppState>(context).dispatch(
                                    SetRacesSportNameAction(racesSportName: ""))
                              },
                            Navigator.pop(context)
                          }),
                  actions: <Widget>[LoginAction()],
                  bottom: TabBar(
                    key: Key("${_tabController.index}"),
                    controller: _tabController,
                    tabs: tabsLength == 0
                        ? [
                            Tab(text: LocaleKeys.bookingCode.tr()),
                          ]
                        : tabsLength == 1 ||
                                (getArrayOdds().length > 0 &&
                                    getArrayOdds().any((element) =>
                                        getArrayOdds().any((e) =>
                                            element['betDomainId'] !=
                                                e['betDomainId'] &&
                                            element['match'] == e['match']) ==
                                        true))
                            ? [
                                Tab(text: LocaleKeys.single.tr()),
                              ]
                            : tabsLength == 2
                                ? [
                                    Tab(text: LocaleKeys.single.tr()),
                                    Tab(text: "Multiple"),
                                  ]
                                : [
                                    Tab(text: LocaleKeys.single.tr()),
                                    Tab(text: "Multiple"),
                                    Tab(text: LocaleKeys.system.tr()),
                                  ],
                  )),
              body: TabBarView(
                key: Key("${_tabController.index}"),
                controller: _tabController,
                children: tabsLength == 0
                    ? [
                        BookingCheck(
                          addMatchesData: (val, e) {
                            addMatchesData(val, e);
                          },
                        ),
                      ]
                    : tabsLength == 1 ||
                            (getArrayOdds().length > 0 &&
                                getArrayOdds().any((element) =>
                                    getArrayOdds().any((e) =>
                                        element['betDomainId'] !=
                                            e['betDomainId'] &&
                                        element['match'] == e['match']) ==
                                    true))
                        ? [
                            BSForm(key: Key("0"), currentTab: 0),
                          ]
                        : tabsLength == 2
                            ? [
                                BSForm(key: Key("0"), currentTab: 0),
                                BSForm(key: Key("1"), currentTab: 1)
                              ]
                            : [
                                BSForm(key: Key("0"), currentTab: 0),
                                BSForm(key: Key("1"), currentTab: 1),
                                BSForm(key: Key("2"), currentTab: 2),
                              ],
              ));
        });
  }
}
