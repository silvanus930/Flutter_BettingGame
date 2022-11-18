import 'package:flutter/material.dart';
import 'package:flutter_betting_app/matchDetails/matchDetails.dart';
import 'package:flutter_betting_app/races/racesOddButton.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
//import '../redux/reducer.dart';
import '../redux/actions.dart';
import 'dart:convert';
//import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
//import 'package:flutter_countdown_timer/index.dart';
import '../Utils/stomp.dart' as stomp;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/defaultConfig.dart' as config;

class RaceBoard extends StatefulWidget {
  final index;
  final webSocketReConnect;
  final raceInfo;
  final store;
  final liveStreamEnabled;
  final Function toggleLiveStream;
  const RaceBoard(
      {Key? key,
      this.index,
      this.webSocketReConnect,
      this.raceInfo,
      this.store,
      this.liveStreamEnabled,
      required this.toggleLiveStream})
      : super(key: key);

  @override
  State<RaceBoard> createState() => _RaceBoardState();
}

class _RaceBoardState extends State<RaceBoard> {
  dynamic unsubscribeRaceMatch;
  bool widgetOpacity = false;
  Map raceData = {};
  int rowsLength = 3;

  initState() {
    super.initState();
    subscribeRaceMatch();
  }

  @override
  void didUpdateWidget(RaceBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.webSocketReConnect != oldWidget.webSocketReConnect) {
      subscribeRaceMatch();
    }
  }

  @override
  void dispose() {
    if (unsubscribeRaceMatch != null) {
      unsubscribeRaceMatch(unsubscribeHeaders: {
        'id': "racePanel/" + widget.raceInfo['matchId'].toString()
      });
    }

    super.dispose();
  }

  subscribeRaceMatch() {
    unsubscribeRaceMatch = stomp.stompClient.subscribe(
      destination:
          '/matchs/${widget.raceInfo['sportId']}/${widget.raceInfo['matchId']}/BMG_MAIN_EXT',
      headers: {'id': "racePanel/" + widget.raceInfo['matchId'].toString()},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['match'] != null) {
          setState(() {
            raceData = result['match'];
          });
        }
      },
    );
  }

  Widget _showCompetitorsTable() {
    List<DataRow> rows = [];
    List odds = raceData['sport']['sportId'] == 100
        ? widget.store.state.horsesOdds
        : widget.store.state.dogsOdds;
    raceData['betdomains'].sort((a, b) => a["id"].compareTo(b["id"]) as int);
    raceData['betdomains'][0]['odds']
        .sort((a, b) => a["value"].compareTo(b["value"]) as int);
    raceData['betdomains'][0]['odds'].sublist(0, rowsLength).forEach((e) {
      Map competitor = raceData['matchtocompetitors'].firstWhere(
          (val) => val['homeTeam'] == e['runners'][0],
          orElse: () => null);
      rows.add(DataRow(cells: [
        DataCell(
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
                flex: 1,
                child: Text(competitor['homeTeam'].toString(),
                    style: TextStyle(fontSize: 9))),
            competitor['competitor']['silkFileImage'] != null &&
                    competitor['competitor']['silkFileImage']['bytes'] != null
                ? Expanded(
                    flex: 2,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: Image.memory(
                            Base64Decoder().convert(competitor['competitor']
                                ['silkFileImage']['bytes']),
                            gaplessPlayback: true,
                            fit: BoxFit.contain,
                            height: 20)))
                : SizedBox()
          ]),
        ),
        DataCell(raceData['sport']['sportId'] == 100
            ? Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${competitor['competitor']['defaultName']}',
                          style: TextStyle(fontSize: 9)),
                      Text(
                          "J: ${competitor['competitor']['sisMeta']['shortJockey']} / T: ${competitor['competitor']['sisMeta']['trainer']}",
                          style: TextStyle(color: Colors.grey, fontSize: 7)),
                      Text(
                          "Age: ${competitor['competitor']['sisMeta']['age']} / Weight: ${competitor['competitor']['sisMeta']['weightStones']}st ${competitor['competitor']['sisMeta']['weightPounds']}lb",
                          style: TextStyle(color: Colors.grey, fontSize: 7)),
                    ]))
            : Text('${competitor['competitor']['defaultName']}',
                style: TextStyle(fontSize: 9))),
        for (var item in raceData['betdomains'])
          DataCell(Container(
              alignment: Alignment.center,
              child: item['odds'].firstWhere((val) => competitor['homeTeam'] == val['runners'][0], orElse: () => null) !=
                      null
                  ? RacesOddButton(
                      odds: item['odds'].firstWhere(
                          (val) => competitor['homeTeam'] == val['runners'][0],
                          orElse: () => null),
                      sportId: raceData['sport']['sportId'],
                      matchId: raceData['matchId'],
                      status: raceData['liveBetStatus'],
                      betDomainStatus: item['status'],
                      enabled: odds.length > 0 &&
                          odds.any((element) =>
                              element['oddId'] ==
                              item['odds'].firstWhere(
                                  (val) => competitor['homeTeam'] == val['runners'][0],
                                  orElse: () => null)['oddId']),
                      disabled: false)
                  : SizedBox())),
      ]));
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DataTable(
          dataTextStyle: TextStyle(color: Colors.white),
          headingTextStyle: TextStyle(color: Colors.white),
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Theme.of(context).colorScheme.onSecondary),
          dataRowColor: MaterialStateColor.resolveWith(
              (states) => Color(0xFF333549).withOpacity(0.3)),
          columnSpacing: 1.0,
          headingRowHeight: 30,
          columns: <DataColumn>[
            DataColumn(
              label: Center(
                  child: Text(
                "NO.",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            DataColumn(
              label: Center(
                  child: Text(
                widget.raceInfo['sportId'] == "100" ? "HORSE" : "DOG",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            for (var item in raceData['betdomains'])
              DataColumn(
                label: Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text('${item['betdomainName']}',
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 12),
                            textAlign: TextAlign.right))),
              )
          ],
          rows: rows),
      /*raceData['betdomains'][0]['odds'].length > 3
          ? Container(
              child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      rowsLength = rowsLength == 3
                          ? raceData['betdomains'][0]['odds'].length
                          : 3;
                    });
                  },
                  icon: Icon(
                      rowsLength == 3
                          ? Icons.arrow_drop_down
                          : Icons.arrow_drop_up,
                      color: Theme.of(context).indicatorColor),
                  label: Text(
                      rowsLength == 3
                          ? "Show more +${raceData['betdomains'][0]['odds'].length - 3}"
                          : "Show less",
                      style: Theme.of(context).primaryTextTheme.bodyText2)))
          : SizedBox()*/
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          String timeFormat = "";
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = 'h:mma, dd/MM';
          } else {
            timeFormat = 'HH:mm, dd/MM';
          }
          return raceData.isNotEmpty
              ? Opacity(
                  opacity: widgetOpacity ? 0.6 : 1,
                  child: Card(
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              color: Colors.black,
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${DateFormat(timeFormat).format(DateTime.fromMillisecondsSinceEpoch(raceData['startDate'])).toString()}',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.left,
                                        )),
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                            '${raceData['country']['defaultName']}/${raceData['tournamentName']}',
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: InkWell(
                                            onTap: () {
                                              if (widget.liveStreamEnabled) {
                                                widget.toggleLiveStream();
                                              }
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MatchDetails(
                                                            sportData: {
                                                              'sport': widget
                                                                      .raceInfo[
                                                                  'sportId'],
                                                              'country': widget
                                                                      .raceInfo[
                                                                  'countryId'],
                                                              'groups': [
                                                                "BMG_SIS_WIN_PLACE"
                                                              ],
                                                              'tournament':
                                                                  raceData[
                                                                      'tournamentId'],
                                                              'match': widget
                                                                      .raceInfo[
                                                                  'matchId'],
                                                            },
                                                            metaDataIndex: -1)),
                                              );
                                            },
                                            child: Text('+MORE',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Theme.of(context)
                                                        .indicatorColor))))
                                  ])),
                          raceData['betdomains'].length > 0
                              ? _showCompetitorsTable()
                              : SizedBox()
                        ],
                      )))
              : Center(child: CircularProgressIndicator());
        });
  }
}
