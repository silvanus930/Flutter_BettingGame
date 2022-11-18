import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
//import 'dart:developer';
import '/redux/actions.dart';
//import 'dart:async';
import 'dart:convert';
import 'popularMatch.dart';
import 'popularMatchesFilter.dart';
import '../config/defaultConfig.dart' as config;
import 'package:jiffy/jiffy.dart';
import '../Utils/stomp.dart' as stomp;
import 'package:carousel_slider/carousel_slider.dart';
import '../Utils/animatiedClip.dart';

class PopularMatches extends StatefulWidget {
  final store;

  const PopularMatches({Key? key, this.store}) : super(key: key);

  @override
  PopularMatchesState createState() => PopularMatchesState();
}

class PopularMatchesState extends State<PopularMatches> {
  dynamic unsubscribePopularMatchesData;
  dynamic unsubscribePopularMatchesMetaData;
  dynamic unsubscribeMatchDetailsData;
  int count = 1;
  int imgCount = 0;
  bool periodChnaged = false;
  bool sportChanged = false;
  String market = config.popularMatchesGroups[1]![0]['key'].toString();
  int sportId = 1;
  int from = DateTime.now().toUtc().millisecondsSinceEpoch;
  int to = DateTime.now()
      .toUtc()
      .add(const Duration(days: 30))
      .millisecondsSinceEpoch;
  bool update = false;
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;

  void unSubscribePopularMatches() {
    unsubscribePopularMatchesData(
        unsubscribeHeaders: {'id': 'popular_matches_list'});
  }

  void unSubscribePopularMatchesMeta() {
    unsubscribePopularMatchesMetaData(
        unsubscribeHeaders: {'id': 'popular_matches_list_meta'});
  }

  void subscribePopularMatchesData() {
    if (stomp.stompClient.connected) {
      if (unsubscribePopularMatchesData != null) {
        unSubscribePopularMatches();
      }
      if (unsubscribePopularMatchesMetaData != null) {
        unSubscribePopularMatchesMeta();
      }

      unsubscribePopularMatchesData = stomp.stompClient.subscribe(
          destination: '/matchLine/feed/$market',
          headers: {'id': 'popular_matches_list', "sportIds": '$sportId'},
          callback: (frame) {
            var result = jsonDecode(frame.body!);
            !update
                ? subscribeMatchListMoreCallback(result)
                : subscribeMatchListGroupCallback(result);
          });
      String betDomains = config.popularMatchesGroups[sportId].map((e) {
        return e['key'];
      }).join(",");
      unsubscribePopularMatchesMetaData = stomp.stompClient.subscribe(
          destination: '/matchLine/meta',
          headers: {
            'id': 'popular_matches_list_meta',
            "betdomainGroups": betDomains
          },
          callback: (frame) {
            var result = jsonDecode(frame.body!);
            subscribeMetaDataCallback(result);
          });
    }
  }

  subscribeMetaDataCallback(data) {
    if (data['status'] != null && data['status'] == "not found") {
      return;
    } else {
      widget.store.dispatch(SetPopularMatchesMetaDataAction(
          popularMatchesMetaData: [
            data['groups'],
            data['availableSportIds'],
            data['sports']
          ]));
    }
  }

  void subscribeMatchListMoreCallback(data) {
    List popularMatches = widget.store.state.popularMatchesData;
    String destinationMore = '/matchLine/$market/more';
    int requestCount = count;
    setState(() {
      count = count - 1;
    });
    List matches = [];

    if (popularMatches.length > 0 && !periodChnaged) {
      popularMatches.forEach((e) {
        matches.add(e['matchId']);
      });
    }

    if (data != null) {
      if (data['matchStatusMessage'] != null) {
        if (data['matchStatusMessage']['status'] > 1) {
          widget.store.dispatch(RemoveMatchPopularMatchesDataAction(
              popularMatchesData: data['matchStatusMessage']['matchId']));
        }
      }
      if (data['matchList'] != null &&
          (popularMatches.length == 0 || periodChnaged || sportChanged)) {
        widget.store.dispatch(SetpPopularMatchesDataAction(
            popularMatchesData: data['matchList']));
        setState(() {
          periodChnaged = false;
          sportChanged = false;
        });
      } else if (data['matchList'] != null && popularMatches.length > 0) {
        widget.store.dispatch(UpdatePopularMatchesDataAction(
            popularMatchesData: data['matchList']));
      }
      if (data['match'] != null && popularMatches.length > 0) {
        widget.store.dispatch(UpdatePopularMatchesDataAction(
            popularMatchesData: [data['match']]));
      }
    }
    if (requestCount <= 0) {
      return;
    }

    stomp.stompClient.send(
      destination: destinationMore,
      body: json.encode({
        'holdMatchIds': matches,
        'holdMaxStartDate': from,
        'holdMinStartDate': from,
        'count': '10',
        'dateDirection': 'later'
      }),
    );
  }

  void subscribeMatchListGroupCallback(data) {
    List popularMatches = widget.store.state.popularMatchesData;
    String destinationGroupChanged = '/matchLine/$market/afterGroupChange';
    int requestCount = count;
    setState(() {
      count = count - 1;
    });
    List matches = [];

    if (popularMatches.length > 0) {
      popularMatches.forEach((e) {
        matches.add(e['matchId']);
      });
    }

    if (data != null) {
      if (data['matchList'] != null && popularMatches.length == 0) {
        widget.store.dispatch(SetpPopularMatchesDataAction(
            popularMatchesData: data['matchList']));
        setState(() {
          update = false;
        });
      } else if (data['matchList'] != null && popularMatches.length > 0) {
        widget.store.dispatch(UpdatePopularMatchesDataAction(
            popularMatchesData: data['matchList']));
      }
      setState(() {
        update = false;
      });
    }
    if (requestCount <= 0) {
      return;
    }

    stomp.stompClient.send(
      destination: destinationGroupChanged,
      body: json.encode({
        'matchIds': matches,
        'maxStartDate': DateTime.now().millisecondsSinceEpoch,
        'minStartDate': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  void addMoreMatches() {
    setState(() {
      count = 1;
    });
    subscribeMatchListMoreCallback(null);
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

  void sportChange(int newSportId) {
    setState(() {
      count = 1;
      sportId = newSportId;
      sportChanged = true;
    });
    subscribePopularMatchesData();
  }

  void sportGroupChange(int newSportId, String newMarket) {
    setState(() {
      count = 1;
      sportId = newSportId;
      market = newMarket;
      sportChanged = true;
    });
    subscribePopularMatchesData();
  }

  void preiodChange(int period) {
    var newPeriod = 0;
    if (period == 1) {
      newPeriod = DateTime.now().toUtc().millisecondsSinceEpoch;
    } else {
      newPeriod = Jiffy()
          .add(duration: Duration(days: 1))
          .startOf(Units.DAY)
          .dateTime
          .millisecondsSinceEpoch;
    }

    setState(() {
      count = 1;
      from = newPeriod;
      periodChnaged = true;
    });
    subscribePopularMatchesData();
  }

  void marketChange(String newMarket) {
    setState(() {
      count = 1;
      market = newMarket;
      update = true;
    });
    subscribePopularMatchesData();
  }

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  initState() {
    super.initState();
    if (stomp.stompClient.connected) {
      subscribePopularMatchesData();
    }
    if (config.showSlides) {
      getImages();
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void didUpdateWidget(PopularMatches oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    if (unsubscribePopularMatchesData != null) {
      unsubscribePopularMatchesData(
          unsubscribeHeaders: {'id': 'popular_matches_list'});
    }
    if (unsubscribePopularMatchesData != null) {
      unsubscribePopularMatchesData(
          unsubscribeHeaders: {'id': 'popular_matches_list_meta'});
    }
    widget.store
        .dispatch(RemovePopularMatchesDataAction(popularMatchesData: []));
    widget.store.dispatch(
        RemovePopularMatchesMetaDataAction(popularMatchesMetaData: []));

    super.dispose();
  }

  getImages() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    int images = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith(config.imageLocation + 'slides/' +
              context.locale.toString()))
        .length;
    setState(() {
      imgCount = images;
    });
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
            setState(() {
              update = true;
            });
            subscribePopularMatchesData();
            addMoreMatches();
          }
        },
        builder: (context, state) {
          int currentBetDomain = -1;
          if (state.popularMatchesMetaData.length > 0) {
            currentBetDomain = int.parse(state.popularMatchesMetaData[0]
                .firstWhere((e) => e['key'] == market)['betdomainNumbers'][0]);
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
                              "slides/" + context.locale.toString() + "/${itemIndex + 1}.png"),
                        ),
                      ))
                  : SizedBox(),
              state.popularMatchesMetaData.length > 2
                  ? PopularMatchesFilter(
                      currentSportId: sportId,
                      currentMarket: market,
                      metaData: state.popularMatchesMetaData,
                      sportGroupChange: (id, newMarket) {
                        sportGroupChange(id, newMarket);
                      },
                      marketChange: (val) {
                        marketChange(val);
                      },
                      preiodChange: (val) {
                        preiodChange(val);
                      },
                      sportChange: (val) {
                        sportChange(val);
                      },
                    )
                  : SizedBox(),
              state.popularMatchesData.length > 0
                  ? Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.popularMatchesData.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Container(
                                key: Key(
                                    "${state.popularMatchesData[index]['matchId']}"),
                                constraints: new BoxConstraints(
                                  minHeight: 50.0,
                                  minWidth: 200.0,
                                ),
                                alignment: Alignment.center,
                                child: new PopularMatch(
                                    matchData: state.popularMatchesData[index],
                                    index: index,
                                    betDomainsData:
                                        state.popularMatchesData[index]
                                            ['betdomains'],
                                    key: Key(
                                        "${state.popularMatchesData[index]['matchId']}"),
                                    addMoreMatches: () {
                                      addMoreMatches();
                                    },
                                    matchesCount:
                                        state.popularMatchesData.length,
                                    currentBetDomainId: currentBetDomain));
                          }))
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ]),
          );
        });
  }
}
