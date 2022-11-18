import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import './superJackpotOddButton.dart';
import 'package:intl/intl.dart';
import '../../config/defaultConfig.dart' as config;

class MatchData extends StatefulWidget {
  final matchData;
  final index;
  final odds;
  final matchObj;
  final Function addMatchObj;
  final jakpotStatus;
  const MatchData(
      {Key? key,
      this.matchData,
      this.index,
      this.odds,
      this.matchObj,
      required this.addMatchObj,
      this.jakpotStatus})
      : super(key: key);

  @override
  State<MatchData> createState() => _MatchDataState();
}

class _MatchDataState extends State<MatchData> {
  bool widgetOpacity = false;

  handleOddButton(odd) {
    widget.addMatchObj(widget.matchData, odd);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          String timeFormat = "";
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = 'h:mma dd/MM';
          } else {
            timeFormat = 'HH:mm dd/MM';
          }

          Widget getOdds(List<dynamic> strings, matchId) {
            strings.sort((a, b) =>
                a['tipDetailsWS']["sort"].compareTo(b['tipDetailsWS']["sort"]));
            return new Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Wrap(
                  children: strings
                      .map((item) => new Container(
                          child: OddButton(
                              handleOddButton: (odd) {
                                handleOddButton(odd);
                              },
                              odd: item,
                              sportId: item['tipDetailsWS']['sportId'],
                              matchId: matchId,
                              status: widget.matchData['status'],
                              enabled: widget.odds.firstWhere(
                                      (val) => val['id'] == item['svrOddID'],
                                      orElse: () => null) !=
                                  null,
                              disabled: widget.odds
                                          .where((val) =>
                                              val['matchId'] ==
                                              widget.matchData['id'])
                                          .length ==
                                      2 ||
                                  widget.jakpotStatus != 1)))
                      .toList())
            ]);
          }

          return Opacity(
              opacity: widgetOpacity ? 0.6 : 1,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        topLeft: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ]),
                  margin: const EdgeInsets.all(5.0),
                  child: Card(
                      child: Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Column(
                            children: [
                              Container(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            '${widget.matchData['tips'][0]['tipDetailsWS']['ligaName']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            '${DateFormat(timeFormat).format(DateTime.fromMillisecondsSinceEpoch(widget.matchData['startDate'])).toString()}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))),
                                  ),
                                ],
                              )),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.only(top: 7, bottom: 7),
                                child: Column(
                                  children: [
                                    Container(
                                        child: Row(children: [
                                      Expanded(
                                          flex: 6,
                                          child: Column(children: [
                                            new Text(
                                                '${widget.matchData['team1']}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .bodyText2),
                                            SizedBox(height: 10),
                                            new Text(
                                                '${widget.matchData['team2']}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .bodyText2)
                                          ])),
                                      Expanded(
                                          flex: 7,
                                          child: getOdds(
                                              widget.matchData['tips'],
                                              widget.matchData['id'])),
                                    ])),
                                  ],
                                ),
                              ),
                            ],
                          )))));
        });
  }
}
