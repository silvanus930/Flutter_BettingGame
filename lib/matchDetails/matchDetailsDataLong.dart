import 'package:flutter/material.dart';
import 'package:flutter_betting_app/popularMatches/popularOddButton.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import '/redux/actions.dart';
import '../../live/liveOddsButton.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

late var store;

class MatchDetailsDataLong extends StatefulWidget {
  final matchData;
  final index;
  final group;

  const MatchDetailsDataLong(
      {Key? key, this.matchData, this.index, this.group})
      : super(key: key);

  @override
  State<MatchDetailsDataLong> createState() => _MatchDetailsDataLongState();
}

class _MatchDetailsDataLongState extends State<MatchDetailsDataLong>
    with AutomaticKeepAliveClientMixin {
  bool widgetOpacity = false;

  void generateSubscribe() {
    final Map subscribe = {};
    subscribe["sport"] = widget.matchData['sport']['sportId'];
    subscribe["country"] = widget.matchData['country'];
    subscribe["groups"] = [widget.group['key']];
    subscribe["tournament"] = widget.matchData['tournamentId'];
    subscribe["match"] = widget.matchData['matchId'];

    store.dispatch(SetMatchDetailsSubscribeListAction(
        matchDetailsSubscribeList: subscribe));
  }

  void generateUnSubscribe() {
    final Map subscribe = {};
    subscribe["sport"] = widget.matchData['sport']['sportId'];
    subscribe["country"] = widget.matchData['country'];
    subscribe["groups"] = [widget.group['key']];
    subscribe["tournament"] = widget.matchData['tournamentId'];
    subscribe["match"] = widget.matchData['matchId'];

    store.dispatch(SetMatchDetailsUnSubscribeListAction(
        matchDetailsUnSubscribeList: subscribe));

    /*StoreProvider.of<AppState>(context)
        .dispatch(RemovePrematchBetDomainsAction(prematchBetDomains: {}));

    StoreProvider.of<AppState>(context).dispatch(
        RemovePrematchBetdomainsGroupAction(prematchBetdomainsGroup: {}));*/
  }

  @override
  void didUpdateWidget(MatchDetailsDataLong oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    generateUnSubscribe();
    super.deactivate();
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

  _onExpansion(bool expanded) {
    if (expanded) {
      generateSubscribe();
    } else {
      generateUnSubscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    store = StoreProvider.of<AppState>(context);
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (oldViewModel!.webSocketReConnect !=
              viewModel.webSocketReConnect) {
            generateSubscribe();
          }
        },
        builder: (context, state) {
          List betDomainsData = state.matchDetailsBetDomains
              .where((e) => widget.group['betdomainNumbers']
                  .contains(e['betDomainNumber'].toString()))
              .toList();

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
                                sportId: widget.matchData['sport']['sportId'],
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
                                    sportId: widget.matchData['sport']
                                        ['sportId'],
                                    matchId: matchId,
                                    status: widget.matchData['liveBetStatus'],
                                    betDomainStatus: status,
                                    enabled: state.odds.length > 0 &&
                                        state.odds.any((element) => element['oddId'] == item['oddId']),
                                    disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId))))
                            .toList())
                    : betDomainNumber == 576 || betDomainNumber == 575 || betDomainNumber == 577
                        ? Column(children: strings.where((e) => e["value"] > 1).toList().map((item) => Container(child: LiveOddsButton(odds: item, sportId: widget.matchData['sport']['sportId'], matchId: matchId, status: widget.matchData['liveBetStatus'], betDomainStatus: status, enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']), disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))).toList())
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
                                                              .matchData['sport']
                                                          ['sportId'],
                                                      matchId: matchId,
                                                      status: widget
                                                          .matchData['liveBetStatus'],
                                                      betDomainStatus: status,
                                                      enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']),
                                                      disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))))
                                          .toList())
                              ])
                            : Row(children: strings.map((item) => new Expanded(child: LiveOddsButton(odds: item, sportId: widget.matchData['sport']['sportId'], matchId: matchId, status: widget.matchData['liveBetStatus'], betDomainStatus: status, enabled: state.odds.length > 0 && state.odds.any((element) => element['oddId'] == item['oddId']), disabled: state.odds.length > 0 && state.odds.any((element) => element['betDomainId'] != betDomainId && element['match'] == matchId)))).toList());
          }

          Widget getMarkets(List<dynamic> strings) {
            /*strings.sort((a, b) {
              int sort = a["sort"].compareTo(b["sort"]);
              if (sort != 0) return sort;
              return a['discriminator'].compareTo(b['discriminator']);
            });*/
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
                    .map((item) => Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ]),
                        alignment: Alignment.center,
                        child: Card(
                            child: Column(children: [
                          item['betdomainNumberCanBeCashout']
                              ? Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4)),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  child: Stack(
                                    children: [
                                      Align(
                                          child: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Text(
                                                item['discriminator']
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .indicatorColor),
                                              ))),
                                      Positioned(
                                          left: 10,
                                          top: 5,
                                          child: Tooltip(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        5.0),
                                                color: Colors.grey
                                                    .withOpacity(0.7)),
                                            message:
                                                LocaleKeys.marketCashout.tr(),
                                            child: Icon(Icons.monetization_on,
                                                color: Colors.white),
                                          )),
                                    ],
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4)),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  child: Align(
                                      child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            item['discriminator'].toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .indicatorColor),
                                          )))),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: getOdds(
                                  item['odds'],
                                  item['betDomainId'],
                                  item['matchId'],
                                  item['status'],
                                  item['betDomainNumber']))
                        ]))))
                    .toList());
          }

          return Container(
              decoration: const BoxDecoration(
                  border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              )),
              child: ExpansionTile(
                  onExpansionChanged: (bool expanding) =>
                      _onExpansion(expanding),
                  title: Text(widget.group['name']),
                  children: [
                    Opacity(
                        opacity: widgetOpacity ? 0.6 : 1,
                        child: Container(
                            //padding: EdgeInsets.all(8.0),
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child:
                                                    getMarkets(betDomainsData)),
                                          ])),
                                ],
                              ),
                            ),
                          ],
                        )))
                  ]));
        });
  }

  @override
  bool get wantKeepAlive => true;
}
