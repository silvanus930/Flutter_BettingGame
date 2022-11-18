import 'package:flutter/material.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/actions.dart';
//import 'dart:async';
import 'dart:convert';
import 'prematchSportsWidgets/sportCategories.dart';
import 'prematchSportsWidgets/sportCountries.dart';
import 'prematchSportsWidgets/sportTournaments.dart';
import 'prematchSportsWidgets/sportTournamentData.dart';
import '../Utils/stomp.dart' as stomp;
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class PrematchSports extends StatefulWidget {
  final store;
  final locale;

  const PrematchSports({Key? key, this.store, this.locale}) : super(key: key);

  @override
  PrematchSportsState createState() => PrematchSportsState();
}

class PrematchSportsState extends State<PrematchSports> {
  dynamic unsubscribePrematchInfo;
  dynamic unsubscribePrematchData;
  dynamic unsubscribeMatchDetailsData;
  bool langChanged = false;
  int indexSport = -1;
  int indexCountry = -1;
  int indexTournament = -1;
  int activeCategory = 1;
  List<int> activeCategoryList = [1, 2, 3, 4];

  getPeriodName(id) {
    switch (id) {
      case 1:
        return LocaleKeys.today.tr();
      case 2:
        return LocaleKeys.lastMinute.tr();
      case 3:
        return LocaleKeys.tomorrow.tr();
      case 4:
        return LocaleKeys.allEvents.tr();
      default:
        return "";
    }
  }

  void unSubscribeMatchesInTour(newSubscribe) {
    unsubscribePrematchData(unsubscribeHeaders: {
      'id':
          '/tournament/${newSubscribe['sport']}/${newSubscribe['tournament']}/${newSubscribe['groups'][0]}'
    });
    widget.store.dispatch(
        RemovePrematchUnSubscribeListAction(prematchUnSubscribeList: []));
  }

  void subscribeMatchesInTour(newSubscribe) {
    if (stomp.stompClient.connected) {
      unsubscribePrematchData = stomp.stompClient.subscribe(
        destination:
            '/tournament/${newSubscribe['sport']}/${newSubscribe['tournament']}/${newSubscribe['groups'][0]}',
        headers: {
          'id':
              '/tournament/${newSubscribe['sport']}/${newSubscribe['tournament']}/${newSubscribe['groups'][0]}'
        },
        callback: (frame) {
          var result = jsonDecode(frame.body!);
          if (result['tournament'] != null) {
            result['tournament']['country'] =
                widget.store.state.prematchSubscribeList[0]['country'];
            result['tournament']['activeGroup'] =
                widget.store.state.prematchSubscribeList[0]['groups'];
            widget.store.dispatch(SetPrematchMatchAction(
                prematchMatch: result['tournament']['matchs']));
            widget.store.dispatch(SetPrematchBetDomainsAction(
                prematchBetDomains: result['tournament']));
            widget.store.dispatch(SetPrematchBetdomainsGroupAction(
                prematchBetdomainsGroup: result['tournament']));
          }
          /*else if (result['betdomainStatusMessage'] != null) {
                      widget.store.dispatch(UpdateStatusOddsBetDomainInfoAction(
                          oddsBetDomainInfo: result['betdomainStatusMessage']));
                    }*/
          /*widget.store.dispatch(
                SetPrematchInfoAction(prematchInfo: result['sportCategories']));*/
          widget.store.dispatch(
              RemovePrematchSubscribeListAction(prematchSubscribeList: []));
        },
      );
    }
  }

  void unSubscribeMatchDetails(newSubscribe) {
    unsubscribeMatchDetailsData(unsubscribeHeaders: {
      'id':
          '/matchDetails/${newSubscribe['sport']}/${newSubscribe['match']}/${newSubscribe['groups'][0]}'
    });
  }

  void subscribeMatchDetails(newSubscribe) {
    if (stomp.stompClient.connected) {
      widget.store.dispatch(RemoveMatchDetailsSubscribeListAction(
          matchDetailsSubscribeList: newSubscribe));
      unsubscribeMatchDetailsData = stomp.stompClient.subscribe(
        destination:
            '/matchs/${newSubscribe['sport']}/${newSubscribe['match']}/${newSubscribe['groups'][0]}',
        headers: {
          'id':
              '/matchDetails/${newSubscribe['sport']}/${newSubscribe['match']}/${newSubscribe['groups'][0]}'
        },
        callback: (frame) {
          var result = jsonDecode(frame.body!);
          if (result['match'] != null) {
            widget.store.dispatch(SetMatchDetailsMatchDataAction(
                matchDetailsMatchData: result['match']));

            widget.store.dispatch(SetMatchDetailsDomainsAction(
                matchDetailsBetDomains: result['match']));
          } else if (result['betdomainStatusMessage'] != null) {
            widget.store.dispatch(UpdatetMatchDetailsDomainsAction(
                matchDetailsBetDomains: result['betdomainStatusMessage']));
          }

          /*else if (result['betdomainStatusMessage'] != null) {
                      widget.store.dispatch(UpdateStatusOddsBetDomainInfoAction(
                          oddsBetDomainInfo: result['betdomainStatusMessage']));
                    }*/
          /*widget.store.dispatch(
                SetPrematchInfoAction(prematchInfo: result['sportCategories']));*/
          /* widget.store.dispatch(RemoveMatchDetailsSubscribeListAction(
              matchDetailsSubscribeList: newSubscribe));*/
        },
      );
    }
  }

  void subscribePrematchInfo() {
    if (unsubscribePrematchInfo != null) {
      unsubscribePrematchInfo(unsubscribeHeaders: {'id': 'prematchInfo'});
    }
    unsubscribePrematchInfo = stomp.stompClient.subscribe(
      destination: getActiveCategory(),
      headers: {'id': 'prematchInfo'},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['sportCategories'] != null) {
          widget.store.dispatch(
              SetPrematchInfoAction(prematchInfo: result['sportCategories']));
          /*widget.store.dispatch(SetliveInfoCommonAction(
                liveInfoCommon: result['sportCategories']));*/
        }
      },
    );
  }

  initState() {
    super.initState();
    if (stomp.stompClient.connected) {
      subscribePrematchInfo();
    }
  }

  void didUpdateWidget(PrematchSports oldWidget) {
    if (stomp.stompClient.connected &&
        widget.store.state.prematchInfo.length == 0) {
      subscribePrematchInfo();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (unsubscribePrematchInfo != null) {
      unsubscribePrematchInfo(unsubscribeHeaders: {'id': 'prematchInfo'});
    }

    widget.store.dispatch(RemovePrematchInfoAction(prematchInfo: []));
    super.dispose();
  }

  PageController _pageController = PageController();

  getActiveCategory() {
    switch (activeCategory) {
      case 1:
        return "/today";
      case 2:
        return "/sixhours";
      case 3:
        return "/tomorrow";
      case 4:
        return "/allevents";
      default:
        return "/today";
    }
  }

  void changeSportIndex(index) {
    setState(() {
      indexSport = index;
      indexTournament = -1;
      indexCountry = -1;
    });
  }

  void changeCountryIndex(index) {
    setState(() {
      indexCountry = index;
    });
  }

  void changeTournamentIndex(index) {
    setState(() {
      indexTournament = index;
    });
  }

  void nextPage() {
    _pageController.animateToPage(_pageController.page!.toInt() + 1,
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  void homePage() {
    _pageController.animateToPage(
        _pageController.page!.toInt() - _pageController.page!.toInt(),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn);
  }

  void previousPage() {
    _pageController.animateToPage(_pageController.page!.toInt() - 1,
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  void changePeriod(category) {
    setState(() {
      activeCategory = category;
    });

    subscribePrematchInfo();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (viewModel.prematchUnSubscribeList.length > 0 &&
              viewModel.prematchUnSubscribeList.length !=
                  oldViewModel!.prematchUnSubscribeList.length) {
            unSubscribeMatchesInTour(viewModel.prematchUnSubscribeList[0]);
          }

          if (viewModel.prematchSubscribeList.length > 0 &&
              viewModel.prematchSubscribeList.length !=
                  oldViewModel!.prematchSubscribeList.length) {
            subscribeMatchesInTour(viewModel.prematchSubscribeList[0]);
          }
          if (viewModel.matchDetailsUnSubscribeList.length > 0 &&
              viewModel.matchDetailsUnSubscribeList.length !=
                  oldViewModel!.matchDetailsUnSubscribeList.length) {
            viewModel.matchDetailsUnSubscribeList.forEach((element) {
              unSubscribeMatchDetails(element);
            });
            widget.store.dispatch(RemovematchDetailsUnSubscribeListAction(
                matchDetailsUnSubscribeList: []));
          }

          if (viewModel.matchDetailsSubscribeList.length > 0 &&
              viewModel.matchDetailsSubscribeList.length !=
                  oldViewModel!.matchDetailsSubscribeList.length) {
            viewModel.matchDetailsSubscribeList.forEach((element) {
              subscribeMatchDetails(element);
            });
          }
          if (oldViewModel!.webSocketReConnect !=
              viewModel.webSocketReConnect) {
            homePage();
            subscribePrematchInfo();
            indexTournament = -1;
            indexCountry = -1;
            langChanged = false;
          }
        },
        builder: (context, state) {
          state.prematchInfo.sort((a, b) => a["id"].compareTo(b["id"]));
          return Scaffold(
              body: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: <Widget>[
              SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.all(5.0),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(isDense: true),
                                  value: activeCategory,
                                  dropdownColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  icon: Icon(Icons.keyboard_arrow_down,
                                      color: Colors.white),
                                  items: activeCategoryList
                                      .map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        getPeriodName(value),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    "All",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onChanged: (int? value) {
                                    changePeriod(value);
                                  },
                                )))),
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.prematchInfo.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return SportCategories(state.prematchInfo[index],
                              nextPage, changeSportIndex, index);
                        })
                  ])),
              indexSport == -1
                  ? SizedBox()
                  : SportCountries(
                      sportData: state.prematchInfo[indexSport]['countries'],
                      sportName: state.prematchInfo[indexSport]['name'],
                      nextPage: nextPage,
                      previousPage: previousPage,
                      changeCountryIndex: changeCountryIndex),
              indexCountry == -1
                  ? SizedBox()
                  : SportTournaments(
                      state.prematchInfo[indexSport]['countries'][indexCountry]
                          ['tournaments'],
                      state.prematchInfo[indexSport]['countries'][indexCountry]
                          ['name'],
                      nextPage,
                      previousPage,
                      changeTournamentIndex),
              indexTournament == -1
                  ? SizedBox()
                  : SportTournamentData(
                      sportData: state.prematchInfo[indexSport]['countries']
                          [indexCountry]['tournaments'][indexTournament],
                      previousPage: previousPage)
            ],
          ));
          /*ListView.builder(
                  itemCount: state.prematchInfo.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return SportCategories(state.prematchInfo[index]);
                  }));*/
        });
  }
}
