import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
//import '../redux/reducer.dart';
//import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
//import 'package:flutter_countdown_timer/index.dart';
import '../../live/liveOddsButton.dart';
import 'package:flutter_betting_app/popularMatches/popularOddButton.dart';
import 'package:intl/intl.dart';
import '../../matchDetails/matchDetails.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/defaultConfig.dart' as config;

class SportTournamentDataBody extends StatefulWidget {
  final matchData;
  final index;
  final betDomainsData;
  const SportTournamentDataBody(
      {Key? key, this.matchData, this.index, this.betDomainsData})
      : super(key: key);

  @override
  State<SportTournamentDataBody> createState() =>
      _SportTournamentDataBodyState();
}

class _SportTournamentDataBodyState extends State<SportTournamentDataBody> {
  bool widgetOpacity = false;
  String timeFormat = "";

  @override
  void didUpdateWidget(SportTournamentDataBody oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  correctScoreObject(list) {
    Map correctScoreObject = {'0': []};

    int counter = 0;
    list.forEach((e) {
      if (e["information"] == null ||
          e["information"][0] == counter.toString()) {
        correctScoreObject['$counter'].add(e);
      } else {
        correctScoreObject['${counter + 1}'] = [];
        correctScoreObject['${counter + 1}'].add(e);
        counter = counter + 1;
      }
    });
    return correctScoreObject;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = "MM/dd', 'h:mma";
          } else {
            timeFormat = "MM/dd', 'HH:mm";
          }

          Widget getOdds(List<dynamic> strings, betDomainId, matchId, status,
              betDomainNumber) {
            Map correctScoreObj = {};
            betDomainNumber == 566 || betDomainNumber == 234
                ? strings.sort(
                    (a, b) => a["information"].compareTo(b["information"]))
                : betDomainNumber == 575 ||
                        betDomainNumber == 576 ||
                        betDomainNumber == 577
                    ? strings.sort((a, b) => a["value"].compareTo(b["value"]))
                    : strings.sort((a, b) => a["sort"].compareTo(b["sort"]));
            if (betDomainNumber == 566) {
              correctScoreObj = correctScoreObject(strings);
            }
            return betDomainNumber == 3 ||
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
                        ? Column(children: strings.where((e) => e["value"] > 1).toList().map((item) => Container(child: LiveOddsButton(odds: item, sportId: widget.matchData['sportId'], matchId: matchId, status: widget.matchData['liveBetStatus'], betDomainStatus: status, enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']), disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))).toList())
                        : betDomainNumber == 566
                            ? Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                for (var k in correctScoreObj.keys)
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: correctScoreObj[k]
                                          .map<Widget>((item) => DefaultTextStyle(
                                              style: TextStyle(fontSize: 10),
                                              child: Container(
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.12),
                                                  child: PopularOddButton(
                                                      odds: item,
                                                      sportId: widget
                                                              .matchData['sportId'],
                                                      matchId: matchId,
                                                      status: widget
                                                          .matchData['liveBetStatus'],
                                                      betDomainStatus: status,
                                                      enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']),
                                                      disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))))
                                          .toList())
                              ])
                            : Row(children: strings.map((item) => new Expanded(child: LiveOddsButton(odds: item, sportId: widget.matchData['sportId'], matchId: matchId, status: widget.matchData['liveBetStatus'], betDomainStatus: status, enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']), disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))).toList());
          }

          Widget getMarkets(List<dynamic> strings) {
            strings.sort((a, b) {
              int sort = a["sort"].compareTo(b["sort"]);
              if (sort != 0) return sort;
              if (a['specialOddValueMap'].isNotEmpty &&
                  b['specialOddValueMap'].isNotEmpty) {
                return a['specialOddValueMap']
                    .values
                    .first
                    .compareTo(b['specialOddValueMap'].values.first);
              }
              return 0;
            });
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
                                          child: Icon(
                                            Icons.monetization_on,
                                          ),
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

          if (widget.matchData != null) {
            widget.matchData['matchtocompetitors']
                .sort((a, b) => a["homeTeam"].compareTo(b["homeTeam"]) as int);
          }

          return Opacity(
              opacity: widgetOpacity ? 0.6 : 1,
              child: Container(
                  //padding: EdgeInsets.all(8.0),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: EdgeInsets.all(8.0),
                      color: Theme.of(context).colorScheme.onBackground,
                      child: new Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: Text(
                                    DateFormat(timeFormat)
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                widget.matchData['startDate']))
                                        .toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12))),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: double.infinity,
                              child: new Text(
                                  '${widget.matchData['matchtocompetitors'][0]['competitor']['defaultName']}' +
                                      ' vs ' +
                                      '${widget.matchData['matchtocompetitors'][1]['competitor']['defaultName']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).indicatorColor,
                                      fontSize: 15)),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: const EdgeInsets.only(left: 30.0),
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
                                      MaterialPageRoute(
                                          builder: (context) => MatchDetails(
                                                key: Key(widget
                                                    .matchData['matchId']
                                                    .toString()),
                                                sportData: {
                                                  'sport': widget
                                                      .matchData['sportId'],
                                                  'country': state
                                                          .prematchBetdomainsGroup[
                                                      0]['country'],
                                                  'groups': ["BMG_MAIN"],
                                                  'tournament': state
                                                          .prematchBetdomainsGroup[
                                                      0]['tournament'],
                                                  'match': widget
                                                      .matchData['matchId'],
                                                      
                                                },
                                                metaDataIndex: -1
                                              )),
                                    );
                                  },
                                  child: Text(
                                      '+${widget.matchData['betdomainSize'].toString()}',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right),
                                )),
                          ),
                        ],
                      ))),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: getMarkets(widget.betDomainsData)),
                                ])),
                      ],
                    ),
                  ),
                ],
              )));
        });
  }
}
