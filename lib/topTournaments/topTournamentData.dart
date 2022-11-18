import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
//import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
//import 'package:flutter_countdown_timer/index.dart';
import '../../live/liveOddsButton.dart';
import 'package:intl/intl.dart';
import '../../matchDetails/matchDetails.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/defaultConfig.dart' as config;

class TopTournamentDataBody extends StatefulWidget {
  final matchData;
  final index;
  final betDomainsData;
  const TopTournamentDataBody(
      {Key? key, this.matchData, this.index, this.betDomainsData})
      : super(key: key);

  @override
  State<TopTournamentDataBody> createState() => _TopTournamentDataBodyState();
}

class _TopTournamentDataBodyState extends State<TopTournamentDataBody> {
  bool widgetOpacity = false;
  String timeFormat = "";

  @override
  void didUpdateWidget(TopTournamentDataBody oldWidget) {
    super.didUpdateWidget(oldWidget);
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
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = "MM/dd h:mma";
          } else {
            timeFormat = "MM/dd' 'HH:mm";
          }
          Widget getOdds(List<dynamic> strings, betDomainId, matchId, status) {
            strings.sort((a, b) => a["sort"].compareTo(b["sort"]));
            return new Row(
                children: strings
                    .map((item) => new Expanded(
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
                    .toList());
          }

          Widget getMarkets(List<dynamic> strings) {
            strings.sort((a, b) => a["sort"].compareTo(b["sort"]));
            return new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
                                              item['betdomainName'].toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                          child: Icon(Icons.monetization_on,
                                              color: Colors.white),
                                        )),
                                  ],
                                )
                              : Text(
                                  item['betdomainName'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                          getOdds(item['odds'], item['betDomainId'],
                              item['matchId'], item['status'])
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
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onBackground,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4))),
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
                                                  'sport':
                                                      widget.matchData['sport']
                                                          ['sportId'],
                                                  'country': widget
                                                          .matchData['country']
                                                      ['countryId'],
                                                  'groups': ["BMG_MAIN"],
                                                  'tournament':
                                                      widget.matchData[
                                                          'tournamentId'],
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
                      margin: const EdgeInsets.only(top: 10.0),
                      width: MediaQuery.of(context).size.width,
                      child: getMarkets(widget.betDomainsData)),
                ],
              )));
        });
  }
}
