import 'package:flutter/material.dart';
import 'package:flutter_betting_app/matchDetails/matchDetails.dart';
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

import 'results/racesResultsBoard.dart';

class RaceCountryBoard extends StatefulWidget {
  final index;
  final countryInfo;
  final countryCode;
  const RaceCountryBoard(
      {Key? key, this.index, this.countryInfo, this.countryCode})
      : super(key: key);

  @override
  State<RaceCountryBoard> createState() => _RaceCountryBoardState();
}

class _RaceCountryBoardState extends State<RaceCountryBoard> {
  initState() {
    super.initState();
  }

  Widget tournamentBoard(Map tournamentData) {
    tournamentData['matchMenuDtos']
        .sort((a, b) => a["startDate"].compareTo(b["startDate"]) as int);
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF333549), width: 2),
          ),
        ),
        child: Column(children: [
          Text(tournamentData['name']),
          Wrap(
            children: [
              for (final match in tournamentData['matchMenuDtos'])
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: match['status'] == 8
                        ? TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.onSecondary),
                            child: Text(
                              "Result ${DateFormat('Hm').format(DateTime.fromMillisecondsSinceEpoch(match['startDate'])).toString()}",
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return RaceResultsBoard(
                                      sportId: tournamentData['sportId'],
                                      matchId: match['matchId'],
                                      tournamentName: tournamentData['name'],
                                      startDate: match['startDate']);
                                }),
                              );
                            },
                          )
                        : match['status'] == 1
                            ? TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                child: Text(
                                    "${DateFormat('Hm').format(DateTime.fromMillisecondsSinceEpoch(match['startDate'])).toString()}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryVariant)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MatchDetails(sportData: {
                                              'sport': tournamentData['sportId']
                                                  .toString(),
                                              'country':
                                                  widget.countryInfo['id'],
                                              'groups': ["BMG_SIS_WIN_PLACE"],
                                              'tournament':
                                                  tournamentData['id'],
                                              'match': match['matchId'],
                                            }, metaDataIndex: -1)),
                                  );
                                },
                              )
                            : SizedBox()),
            ],
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Card(
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
                            widget.countryCode == 'kos' ||
                                    widget.countryCode == 'int'
                                ? Image.asset(
                                    'assets/countries/${widget.countryCode}.png',
                                    height: 20,
                                    width: 30,
                                    fit: BoxFit.fill)
                                : widget.countryCode != ""
                                    ? Image.asset(
                                        'icons/flags/png/${widget.countryCode}.png',
                                        height: 20,
                                        width: 30,
                                        fit: BoxFit.fill,
                                        package: 'country_icons')
                                    : SizedBox(),
                            SizedBox(width: 5),
                            Text(widget.countryInfo['name'])
                          ])),
                  for (final tour in widget.countryInfo['tournaments'])
                    tournamentBoard(tour)
                ],
              ));
        });
  }
}
