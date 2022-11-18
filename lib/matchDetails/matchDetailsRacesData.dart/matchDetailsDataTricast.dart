import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/races/racesOddButton.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import '/redux/actions.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

late var store;

class MatchDetailsDataTricast extends StatefulWidget {
  final matchData;
  final betDomains;

  const MatchDetailsDataTricast({Key? key, this.matchData, this.betDomains})
      : super(key: key);

  @override
  State<MatchDetailsDataTricast> createState() =>
      _MatchDetailsDataTricastState();
}

class _MatchDetailsDataTricastState extends State<MatchDetailsDataTricast> {
  int first = -1;
  int second = -1;
  int third = -1;
  Map oddObject = {};
  List any = [];

  @override
  void didUpdateWidget(MatchDetailsDataTricast oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void initState() {
    super.initState();
  }

  sortCompetitors(array) {
    List arrayWithRunners = [];
    List competitorsSort = [];
    var data;

    array.forEach((element) {
      arrayWithRunners.add(element['runners'][0]);
    });
    arrayWithRunners = arrayWithRunners.toSet().toList();

    arrayWithRunners.forEach((val) => {
          data = array.where((e) => e['runners'][0] == val).toList().reduce(
              (value, e) =>
                  value is double ? value : value['value'] + e['value']),
          competitorsSort.add({'number': val, 'value': data})
        });

    competitorsSort = competitorsSort
        .where((e) => e['number'] != null && e['value'] != null)
        .toList();

    competitorsSort.sort((a, b) {
      int cmp = a['value'].compareTo(b['value']);
      if (cmp != 0) return cmp;
      return a['number'].compareTo(b['number']);
    });

    return competitorsSort;
  }

  handleClickPlace(type, index) {
    switch (type) {
      case 'first':
        this.setState(() {
          first = index != first ? index : -1;
        });
        handleObject();
        break;

      case 'second':
        this.setState(() {
          second = index != second ? index : -1;
        });
        handleObject();
        break;
      case 'third':
        this.setState(() {
          third = index != third ? index : -1;
        });
        handleObject();
        break;
      case 'any':
        any.contains(index)
            ? any.removeWhere((item) => item == index)
            : any.add(index);
        handleObject();
        break;

      default:
        break;
    }
  }

  handleObject() {
    if (first != -1 && second != -1 && third != -1) {
      Map odd = {};
      odd = widget.betDomains[1]['odds'].firstWhere((e) =>
          e['runners'][0] == first &&
          e['runners'][1] == second &&
          e['runners'][2] == third);
      setState(() {
        oddObject = odd;
      });
    } else if (any.length == 3) {
      Map odd = {};
      odd = widget.betDomains
          .firstWhere((e) => e['betDomainNumber'] == 2022)['odds']
          .firstWhere((e) =>
              e['runners'].contains(any[0]) &&
              e['runners'].contains(any[1]) &&
              e['runners'].contains(any[2]));
      setState(() {
        oddObject = odd;
      });
    } else {
      setState(() {
        oddObject = {};
      });
    }
  }

  clearSelections() {
    setState(() {
      oddObject = {};
      first = -1;
      second = -1;
      third = -1;
      any = [];
    });
  }

  handleOddClick() {
    final store = StoreProvider.of<AppState>(context);
    if (oddObject.isNotEmpty) {
      if (widget.matchData['sport']['sportId'] == 100) {
        if (store.state.horsesOdds.length > 0 &&
            store.state.horsesOdds
                .any((element) => element['oddId'] == oddObject['oddId'])) {
          store.dispatch(RemoveHorsesOddsAction(horsesOdds: {
            'match': widget.matchData['matchId'],
            'oddId': oddObject['oddId']
          }));
          store.dispatch(
              RemoveMatchObjAction(matchObj: {'oddId': oddObject['oddId']}));
        } else {
          store.dispatch(SetHorsesOddsAction(horsesOdds: {
            'match': widget.matchData['matchId'],
            'betDomainId': oddObject['betdomainId'],
            'sport': 100,
            'oddId': oddObject['oddId']
          }));
        }
      } else {
        if (store.state.dogsOdds.length > 0 &&
            store.state.dogsOdds
                .any((element) => element['oddId'] == oddObject['oddId'])) {
          store.dispatch(RemoveDogsOddsAction(dogsOdds: {
            'match': widget.matchData['matchId'],
            'oddId': oddObject['oddId']
          }));
          store.dispatch(
              RemoveMatchObjAction(matchObj: {'oddId': oddObject['oddId']}));
        } else {
          store.dispatch(SetDogsOddsAction(dogsOdds: {
            'match': widget.matchData['matchId'],
            'betDomainId': oddObject['betdomainId'],
            'sport': 101,
            'oddId': oddObject['oddId']
          }));
        }
      }
      clearSelections();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  Widget _showCompetitorsTable(betDomains) {
    List<DataRow> rows = [];

    betDomains[1]['odds']
        .sort((a, b) => a["value"].compareTo(b["value"]) as int);
    bool reverseForecast =
        widget.betDomains.any((e) => e['betDomainNumber'] == 2022);

    sortCompetitors(betDomains[1]['odds']).forEach((e) {
      Map competitor = widget.matchData['matchtocompetitors'].firstWhere(
          (val) => val['homeTeam'] == e['number'],
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
        DataCell(widget.matchData['sport']['sportId'] == 100
            ? Wrap(children: [
                Text('${competitor['competitor']['defaultName']}',
                    style: TextStyle(fontSize: 9)),
                Text(
                    "J: ${competitor['competitor']['sisMeta']['shortJockey']} / T: ${competitor['competitor']['sisMeta']['trainer']}",
                    style: TextStyle(color: Colors.grey, fontSize: 7)),
                Text(
                    "Age: ${competitor['competitor']['sisMeta']['age']} / Weight: ${competitor['competitor']['sisMeta']['weightStones']}st ${competitor['competitor']['sisMeta']['weightPounds']}lb",
                    style: TextStyle(color: Colors.grey, fontSize: 7)),
              ])
            : Text('${competitor['competitor']['defaultName']}',
                style: TextStyle(fontSize: 9))),
        DataCell(InkWell(
            onTap:
                second == e['number'] || third == e['number'] || any.length > 0
                    ? null
                    : () {
                        handleClickPlace("first", e['number']);
                      },
            child: Opacity(
                opacity: second == e['number'] ||
                        third == e['number'] ||
                        any.length > 0
                    ? 0.3
                    : 1,
                child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.12,
                    decoration: BoxDecoration(
                        color: first == e['number']
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: first == e['number']
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary)),
                    child: Text(
                      "1ST",
                      style: TextStyle(
                          color: first != -1 && first != e['number']
                              ? Colors.white.withOpacity(0.5)
                              : first == e['number']
                                  ? Theme.of(context).colorScheme.surface
                                  : Colors.white),
                    ))))),
        DataCell(InkWell(
            onTap:
                first == e['number'] || third == e['number'] || any.length > 0
                    ? null
                    : () {
                        handleClickPlace("second", e['number']);
                      },
            child: Opacity(
                opacity: first == e['number'] ||
                        third == e['number'] ||
                        any.length > 0
                    ? 0.3
                    : 1,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.12,
                  decoration: BoxDecoration(
                      color: second == e['number']
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: second == e['number']
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary)),
                  child: Text(
                    "2ND",
                    style: TextStyle(
                        color: second != -1 && second != e['number']
                            ? Colors.white.withOpacity(0.5)
                            : second == e['number']
                                ? Theme.of(context).colorScheme.surface
                                : Colors.white),
                  ),
                )))),
        DataCell(InkWell(
            onTap:
                first == e['number'] || second == e['number'] || any.length > 0
                    ? null
                    : () {
                        handleClickPlace("third", e['number']);
                      },
            child: Opacity(
                opacity: first == e['number'] ||
                        second == e['number'] ||
                        any.length > 0
                    ? 0.3
                    : 1,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.12,
                  decoration: BoxDecoration(
                      color: third == e['number']
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: third == e['number']
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary)),
                  child: Text(
                    "3ND",
                    style: TextStyle(
                        color: third != -1 && third != e['number']
                            ? Colors.white.withOpacity(0.5)
                            : third == e['number']
                                ? Theme.of(context).colorScheme.surface
                                : Colors.white),
                  ),
                )))),
        if (reverseForecast)
          DataCell(InkWell(
              onTap: first != -1 ||
                      second != -1 ||
                      third != -1 ||
                      any.length == 3 && !any.contains(e['number'])
                  ? null
                  : () {
                      handleClickPlace("any", e['number']);
                    },
              child: Opacity(
                  opacity: first != -1 ||
                          second != -1 ||
                          third != -1 ||
                          any.length == 3 && !any.contains(e['number'])
                      ? 0.3
                      : 1,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.12,
                    decoration: BoxDecoration(
                        color: any.contains(e['number'])
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: any.contains(e['number'])
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary)),
                    child: Text(
                      "ANY",
                      style: TextStyle(
                          color: any.contains(e['number'])
                              ? Theme.of(context).colorScheme.surface
                              : Colors.white),
                    ),
                  ))))
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
                widget.matchData['sport']['sportId'] == 100 ? "HORSE" : "DOG",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            DataColumn(
              label: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.12,
                  child: Text(
                    "1ST",
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  )),
            ),
            DataColumn(
              label: Container(
                  width: MediaQuery.of(context).size.width * 0.12,
                  alignment: Alignment.center,
                  child: Text(
                    "2ND",
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  )),
            ),
            DataColumn(
              label: Container(
                  width: MediaQuery.of(context).size.width * 0.12,
                  alignment: Alignment.center,
                  child: Text(
                    "3RD",
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  )),
            ),
            if (reverseForecast)
              DataColumn(
                label: Container(
                    width: MediaQuery.of(context).size.width * 0.12,
                    alignment: Alignment.center,
                    child: Text(
                      "ANY",
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                    )),
              ),
          ],
          rows: rows),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {},
        builder: (context, state) {
          return Column(children: [
            _showCompetitorsTable(widget.betDomains),
            oddObject.isNotEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).indicatorColor),
                      child: Text(
                          '${oddObject['value'].toString()} ADD TO BETSLIP',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface)),
                      onPressed: () {
                        handleOddClick();
                      },
                    ))
                : SizedBox(),
          ]);
        });
  }
}
