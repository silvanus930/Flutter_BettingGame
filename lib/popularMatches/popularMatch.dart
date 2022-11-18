import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
//import '../redux/reducer.dart';;
//import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
//import 'package:flutter_countdown_timer/index.dart';
import 'popularOddButton.dart';
import 'package:intl/intl.dart';
import '../../matchDetails/matchDetails.dart';
import '../../config/defaultConfig.dart' as config;

class PopularMatch extends StatefulWidget {
  final matchData;
  final index;
  final betDomainsData;
  final matchesCount;
  final Function addMoreMatches;
  final currentBetDomainId;
  const PopularMatch(
      {Key? key,
      this.matchData,
      this.index,
      this.betDomainsData,
      this.matchesCount,
      this.currentBetDomainId,
      required this.addMoreMatches})
      : super(key: key);

  @override
  State<PopularMatch> createState() => _PopularMatchState();
}

class _PopularMatchState extends State<PopularMatch> {
  bool widgetOpacity = false;

  @override
  void didUpdateWidget(PopularMatch oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) => {
          if (widget.matchesCount - widget.index < 5) {widget.addMoreMatches()}
        });
  }

  @override
  void dispose() {
    super.dispose();
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

          Widget getOdds(List<dynamic> strings, betDomainId, matchId, status) {
            strings.sort((a, b) => a["sort"].compareTo(b["sort"]));
            return new Wrap(
                children: strings
                    .map((item) => new Container(
                        child: PopularOddButton(
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
                    .toList());
          }

          Widget getMarkets(List<dynamic> strings) {
            strings.sort((a, b) => a["sort"].compareTo(b["sort"]));
            return new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: strings
                    .map((item) => new Container(
                        child: getOdds(item['odds'], item['betDomainId'],
                            item['matchId'], item['status'])))
                    .toList());
          }

          if (widget.matchData != null) {
            widget.matchData['matchtocompetitors']
                .sort((a, b) => a["homeTeam"].compareTo(b["homeTeam"]) as int);
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
                                            '${widget.matchData['country']['defaultName']} / ${widget.matchData['tournamentName']}',
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
                                                '${widget.matchData['matchtocompetitors'][0]['competitor']['defaultName']}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .bodyText2),
                                            SizedBox(height: 10),
                                            new Text(
                                                '${widget.matchData['matchtocompetitors'][1]['competitor']['defaultName']}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .bodyText2)
                                          ])),
                                      Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MatchDetails(
                                                          sportData: {
                                                            'sport':
                                                                widget.matchData[
                                                                        'sport']
                                                                    ['sportId'],
                                                            'country': widget
                                                                        .matchData[
                                                                    'country']
                                                                ['countryId'],
                                                            'groups': [
                                                              "BMG_MAIN"
                                                            ],
                                                            'tournament': widget
                                                                    .matchData[
                                                                'tournamentId'],
                                                            'match': widget
                                                                    .matchData[
                                                                'matchId'],
                                                          },
                                                          metaDataIndex: -1
                                                        
                                                        )),
                                              );
                                            },
                                            child: Text(
                                                '+${widget.matchData['betdomainSize'].toString()}',
                                                overflow: TextOverflow.fade,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .caption),
                                          )),
                                      Expanded(
                                          flex: 7,
                                          child: widget.currentBetDomainId ==
                                                  widget.betDomainsData[0]
                                                      ['betDomainNumber']
                                              ? getMarkets(
                                                  widget.betDomainsData)
                                              : SizedBox()),
                                    ])),
                                  ],
                                ),
                              ),
                            ],
                          )))));
        });
  }
}
