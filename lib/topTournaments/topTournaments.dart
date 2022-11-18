import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/actions.dart';
import 'dart:convert';
import 'topTournamentData.dart';
import '../Utils/stomp.dart' as stomp;
import '../config/defaultConfig.dart' as config;
import 'package:carousel_slider/carousel_slider.dart';
import '../Utils/animatiedClip.dart';

class TopTournaments extends StatefulWidget {
  final store;

  const TopTournaments({Key? key, this.store}) : super(key: key);

  @override
  TopTournamentsState createState() => TopTournamentsState();
}

class TopTournamentsState extends State<TopTournaments> {
  dynamic unsubscribeTopTorunamentsInfo;
  dynamic unsubscribeTopTorunamentsData;
  dynamic unsubscribeMatchDetailsData;
  int imgCount = 0;
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;

  void unSubscribeTopData() {
    unsubscribeTopTorunamentsData(
        unsubscribeHeaders: {'id': 'topTournamentData'});
  }

  void subscribeTopTorunamentsData(selectedTournament) {
    if (stomp.stompClient.connected) {
      if (unsubscribeTopTorunamentsData != null) {
        unSubscribeTopData();
      }
      if (selectedTournament.isEmpty) {
        return;
      }

      unsubscribeTopTorunamentsData = stomp.stompClient.subscribe(
          destination:
              '/topTournamentCategory/${selectedTournament['sportId']}/${selectedTournament['categoryId']}/BMG_MAIN',
          headers: {'id': 'topTournamentData'},
          callback: (frame) {
            var result = jsonDecode(frame.body!);
            if (frame.body == "not found") {
              widget.store.dispatch(RemoveSelectedTopTournamentDataAction(
                  selectedTopTournamentData: {}));
            }
            if (result['tournamentDto'] != null) {
              Map newData = {};
              newData['sport'] =
                  result['tournamentDto']['sport']['defaultName'];
              newData['tournament'] = result['tournamentDto'];

              widget.store.dispatch(UpdateSelectedTopTournamentMatchDataAction(
                  selectedTopTournamentData: newData));
              return;
            }
            if (result != null && result['betdomainStatusMessage'] != null) {
              widget.store.dispatch(
                  UpdateSelectedTopTournamentBetDomainStatusDataAction(
                      selectedTopTournamentData:
                          result['betdomainStatusMessage']));

              return;
            }

            if (result != null &&
                result['tournament'] != null &&
                result['tournament']['tournamentId'] != null) {
              if (selectedTournament.isNotEmpty &&
                  widget.store.state.selectedTopTournamentData.isEmpty) {
                result['tournament']['country'] =
                    selectedTournament['countryId'];
                widget.store.dispatch(SetSelectedTopTournamentDataAction(
                    selectedTopTournamentData: result['tournament']));
                return;
              }
              if (selectedTournament.isNotEmpty &&
                  widget.store.state.selectedTopTournamentData.isNotEmpty) {
                Map newData = {};
                newData['sport'] = result['tournament']['sport']['defaultName'];
                newData['tournament'] = result['tournament'];

                widget.store.dispatch(
                    UpdateSelectedTopTournamentMatchDataAction(
                        selectedTopTournamentData: newData['tournament']));
                return;
              }
            }
          });
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
          /*widget.store.dispatch(RemoveMatchDetailsSubscribeListAction(
              matchDetailsSubscribeList: newSubscribe));*/
        },
      );
    }
  }

  onTabTappedTournament(selectedTournament) {
    if (selectedTournament['tournamentId'] !=
        widget.store.state.selectedTopTournament['tournamentId']) {
      widget.store.dispatch(
          RemoveSelectedTopTournamentDataAction(selectedTopTournamentData: {}));
      widget.store.dispatch(SetSelectedTopTournamentAction(
          selectedTopTournament: selectedTournament));
    }
  }

  subscribeTopTournamentsInfo() {
    unsubscribeTopTorunamentsInfo = stomp.stompClient.subscribe(
      destination: '/topTournaments',
      headers: {'id': 'topTorunamentsInfo'},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['topTournaments'] != null) {
          result['topTournaments']
              .sort((a, b) => a["sort"].compareTo(b["sort"]) as int);
          widget.store.dispatch(SetTopTournamentListAction(
              topTournamentList: result['topTournaments']));
        }
      },
    );
  }

  getImages() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    int images = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith(config.imageLocation + 'slides'))
        .length;
    setState(() {
      imgCount = images;
    });
  }

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  initState() {
    super.initState();
    if (stomp.stompClient.connected) {
      subscribeTopTournamentsInfo();
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    if (config.showSlides) {
      getImages();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (unsubscribeTopTorunamentsInfo != null) {
      unsubscribeTopTorunamentsInfo(
          unsubscribeHeaders: {'id': 'topTorunamentsInfo'});
    }
    if (unsubscribeTopTorunamentsData != null) {
      unsubscribeTopTorunamentsData(
          unsubscribeHeaders: {'id': 'topTournamentData'});
    }
    widget.store.dispatch(RemoveTopTournamentListAction(topTournamentList: []));
    widget.store
        .dispatch(RemoveSelectedTopTournamentAction(selectedTopTournament: {}));
    widget.store.dispatch(
        RemoveSelectedTopTournamentDataAction(selectedTopTournamentData: {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (oldViewModel!.topTournamentList.length == 0 &&
              viewModel.topTournamentList.length > 0) {
            onTabTappedTournament(viewModel.topTournamentList[0]);
          }

          if (viewModel.selectedTopTournament.isNotEmpty &&
                  oldViewModel.selectedTopTournament.isEmpty ||
              viewModel.selectedTopTournament.isNotEmpty &&
                  oldViewModel.selectedTopTournament['tournamentId'] !=
                      viewModel.selectedTopTournament['tournamentId']) {
            subscribeTopTorunamentsData(viewModel.selectedTopTournament);
          }

          if (oldViewModel.selectedTopTournament.isNotEmpty &&
              viewModel.selectedTopTournament.isEmpty) {
            unSubscribeTopData();
          }

          if (viewModel.matchDetailsUnSubscribeList.length > 0 &&
              viewModel.matchDetailsUnSubscribeList.length !=
                  oldViewModel.matchDetailsUnSubscribeList.length) {
            viewModel.matchDetailsUnSubscribeList.forEach((element) {
              unSubscribeMatchDetails(element);
            });
            widget.store.dispatch(RemovematchDetailsUnSubscribeListAction(
                matchDetailsUnSubscribeList: []));
          }

          if (viewModel.matchDetailsSubscribeList.length > 0 &&
              viewModel.matchDetailsSubscribeList.length !=
                  oldViewModel.matchDetailsSubscribeList.length) {
            viewModel.matchDetailsSubscribeList.forEach((element) {
              subscribeMatchDetails(element);
            });
          }
          if (oldViewModel.webSocketReConnect != viewModel.webSocketReConnect) {
            subscribeTopTournamentsInfo();
            if (viewModel.selectedTopTournament.isNotEmpty) {
              subscribeTopTorunamentsData(viewModel.selectedTopTournament);
            }
          }
        },
        builder: (context, state) {
          if (state.selectedTopTournamentData.isNotEmpty &&
              state.selectedTopTournamentData['matchs'].length > 0) {
            state.selectedTopTournamentData['matchs'].sort(
                (a, b) => a["startDate"].compareTo(b["startDate"]) as int);
          }
          return Scaffold(
            body: Column(children: [
              config.showSlides
                  ? AnimatedClipRect(
                      open: _scrollPosition < 10,
                      horizontalAnimation: false,
                      verticalAnimation: true,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      reverseCurve: Curves.easeIn,
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          autoPlay: true,
                          initialPage: 0,
                          aspectRatio: 16 / 4,
                          viewportFraction: 1,
                          enlargeCenterPage: true,
                        ),
                        itemCount: imgCount,
                        itemBuilder: (BuildContext context, int itemIndex,
                                int pageViewIndex) =>
                            Container(
                          child: Image.asset(config.imageLocation +
                              "slides/${itemIndex + 1}.png"),
                        ),
                      ))
                  : SizedBox(),
              state.topTournamentList.length > 0
                  ? DefaultTabController(
                      initialIndex: 0,
                      length: state.topTournamentList.length, // length of tabs
                      child: Container(
                        color: Theme.of(context).colorScheme.onBackground,
                        height: 95,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: TabBar(
                              labelPadding: EdgeInsets.all(5),
                              onTap: (index) {
                                onTabTappedTournament(
                                    state.topTournamentList[index]);
                              },
                              isScrollable: true,
                              indicatorColor: Colors.transparent,
                              labelColor: Theme.of(context).indicatorColor,
                              unselectedLabelColor:
                                  Colors.white.withOpacity(0.6),
                              tabs: [
                                for (final tab in state.topTournamentList)
                                  Container(
                                      alignment: Alignment.center,
                                      width: 60,
                                      height: 95,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                flex: 5,
                                                child: Container(
                                                    height: 45,
                                                    padding:
                                                        EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomRight,
                                                        end: Alignment.topLeft,
                                                        stops: [0.2, 1],
                                                        colors: [
                                                          Color(0xFF1F1111),
                                                          Color(0xFF1F2320),
                                                        ],
                                                      ),
                                                      border: new Border.all(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                    ),
                                                    child: Image.asset(
                                                      'assets/images/top-tournament/${tab['categoryId']}.png',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/images/top-tournament/x.png',
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ))),
                                            Expanded(
                                                flex: 4,
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      tab['categoryName'],
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )))
                                          ]))
                              ],
                            )),
                      ))
                  : SizedBox(),
              state.selectedTopTournamentData.isNotEmpty &&
                      state.selectedTopTournamentData['matchs'].length > 0
                  ? Expanded(
                      child: ListView.builder(
                          itemCount:
                              state.selectedTopTournamentData['matchs'].length,
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Container(
                                margin: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ]),
                                key: Key(
                                    "${state.selectedTopTournamentData['matchs'][index]['matchId']}"),
                                constraints: new BoxConstraints(
                                  minHeight: 150.0,
                                  minWidth: 100,
                                ),
                                alignment: Alignment.center,
                                child: Card(
                                    child: new TopTournamentDataBody(
                                        matchData:
                                            state.selectedTopTournamentData[
                                                'matchs'][index],
                                        index: index,
                                        betDomainsData:
                                            state.selectedTopTournamentData[
                                                'matchs'][index]['betdomains'],
                                        key: Key(
                                            "${state.selectedTopTournamentData['matchs'][index]['matchId']}"))));
                          }))
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ]),
          );
          /*ListView.builder(
                  itemCount: state.prematchInfo.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return SportCategories(state.prematchInfo[index]);
                  }));*/
        });
  }
}
