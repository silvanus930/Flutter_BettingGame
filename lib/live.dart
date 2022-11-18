import 'Utils/loginAction.dart';
import '../config/defaultConfig.dart' as config;
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/live/liveMatches.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'redux/app_state.dart';
import 'redux/actions.dart';
import 'dart:convert';
import 'drawerWidget/MyDrawer.dart';
import 'drawerWidget/MyDrawerUnAuth.dart';
import 'Utils/stomp.dart' as stomp;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class Live extends StatefulWidget {
  final store;
  const Live({Key? key, this.store}) : super(key: key);

  @override
  State<Live> createState() => _LiveState();
}

class _LiveState extends State<Live> {
  dynamic unsubscribeLiveInfo;
  dynamic unsubscribeMatchDetailsData;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int selectedSportId = -1;

  List liveInfoList = [];

  void onTabTapped(int index, List matches) {
    if (index != -1) {
      setState(() {
        int countryId = widget.store.state.liveInfoCommon
            .firstWhere((e) => e['id'] == index)['countries'][0]['id'];
        liveInfoList.addAll(matches.where((i) =>
            i['sportId'] == index.toString() &&
            i['countryId'] == countryId.toString()));
      });
    } else {
      setState(() {
        liveInfoList.addAll(matches);
      });
    }
    setState(() {
      selectedSportId = index;
    });
  }

  void onTabTappedCountry(int index, List matches) {
    setState(() {
      liveInfoList.addAll(matches.where((i) =>
          i['sportId'] == selectedSportId.toString() &&
          i['countryId'] == index.toString()));
    });
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
          /*widget.store.dispatch(RemoveMatchDetailsSubscribeListAction(
              matchDetailsSubscribeList: newSubscribe));*/
        },
      );
    }
  }

  subscribeLiveInfo() {
    unsubscribeLiveInfo = stomp.stompClient.subscribe(
      destination: '/live',
      headers: {'id': 'liveInfo'},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['sportCategories'] != null) {
          widget.store
              .dispatch(SetliveInfoAction(liveInfo: result['sportCategories']));
          widget.store.dispatch(SetliveInfoCommonAction(
              liveInfoCommon: result['sportCategories']));
        }
      },
    );
  }

  initState() {
    super.initState();
    if (stomp.stompClient.connected) {
      subscribeLiveInfo();
    }
  }

  @override
  void dispose() {
    if (unsubscribeLiveInfo != null) {
      unsubscribeLiveInfo(unsubscribeHeaders: {'id': 'liveInfo'});
    }
    widget.store.dispatch(RemoveliveInfoCommonAction(liveInfoCommon: []));
    super.dispose();
    //debugPrint("disconnect");
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
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
            subscribeLiveInfo();
          }
        },
        builder: (context, state) {
          selectedSportId != -1 && liveInfoList.length > 0
              ? liveInfoList.sort((a, b) {
                  int date = a["startDate"].compareTo(b["startDate"]);
                  if (date != 0) return date;
                  return int.parse(a['matchId'])
                      .compareTo(int.parse(b['matchId']));
                })
              : state.liveInfo.sort((a, b) {
                  int sport = a["sportId"].compareTo(b["sportId"]);
                  if (sport != 0) return sport;
                  int date = a["startDate"].compareTo(b["startDate"]);
                  if (date != 0) return date;
                  return a['matchId'].compareTo(b['matchId']);
                });
          return state.liveInfo.length > 0 && state.liveInfoCommon.length > 0
              ? DefaultTabController(
                  length: state.liveInfoCommon.length + 1,
                  child: Scaffold(
                    key: _scaffoldKey,
                    appBar: AppBar(
                        title: Image.asset(
                            config.imageLocation + "logo/logo_header.png",
                            fit: BoxFit.contain,
                            height: 32),
                        leading: new IconButton(
                            icon: new Icon(Icons.menu),
                            onPressed: () =>
                                {_scaffoldKey.currentState!.openDrawer()}),
                        actions: <Widget>[LoginAction()],
                        bottom: TabBar(
                          onTap: (index) {
                            setState(() {
                              liveInfoList.clear();
                            });
                            onTabTapped(
                                index != 0
                                    ? state.liveInfoCommon[index - 1]['id']
                                    : -1,
                                state.liveInfo);
                          },
                          indicatorColor: Colors.white,
                          isScrollable: true,
                          tabs: [
                            Tab(
                                icon: Icon(Icons.emoji_events),
                                child: Column(children: [
                                  Text(LocaleKeys.allSports.tr()),
                                  Text((state.liveInfoCommon.length > 1
                                      ? state.liveInfoCommon
                                          .reduce((value, element) => value
                                                  is int
                                              ? value
                                              : value['size'] + element['size'])
                                          .toString()
                                      : state.liveInfoCommon.length > 0
                                          ? state.liveInfoCommon
                                              .reduce((value, element) => value
                                                      is int
                                                  ? value
                                                  : value['size'] +
                                                      element['size'])['size']
                                              .toString()
                                          : ""))
                                ])),
                            for (final tab in state.liveInfoCommon)
                              Tab(
                                  icon: Icon(tab['id'] == 5
                                      ? Icons.sports_tennis
                                      : Icons.sports_soccer),
                                  child: Column(children: [
                                    Text(tab['name']),
                                    Text(tab['size'].toString())
                                  ])),
                          ],
                        )),
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        selectedSportId != -1
                            ? DefaultTabController(
                                key: Key(selectedSportId.toString()),
                                initialIndex: 0,
                                length: state.liveInfoCommon
                                    .firstWhere((sport) =>
                                        sport['id'] ==
                                        selectedSportId)['countries']
                                    .length, // length of tabs
                                child: Container(
                                  height: 50,
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TabBar(
                                        onTap: (index) {
                                          setState(() {
                                            liveInfoList.clear();
                                          });
                                          onTabTappedCountry(
                                              state.liveInfoCommon.firstWhere(
                                                      (sport) =>
                                                          sport['id'] ==
                                                          selectedSportId)[
                                                  'countries'][index]['id'],
                                              state.liveInfo);
                                        },
                                        isScrollable: true,
                                        labelColor: Colors.white,
                                        unselectedLabelColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        indicator: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background),
                                        tabs: [
                                          for (final tab in state.liveInfoCommon
                                              .firstWhere((sport) =>
                                                  sport['id'] ==
                                                  selectedSportId)['countries'])
                                            Tab(text: tab['name'])
                                        ],
                                      )),
                                ))
                            : SizedBox(height: 0),
                        Expanded(
                            child: Container(
                          child: state.liveInfo.length > 0 ||
                                  liveInfoList.length > 0
                              ? ListView.builder(
                                  itemCount: selectedSportId == -1
                                      ? state.liveInfo.length
                                      : liveInfoList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return Container(
                                      key: Key(
                                          "${selectedSportId == -1 ? state.liveInfo[index]['matchId'] : liveInfoList[index]['matchId']}"),
                                      constraints: new BoxConstraints(
                                        minHeight: 150.0,
                                        minWidth: 5.0,
                                      ),
                                      alignment: Alignment.center,
                                      child: state.liveInfo.length > 0
                                          ? new LiveMatch(
                                              store: widget.store,
                                              matchData: selectedSportId == -1
                                                  ? state.liveInfo[index]
                                                  : liveInfoList[index],
                                              index: index,
                                              webSocketReConnect:
                                                  state.webSocketReConnect,
                                              key: Key(
                                                  "${selectedSportId == -1 ? state.liveInfo[index]['matchId'] : liveInfoList[index]['matchId']}"))
                                          : Text(LocaleKeys.empty.tr()),
                                    );
                                  })
                              : null,
                        ))
                      ],
                    ),
                    drawer:
                        !state.authorization ? MyDrawerUnAuth() : MyDrawer(),
                  ))
              : Center(child: CircularProgressIndicator());
        });
  }
}
