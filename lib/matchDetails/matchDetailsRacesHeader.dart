import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class MatchDetailsRacesHeader extends StatelessWidget {
  MatchDetailsRacesHeader(this.matchData, this.metaData, this.collapsed);
  final matchData;
  final metaData;
  final collapsed;

  @override
  Widget build(BuildContext context) {
    if (matchData != null) {
      matchData['matchtocompetitors']
          .sort((a, b) => a["homeTeam"].compareTo(b["homeTeam"]) as int);
    }

    return SingleChildScrollView(
        child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF0D5611),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
            ),
            margin: EdgeInsets.only(bottom: 5.0),
            child: Column(
              children: [
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(matchData['tournamentName'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                            fontSize: 13))
                  ],
                )),
                metaData == null ? SizedBox(height: 10) : SizedBox(),
                Container(
                    child: metaData == null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  DateFormat('MMMMd')
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              matchData['startDate']))
                                      .toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white54,
                                      fontSize: 13))
                            ],
                          )
                        : SizedBox()),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        child: Text(
                      DateFormat('Hm')
                          .format(DateTime.fromMillisecondsSinceEpoch(
                              matchData['startDate']))
                          .toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    ))
                  ],
                ),
              ],
            )));
  }
}
