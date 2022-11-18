import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/races/racesOddButton.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import '/redux/actions.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'RacesDataForecastTricast.dart';


late var store;

class MatchDetailsDataPlace extends StatefulWidget {
  final matchData;
  final index;
  final group;

  const MatchDetailsDataPlace(
      {Key? key, this.matchData, this.index, this.group})
      : super(key: key);

  @override
  State<MatchDetailsDataPlace> createState() => _MatchDetailsDataPlaceState();
}

class _MatchDetailsDataPlaceState extends State<MatchDetailsDataPlace> {
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
  void didUpdateWidget(MatchDetailsDataPlace oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) => generateSubscribe());
    super.initState();
  }

  @override
  void deactivate() {
    generateUnSubscribe();
    super.deactivate();
  }

  getTableType(id, betdomains) {
    switch (id) {
      case 2004:
        return _showCompetitorsTableWoFav(betdomains);
      case 2005:
        return _showCompetitorsTableWoFav(betdomains);
      case 2006:
        return _showCompetitorsTableWoFav(betdomains);
      case 2012:
        return _showCompetitorsTableFavOut(betdomains[0]);
      case 2013:
        return _showCompetitorsTableFavOut(betdomains[0]);
      case 2014:
        return _showCompetitorsTableFavOut(betdomains[0]);
      case 2001:
        return RacesDataForecastTricast(
            matchData: widget.matchData, betDomains: betdomains);
      default:
        return _showCompetitorsTable(betdomains);
    }
  }

  Widget _showCompetitorsTable(betDomains) {
    List<DataRow> rows = [];
    List odds = widget.matchData['sport']['sportId'] == 100
        ? StoreProvider.of<AppState>(context).state.horsesOdds
        : StoreProvider.of<AppState>(context).state.dogsOdds;
    betDomains.sort((a, b) => a["id"].compareTo(b["id"]) as int);
    betDomains[0]['odds']
        .sort((a, b) => a["value"].compareTo(b["value"]) as int);
    betDomains[0]['odds'].forEach((e) {
      Map competitor = widget.matchData['matchtocompetitors'].firstWhere(
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
        DataCell(widget.matchData['sport']['sportId'] == 100
            ? Container(
                width: MediaQuery.of(context).size.width * 0.2,
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
        for (var item in betDomains)
          DataCell(Container(
              alignment: Alignment.center,
              child: item['odds'].firstWhere((val) => competitor['homeTeam'] == val['runners'][0], orElse: () => null) !=
                      null
                  ? RacesOddButton(
                      odds: item['odds'].firstWhere(
                          (val) => competitor['homeTeam'] == val['runners'][0],
                          orElse: () => null),
                      sportId: widget.matchData['sport']['sportId'],
                      matchId: widget.matchData['matchId'],
                      status: widget.matchData['liveBetStatus'],
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
                widget.matchData['sport']['sportId'] == 100 ? "HORSE" : "DOG",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            for (var item in betDomains)
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
    ]);
  }

  Widget _showCompetitorsTableWoFav(betDomains) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: betDomains.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext ctxt, int index) {
          List<DataRow> rows = [];
          List odds = widget.matchData['sport']['sportId'] == 100
              ? StoreProvider.of<AppState>(context).state.horsesOdds
              : StoreProvider.of<AppState>(context).state.dogsOdds;
          betDomains.sort((a, b) => a["id"].compareTo(b["id"]) as int);

          betDomains[index]['odds']
              .sort((a, b) => a["value"].compareTo(b["value"]) as int);
          betDomains[index]['odds'].forEach((e) {
            Map competitor = widget.matchData['matchtocompetitors'].firstWhere(
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
                          competitor['competitor']['silkFileImage']['bytes'] !=
                              null
                      ? Expanded(
                          flex: 2,
                          child: Container(
                              alignment: Alignment.centerLeft,
                              child: Image.memory(
                                  Base64Decoder().convert(
                                      competitor['competitor']['silkFileImage']
                                          ['bytes']),
                                  gaplessPlayback: true,
                                  fit: BoxFit.contain,
                                  height: 30)))
                      : SizedBox()
                ]),
              ),
              DataCell(widget.matchData['sport']['sportId'] == 100
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text('${competitor['competitor']['defaultName']}',
                              style: TextStyle(fontSize: 9)),
                          Text(
                              "J: ${competitor['competitor']['sisMeta']['shortJockey']} / T: ${competitor['competitor']['sisMeta']['trainer']}",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 7)),
                          Text(
                              "Age: ${competitor['competitor']['sisMeta']['age']} / Weight: ${competitor['competitor']['sisMeta']['weightStones']}st ${competitor['competitor']['sisMeta']['weightPounds']}lb",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 7)),
                        ])
                  : Text('${competitor['competitor']['defaultName']}',
                      style: TextStyle(fontSize: 9))),
              DataCell(Container(
                  alignment: Alignment.center,
                  child: betDomains[index]['odds'].firstWhere((val) => competitor['homeTeam'] == val['runners'][0], orElse: () => null) != null
                      ? RacesOddButton(
                          odds: betDomains[index]['odds'].firstWhere(
                              (val) =>
                                  competitor['homeTeam'] == val['runners'][0],
                              orElse: () => null),
                          sportId: widget.matchData['sport']['sportId'],
                          matchId: widget.matchData['matchId'],
                          status: widget.matchData['liveBetStatus'],
                          betDomainStatus: betDomains[index]['status'],
                          enabled: odds.length > 0 &&
                              odds.any((element) =>
                                  element['oddId'] ==
                                  betDomains[index]['odds'].firstWhere(
                                      (val) => competitor['homeTeam'] == val['runners'][0],
                                      orElse: () => null)['oddId']),
                          disabled: false)
                      : SizedBox())),
            ]));
          });

          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    decoration: new BoxDecoration(
                      color: Colors.black,
                    ),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("${betDomains[index]['betdomainName']},",
                        textAlign: TextAlign.center)),
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
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12),
                        )),
                      ),
                      DataColumn(
                        label: Center(
                            child: Text(
                          widget.matchData['sport']['sportId'] == 100
                              ? "HORSE"
                              : "DOG",
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12),
                        )),
                      ),
                      DataColumn(
                        label: Expanded(
                            child: Container(
                                alignment: Alignment.center,
                                child: Text('ODDS',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12),
                                    textAlign: TextAlign.right))),
                      )
                    ],
                    rows: rows),
              ]);
        });
  }

  Widget _showCompetitorsTableFavOut(betDomains) {
    betDomains['odds'].sort((a, b) => a["value"].compareTo(b["value"]) as int);
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: betDomains['odds'].length,
        shrinkWrap: true,
        itemBuilder: (BuildContext ctxt, int index) {
          List<DataRow> rows = [];
          List odds = widget.matchData['sport']['sportId'] == 100
              ? StoreProvider.of<AppState>(context).state.horsesOdds
              : StoreProvider.of<AppState>(context).state.dogsOdds;

          List competitors = widget.matchData['matchtocompetitors']
              .where((val) =>
                  betDomains['odds'][index]['runners']
                      .contains(val['homeTeam']) ==
                  true)
              .toList();
          rows.add(DataRow(cells: [
            DataCell(
              Column(children: [
                for (var competitor in competitors)
                  Container(
                      alignment: Alignment.centerLeft,
                      height: 50,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(competitor['homeTeam'].toString(),
                                    style: TextStyle(fontSize: 9))),
                            competitor['competitor']['silkFileImage'] != null &&
                                    competitor['competitor']['silkFileImage']
                                            ['bytes'] !=
                                        null
                                ? Expanded(
                                    flex: 2,
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Image.memory(
                                            Base64Decoder().convert(
                                                competitor['competitor']
                                                    ['silkFileImage']['bytes']),
                                            gaplessPlayback: true,
                                            fit: BoxFit.contain,
                                            height: 20)))
                                : SizedBox()
                          ]))
              ]),
            ),
            DataCell(widget.matchData['sport']['sportId'] == 100
                ? Column(children: [
                    for (var competitor in competitors)
                      Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${competitor['competitor']['defaultName']}',
                                    style: TextStyle(fontSize: 9)),
                                Text(
                                    "J: ${competitor['competitor']['sisMeta']['shortJockey']} / T: ${competitor['competitor']['sisMeta']['trainer']}",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 7)),
                                Text(
                                    "Age: ${competitor['competitor']['sisMeta']['age']} / Weight: ${competitor['competitor']['sisMeta']['weightStones']}st ${competitor['competitor']['sisMeta']['weightPounds']}lb",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 7)),
                              ]))
                  ])
                : Column(children: [
                    for (var competitor in competitors)
                      Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          child: Text(
                              '${competitor['competitor']['defaultName']}',
                              style: TextStyle(fontSize: 9)))
                  ])),
            DataCell(Container(
                alignment: Alignment.center,
                child: RacesOddButton(
                    odds: betDomains['odds'][index],
                    sportId: widget.matchData['sport']['sportId'],
                    matchId: widget.matchData['matchId'],
                    status: widget.matchData['liveBetStatus'],
                    betDomainStatus: 0,
                    enabled: odds.length > 0 &&
                        odds.any((element) =>
                            element['oddId'] ==
                            betDomains['odds'][index]['oddId']),
                    disabled: false))),
          ]));

          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    decoration: new BoxDecoration(
                      color: Colors.black,
                    ),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("${betDomains['odds'][index]['information']}",
                        textAlign: TextAlign.center)),
                DataTable(
                    dataTextStyle: TextStyle(color: Colors.white),
                    headingTextStyle: TextStyle(color: Colors.white),
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Theme.of(context).colorScheme.onSecondary),
                    dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Color(0xFF333549).withOpacity(0.3)),
                    columnSpacing: 1.0,
                    dataRowHeight: competitors.length * 50,
                    headingRowHeight: 30,
                    columns: <DataColumn>[
                      DataColumn(
                        label: Center(
                            child: Text(
                          "NO.",
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12),
                        )),
                      ),
                      DataColumn(
                        label: Center(
                            child: Text(
                          widget.matchData['sport']['sportId'] == 100
                              ? "HORSE"
                              : "DOG",
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12),
                        )),
                      ),
                      DataColumn(
                        label: Expanded(
                            child: Container(
                                alignment: Alignment.center,
                                child: Text('ODDS',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12),
                                    textAlign: TextAlign.right))),
                      )
                    ],
                    rows: rows),
              ]);
        });
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
          betDomainsData.sort((a, b) => a["sort"].compareTo(b["sort"]) as int);
          return Opacity(
              opacity: widgetOpacity ? 0.6 : 1,
              child: Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      betDomainsData.length > 0
                          ? getTableType(betDomainsData[0]['betDomainNumber'],
                              betDomainsData)
                          : CircularProgressIndicator()
                    ],
                  )));
        });
  }
}
