import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
//import '../redux/reducer.dart';
import '../redux/actions.dart';
import 'dart:convert';
//import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
//import 'package:flutter_countdown_timer/index.dart';
import 'liveMatchTime.dart';
import 'liveOddsButton.dart';
import '../../matchDetails/matchDetails.dart';
import '../Utils/stomp.dart' as stomp;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class LiveMatch extends StatefulWidget {
  final store;
  final matchData;
  final index;
  final webSocketReConnect;
  const LiveMatch(
      {Key? key,
      this.store,
      this.matchData,
      this.index,
      this.webSocketReConnect})
      : super(key: key);

  @override
  State<LiveMatch> createState() => _LiveMatchState();
}

class _LiveMatchState extends State<LiveMatch> {
  dynamic unsubscribeLiveMatch;
  dynamic unsubscribeLiveMatchMeta;
  int matchDataIndex = -1;
  int metaDataIndex = -1;
  bool statusEnded = false;
  bool widgetOpacity = false;

  initState() {
    super.initState();
    subscribeLiveMatch();
    subscribeLiveMatchMeta();
  }

  @override
  void didUpdateWidget(LiveMatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.webSocketReConnect != oldWidget.webSocketReConnect) {
      subscribeLiveMatch();
      subscribeLiveMatchMeta();
    }

    if (matchDataIndex != -1 &&
        widget.store.state.liveMatches[matchDataIndex]['liveBetStatus'] == 17 &&
        statusEnded == false) {
      statusEnded = true;

      Future.delayed(const Duration(milliseconds: 20000), () {
        widgetOpacity = true;
      });

      Future.delayed(const Duration(milliseconds: 30000), () {
        widget.store.dispatch(RemoveliveInfoAction(
            liveInfo: {'matchId': widget.matchData['matchId'].toString()}));
      });
    }
  }

  @override
  void dispose() {
    if (unsubscribeLiveMatch != null) {
      unsubscribeLiveMatch(
          unsubscribeHeaders: {'id': widget.matchData['matchId'].toString()});
    }

    if (unsubscribeLiveMatchMeta != null) {
      unsubscribeLiveMatchMeta(unsubscribeHeaders: {
        'id': widget.matchData['matchId'].toString() + "_liveMeta"
      });
    }
    super.dispose();
  }

  subscribeLiveMatch() {
    unsubscribeLiveMatch = stomp.stompClient.subscribe(
      destination:
          '/matchs/${widget.matchData['sportId']}/${widget.matchData['matchId']}/BMG_MAIN',
      headers: {'id': widget.matchData['matchId'].toString()},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['match'] != null) {
          widget.store
              .dispatch(SetliveMatchesAction(liveMatches: result['match']));
        } else if (result['matchStatusMessage'] != null) {
          widget.store.dispatch(SetliveMatchesStatusAction(
              liveMatches: result['matchStatusMessage']));
        }
      },
    );
  }

  subscribeLiveMatchMeta() {
    unsubscribeLiveMatchMeta = stomp.stompClient.subscribe(
      destination:
          '/match/livemetadata/${widget.matchData['sportId']}/${widget.matchData['matchId']}',
      headers: {'id': widget.matchData['matchId'].toString() + "_liveMeta"},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['status'] != "not found") {
          widget.store.dispatch(SetliveMatchesMetaAction(
              liveMatchesMeta: result['matchLiveMetadata']));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          matchDataIndex = widget.store.state.liveMatches.indexWhere(
              (element) =>
                  element['matchId'].toString() == widget.matchData['matchId']);

          metaDataIndex = widget.store.state.liveMatchesMeta.indexWhere(
              (element) =>
                  element['matchId'].toString() == widget.matchData['matchId']);

          if (matchDataIndex > state.liveMatches.length - 1 &&
              matchDataIndex < 0) return const Offstage();

          String homeScore = metaDataIndex != -1
              ? state.liveMatchesMeta[metaDataIndex]['homeScore'].toString()
              : "";

          String awayScore = metaDataIndex != -1
              ? state.liveMatchesMeta[metaDataIndex]['awayScore'].toString()
              : "";

          Widget getHomeScorePeriods(List<dynamic> strings) {
            return new Row(
                children: metaDataIndex != -1
                    ? strings
                        .map((item) => new Container(
                            margin:
                                const EdgeInsets.only(left: 20.0),
                            child: Text(
                              item['homeScore'].toString(),
                            )))
                        .toList()
                    : []);
          }

          Widget getAwayScorePeriods(List<dynamic> strings) {
            return new Row(
                children: metaDataIndex != -1
                    ? strings
                        .map((item) => new Container(
                            margin:
                                const EdgeInsets.only(left: 20.0),
                            child: Text(
                              item['awayScore'].toString(),
                            )))
                        .toList()
                    : []);
          }

          Widget getOdds(List<dynamic> strings, betDomainId, matchId, status,
              betDomainNumber) {
            betDomainNumber == 566 || betDomainNumber == 234
                ? strings.sort(
                    (a, b) => a["information"].compareTo(b["information"]))
                : strings.sort((a, b) => a["sort"].compareTo(b["sort"]));
            return betDomainNumber == 3 ||
                    betDomainNumber == 566 ||
                    betDomainNumber == 550 ||
                    betDomainNumber == 234 ||
                    betDomainNumber == 256 ||
                    betDomainNumber == 257 ||
                    betDomainNumber == 259 ||
                    betDomainNumber == 260 ||
                    betDomainNumber == 261 ||
                    betDomainNumber == 262 ||
                    betDomainNumber == 263 ||
                    betDomainNumber == 264 ||
                    betDomainNumber == 231 ||
                    betDomainNumber == 253 ||
                    betDomainNumber == 568
                ? Wrap(
                    children: strings
                        .map((item) => new Container(
                            width: 100,
                            child: LiveOddsButton(
                                odds: item,
                                sportId: widget.matchData['sportId'],
                                matchId: matchId,
                                status: widget.matchData['liveBetStatus'],
                                betDomainStatus: status,
                                enabled: state.odds.length > 0 &&
                                    state.odds.any((element) =>
                                        element['oddId'] == item['oddId']),
                                disabled: state.odds.length > 0 &&
                                    state.odds.any((element) =>
                                        element['betDomainId'] != betDomainId &&
                                        element['match'] == matchId))))
                        .toList())
                : betDomainNumber == 258
                    ? Wrap(
                        children: strings
                            .map((item) => new Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: LiveOddsButton(
                                    odds: item,
                                    sportId: widget.matchData['sportId'],
                                    matchId: matchId,
                                    status: widget.matchData['liveBetStatus'],
                                    betDomainStatus: status,
                                    enabled: state.odds.length > 0 &&
                                        state.odds.any(
                                            (element) => element['oddId'] == item['oddId']),
                                    disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId))))
                            .toList())
                    : betDomainNumber == 576 || betDomainNumber == 575 || betDomainNumber == 577
                        ? Column(children: strings.map((item) => Container(child: LiveOddsButton(odds: item, sportId: widget.matchData['sportId'], matchId: matchId, status: widget.matchData['liveBetStatus'], betDomainStatus: status, enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']), disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))).toList())
                        : Row(children: strings.map((item) => new Expanded(child: LiveOddsButton(odds: item, sportId: widget.matchData['sportId'], matchId: matchId, status: widget.matchData['liveBetStatus'], betDomainStatus: status, enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']), disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))).toList());
          }

          Widget getMarkets(List<dynamic> strings) {
            strings.sort((a, b) => a["sort"].compareTo(b["sort"]));
            return new Column(
                children: strings
                    .map((item) => new Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 10.0),
                        child: Column(children: [
                          item['betdomainNumberCanBeCashout']
                              ? Stack(
                                  children: [
                                    Align(
                                        child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              item['discriminator'].toString(),
                                              textAlign: TextAlign.center,
                                            ))),
                                    Positioned(
                                        left: 0,
                                        child: Tooltip(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                              color:
                                                  Colors.grey.withOpacity(0.7)),
                                          message:
                                              LocaleKeys.marketCashout.tr(),
                                          child: Icon(Icons.monetization_on),
                                        )),
                                  ],
                                )
                              : Text(
                                  item['discriminator'].toString(),
                                  textAlign: TextAlign.center,
                                ),
                          getOdds(
                              item['odds'],
                              item['betDomainId'],
                              item['matchId'],
                              item['status'],
                              item['betDomainNumber'])
                        ])))
                    .toList());
          }

          return matchDataIndex != -1
              ? Opacity(
                  opacity: widgetOpacity ? 0.6 : 1,
                  child: Container(
                      //padding: EdgeInsets.all(8.0),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.all(8.0),
                          color: Colors.black87,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(flex: 1, child: SizedBox()),
                              Expanded(
                                  flex: 4,
                                  child: Text(
                                      state.liveMatches[matchDataIndex] != null
                                          ? state.liveMatches[matchDataIndex]
                                              ['tournamentName']
                                          : null,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.yellowAccent,
                                          fontSize: 15))),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      child: TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new MatchDetails(
                                                    key: Key(widget
                                                        .matchData['matchId']),
                                                    sportData: {
                                                      'sport': widget
                                                          .matchData['sportId'],
                                                      'country':
                                                          widget.matchData[
                                                              'countryId'],
                                                      'groups': ["BMG_MAIN"],
                                                      'tournament': state
                                                                  .liveMatches[
                                                              matchDataIndex]
                                                          ['tournamentId'],
                                                      'match': widget
                                                          .matchData['matchId'],
                                                    },
                                                    metaDataIndex:
                                                        metaDataIndex)),
                                      );
                                    },
                                    child: Text(
                                        '+${state.liveMatches[matchDataIndex]['betdomainSize'].toString()}',
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right),
                                  )))
                            ],
                          )),
                      LiveMatchTime(
                          metaDataIndex != -1
                              ? state.liveMatchesMeta[metaDataIndex]
                                  ['matchStatus']
                              : null,
                          state.liveMatches[matchDataIndex]['startDate'],
                          metaDataIndex != -1
                              ? state.liveMatchesMeta[metaDataIndex]
                                  ['eventTime']
                              : null,
                          state.liveMatches[matchDataIndex]['liveBetStatus'],
                          metaDataIndex != -1
                              ? state.liveMatchesMeta[metaDataIndex]
                                  ['matchStatusId']
                              : null,
                          statusEnded,
                          metaDataIndex != -1 &&
                                  state.liveMatchesMeta[metaDataIndex]
                                          ['stoppageTime'] !=
                                      null
                              ? state.liveMatchesMeta[metaDataIndex]
                                  ['stoppageTime']
                              : "",
                          metaDataIndex != -1 &&
                                  state.liveMatchesMeta[metaDataIndex]
                                          ['stoppageTimeAnnounced'] !=
                                      null
                              ? state.liveMatchesMeta[metaDataIndex]
                                  ['stoppageTimeAnnounced']
                              : ""),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                              state.liveMatches[
                                                          matchDataIndex] !=
                                                      null
                                                  ? state.liveMatches[
                                                          matchDataIndex]
                                                          ['matchName']
                                                      .split("vs.")[0]
                                                  : null,
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(
                                                      color: Theme.of(context)
                                                          .indicatorColor,
                                                      fontSize: 15))),
                                      Expanded(
                                          flex: 1,
                                          child: Text(homeScore,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .indicatorColor,
                                                  fontSize: 15))),
                                      Expanded(
                                          flex: 5,
                                          child: getHomeScorePeriods(
                                              metaDataIndex != -1
                                                  ? state.liveMatchesMeta[
                                                      metaDataIndex]['periods']
                                                  : []))
                                    ])),
                            Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                              state.liveMatches[
                                                          matchDataIndex] !=
                                                      null
                                                  ? state.liveMatches[
                                                          matchDataIndex]
                                                          ['matchName']
                                                      .split("vs.")[1]
                                                  : null,
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(
                                                      color: Theme.of(context)
                                                          .indicatorColor,
                                                      fontSize: 15))),
                                      Expanded(
                                          flex: 1,
                                          child: Text(awayScore,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .indicatorColor,
                                                  fontSize: 15))),
                                      Expanded(
                                          flex: 5,
                                          child: getAwayScorePeriods(
                                              metaDataIndex != -1
                                                  ? state.liveMatchesMeta[
                                                      metaDataIndex]['periods']
                                                  : []))
                                    ]))
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: getMarkets(
                                              state.liveMatches[matchDataIndex]
                                                  ['betdomains'])),
                                    ])),
                          ],
                        ),
                      ),
                    ],
                  )))
              : SizedBox();
        });
  }
}
