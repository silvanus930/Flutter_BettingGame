import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../redux/app_state.dart';
//import '../redux/reducer.dart';
import '../../redux/actions.dart';
import 'dart:convert';
//import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
//import 'package:flutter_countdown_timer/index.dart';
import '../../Utils/stomp.dart' as stomp;
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class RaceResultsBoard extends StatefulWidget {
  final sportId;
  final matchId;
  final tournamentName;
  final startDate;
  final store;
  const RaceResultsBoard(
      {Key? key,
      this.sportId,
      this.matchId,
      this.tournamentName,
      this.startDate,
      this.store})
      : super(key: key);

  @override
  State<RaceResultsBoard> createState() => _RaceResultsBoardState();
}

class _RaceResultsBoardState extends State<RaceResultsBoard> {
  dynamic unsubscribeRaceMatch;
  Map raceData = {};

  initState() {
    super.initState();
    subscribeRaceMatch();
  }

  @override
  void dispose() {
    if (unsubscribeRaceMatch != null) {
      unsubscribeRaceMatch(
          unsubscribeHeaders: {'id': "results-${widget.matchId}"});
    }

    super.dispose();
  }

  subscribeRaceMatch() {
    unsubscribeRaceMatch = stomp.stompClient.subscribe(
      destination: '/matchs/${widget.sportId}/${widget.matchId}/BMG_MAIN_EXT',
      headers: {'id': "results-" + widget.matchId.toString()},
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
    List competitors = raceData['matchtocompetitors']
        .where((e) => e['competitor']['position'] != null)
        .toList();
    competitors.sort((a, b) => a['competitor']['position']
        .compareTo(b['competitor']['position']) as int);
    competitors.forEach((e) {
      rows.add(DataRow(cells: [
        DataCell(
          Text(e['competitor']['position'].toString(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        DataCell(
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
                flex: 1,
                child: Text(e['homeTeam'].toString(),
                    style: TextStyle(fontSize: 9))),
            e['competitor']['silkFileImage'] != null &&
                    e['competitor']['silkFileImage']['bytes'] != null
                ? Expanded(
                    flex: 2,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: Image.memory(
                            Base64Decoder().convert(
                                e['competitor']['silkFileImage']['bytes']),
                            gaplessPlayback: true,
                            fit: BoxFit.contain,
                            height: 20)))
                : SizedBox()
          ]),
        ),
        DataCell(
          Text('${e['competitor']['defaultName']}',
              style: TextStyle(fontSize: 9)),
        ),
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
                "POS.",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
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
                "HORSE",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
          ],
          rows: rows)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                    "${widget.tournamentName}, ${DateFormat('Hm').format(DateTime.fromMillisecondsSinceEpoch(widget.startDate)).toString()}"),
                leading: new IconButton(
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () => {Navigator.pop(context)}),
              ),
              body: raceData.isNotEmpty
                  ? _showCompetitorsTable()
                  : Center(child: CircularProgressIndicator()));
        });
  }
}
