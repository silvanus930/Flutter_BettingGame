import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../config/defaultConfig.dart' as config;

import 'matchDataResult.dart';

class JackpotResult extends StatefulWidget {
  final jackpotResultsData;
  const JackpotResult({Key? key, this.jackpotResultsData}) : super(key: key);

  @override
  JackpotResultState createState() => JackpotResultState();
}

class JackpotResultState extends State<JackpotResult> {
  var formatter = NumberFormat('#,###,000');
  String timeFormat = "";

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = "MM/dd/yyyy', 'h:mma";
          } else {
            timeFormat = "MM/dd/yyyy', 'HH:mm";
          }
          return Container(
              decoration: const BoxDecoration(
                  border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              )),
              padding: EdgeInsets.all(10.0),
              child: ExpansionTile(
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                  textColor: Theme.of(context).secondaryHeaderColor,
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.jackpotResultsData['name'].toUpperCase()),
                        SizedBox(height: 10),
                        Text(
                          LocaleKeys.SUPER_JACKPOT_ENDED_ON.tr(args: [
                            DateFormat(timeFormat).format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.jackpotResultsData['expireAt']))
                          ]),
                        ),
                        SizedBox(height: 10),
                        Text(
                            '${formatter.format(widget.jackpotResultsData['amount'])} ${state.currency}')
                      ]),
                  children: [
                    Container(
                        decoration: new BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        child: ListView.builder(
                            itemCount:
                                widget.jackpotResultsData['markets'].length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Container(
                                  key: Key(
                                      "${widget.jackpotResultsData['markets'][index]['matchId']}"),
                                  constraints: new BoxConstraints(
                                    minHeight: 50.0,
                                    minWidth: 200.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: MatchDataResults(
                                      matchData:
                                          widget.jackpotResultsData['markets']
                                              [index]));
                            }))
                  ]));
        });
  }
}
