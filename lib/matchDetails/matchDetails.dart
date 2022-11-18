import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_betting_app/bsForm.dart';
import 'package:flutter_betting_app/matchDetails/matchDetailsRacesData.dart/matchDetailsDataPlace.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../login_page.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
//import 'redux/reducer.dart';
import '/redux/actions.dart';
//import 'dart:async';
import 'matchDetailsCategoriesFilter.dart';
import 'matchDetailsDataAll.dart';
import 'matchDetailsDataLong.dart';
import 'matchDetailsHeader.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../config/defaultConfig.dart' as config;
import 'matchDetailsRacesHeader.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

late var store;

class MatchDetails extends StatefulWidget {
  final sportData;
  final metaDataIndex;

  const MatchDetails({Key? key, this.sportData, this.metaDataIndex})
      : super(key: key);

  @override
  State<MatchDetails> createState() => MatchDetailsState();
}

class MatchDetailsState extends State<MatchDetails> {
  String activeGroup = 'ALL';
  bool liveStreamEnabled = false;
  String liveStreamUrl = "";

  void marketChange(val) {
    setState(() {
      activeGroup = val;
    });
  }

  void getLiveStreamUrl() async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = Uri(
        scheme: config.protocol,
        host: config.hostname,
        path: 'betting-api-gateway/user/rest/races/getRaceInfo',
      );

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          setState(() {
            liveStreamUrl = result['phenixEmbedUrl'];
          });
        } else {
          debugPrint('failed to load live stream data');
        }
      });
    }
  }

  toggleLiveStream() {
    if (!liveStreamEnabled && liveStreamUrl == "") {
      getLiveStreamUrl();
    }
    setState(() {
      liveStreamEnabled = !liveStreamEnabled;
    });
  }

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

  void generateSubscribe() {
    StoreProvider.of<AppState>(context).dispatch(
        SetMatchDetailsSubscribeListAction(
            matchDetailsSubscribeList: widget.sportData));
  }

  void generateUnSubscribe() {
    store
        .dispatch(RemoveMatchDetailsMatchDataAction(matchDetailsMatchData: []));
    store.dispatch(
        RemoveMatchDetailsBetDomainsAction(matchDetailsBetDomains: {}));
    store.dispatch(SetMatchDetailsUnSubscribeListAction(
        matchDetailsUnSubscribeList: widget.sportData));
    //Navigator.pop(context);
  }

  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) => generateSubscribe());
    if (widget.sportData['sport'] == "100" ||
        widget.sportData['sport'] == "101" && activeGroup == "ALL") {
      marketChange("BMG_SIS_WIN_PLACE");
    }

    super.initState();
  }

  @override
  void dispose() {
    generateUnSubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    store = StoreProvider.of<AppState>(context);
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (oldViewModel!.webSocketReConnect !=
                  viewModel.webSocketReConnect &&
              viewModel.matchDetailsMatchData.length == 0) {
            generateSubscribe();
          }
        },
        builder: (context, state) {
          List data = [];
          if (activeGroup != 'ALL' && state.matchDetailsMatchData.length > 0) {
            data = state.matchDetailsMatchData[0]['betdomainGroups']
                .where((e) => e['key'] == activeGroup)
                .toList();
          } else if (state.matchDetailsMatchData.length > 0) {
            data = state.matchDetailsMatchData[0]['betdomainGroups'];
          }
          double height = widget.metaDataIndex != -1 ? 280 : 170;
          return Scaffold(
              body: CustomScrollView(slivers: <Widget>[
                widget.sportData['sport'] != "100" &&
                        widget.sportData['sport'] != "101"
                    ? SliverAppBar(
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        backgroundColor: Color(0xFF0D5611),
                        expandedHeight: height,
                        collapsedHeight: height / 2,
                        floating: true,
                        pinned: true,
                        flexibleSpace: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          var top = constraints.biggest.height;

                          return state.matchDetailsMatchData.length > 0
                              ? Container(
                                  alignment: Alignment.bottomCenter,
                                  child: MatchDetailsHeader(
                                      state.matchDetailsMatchData[0],
                                      widget.metaDataIndex != -1
                                          ? state.liveMatchesMeta[
                                              widget.metaDataIndex]
                                          : null,
                                      top > (height - 10) ? false : true))
                              : SizedBox();
                        }))
                    : SliverAppBar(
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        backgroundColor: Color(0xFF0D5611),
                        expandedHeight: 90,
                        floating: true,
                        actions: <Widget>[
                          IconButton(
                            color: liveStreamEnabled
                                ? Theme.of(context).indicatorColor
                                : Theme.of(context).colorScheme.onPrimary,
                            icon: const Icon(Icons.play_circle),
                            onPressed: () {
                              !state.authorization
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                    )
                                  : toggleLiveStream();
                            },
                          )
                        ],
                        pinned: true,
                        flexibleSpace: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          var top = constraints.biggest.height;

                          return state.matchDetailsMatchData.length > 0
                              ? Container(
                                  alignment: Alignment.bottomCenter,
                                  child: widget.sportData['sport'] == "100" ||
                                          widget.sportData['sport'] == "101"
                                      ? MatchDetailsRacesHeader(
                                          state.matchDetailsMatchData[0],
                                          widget.metaDataIndex != -1
                                              ? state.liveMatchesMeta[
                                                  widget.metaDataIndex]
                                              : null,
                                          top > (height - 10) ? false : true)
                                      : MatchDetailsHeader(
                                          state.matchDetailsMatchData[0],
                                          widget.metaDataIndex != -1
                                              ? state.liveMatchesMeta[
                                                  widget.metaDataIndex]
                                              : null,
                                          top > (height - 10) ? false : true))
                              : SizedBox();
                        })),
                SliverPinnedHeader(
                    child: state.matchDetailsBetDomains.length > 0 &&
                            !config.enableLongGroups
                        ? widget.sportData['sport'] == "100" ||
                                widget.sportData['sport'] == "101"
                            ? Column(children: [
                                MatchDetailsGroupsFilter(
                                  groupsData: state.matchDetailsBetDomains,
                                  activeGroup: activeGroup,
                                  marketChange: (val) {
                                    marketChange(val);
                                  },
                                ),
                                state.authorization &&
                                        liveStreamEnabled &&
                                        liveStreamUrl != ""
                                    ? Container(
                                        height: 200,
                                        child: InAppWebView(
                                            initialUrlRequest: URLRequest(
                                                url: Uri.parse(liveStreamUrl))))
                                    : SizedBox(),
                              ])
                            : MatchDetailsGroupsFilter(
                                groupsData: state.matchDetailsBetDomains,
                                activeGroup: activeGroup,
                                marketChange: (val) {
                                  marketChange(val);
                                },
                              )
                        : SizedBox()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return !config.enableLongGroups
                          ? Container(
                              key: Key(activeGroup),
                              constraints: new BoxConstraints(
                                minHeight: 135.0,
                              ),
                              alignment: Alignment.center,
                              child: widget.sportData['sport'] == "100" ||
                                      widget.sportData['sport'] == "101"
                                  ? new MatchDetailsDataPlace(
                                      matchData: state.matchDetailsMatchData[0],
                                      index: index,
                                      group: data
                                          .where((element) =>
                                              element['key'] != 'BMG_OUTRIGHT' &&
                                              element['key'] != 'BMG_MAIN' &&
                                              element['key'] !=
                                                  'BMG_MAIN_EXT' &&
                                              element['key'] !=
                                                  'BMG_SIS_THREESOMES')
                                          .toList()[index],
                                      key: Key("${data[index]['key']}"))
                                  : new MatchDetailsDataAll(
                                      matchData: state.matchDetailsMatchData[0],
                                      index: index,
                                      group: data[index],
                                      key: Key("${data[index]['key']}")))
                          : new MatchDetailsDataLong(
                              matchData: state.matchDetailsMatchData[0],
                              index: index,
                              group: data[index],
                              key: Key("${data[index]['key']}"));
                    },
                    childCount:
                        data.length > 0 && widget.sportData['sport'] == "100" ||
                                widget.sportData['sport'] == "101"
                            ? 1
                            : data.length, // 1000 list items
                  ),
                ),
              ]),
              floatingActionButton: getArrayOdds().length > 0
                  ? Container(
                      child: FittedBox(
                        child: Stack(
                          alignment: Alignment(1.2, -1.1),
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) => BSForm()));
                              },
                              child: Icon(Icons.shopping_cart),
                            ),
                            Container(
                              child: Center(
                                child: Text(getArrayOdds().length.toString(),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                              ),
                              padding: EdgeInsets.all(4),
                              constraints:
                                  BoxConstraints(minHeight: 16, minWidth: 25),
                              decoration: BoxDecoration(
                                // This controls the shadow
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      color: Colors.black.withAlpha(50))
                                ],
                                borderRadius: BorderRadius.circular(16),
                                color: Colors
                                    .redAccent, // This would be color of the Badge
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null);
        });
  }
}
