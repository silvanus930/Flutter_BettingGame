import 'package:flutter/material.dart';
//import 'package:flutter_betting_app/prematch/prematchSportsWidgets/sportTournaments.dart';
//import '/login_page.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
//import 'dart:developer';
//import 'package:stomp_dart_client/stomp.dart';
//import 'package:stomp_dart_client/stomp_config.dart';
//import 'package:stomp_dart_client/stomp_frame.dart';
//import 'package:redux/redux.dart';
//import '/redux/app_state.dart';
//import 'redux/reducer.dart';
import '/redux/actions.dart';
//import 'dart:async';
//import 'dart:convert';
import 'sportTournamentDataBody.dart';
import 'prematchGroupsFilter.dart';

class SportTournamentData extends StatefulWidget {
  final sportData;
  final Function previousPage;

  const SportTournamentData(
      {Key? key, this.sportData, required this.previousPage})
      : super(key: key);

  @override
  State<SportTournamentData> createState() => SportTournamentDataState();
}

class SportTournamentDataState extends State<SportTournamentData> {
  String market = "";

  void generateSubscribe() {
    final Map subscribe = {};
    subscribe["sport"] = widget.sportData['sportId'];
    subscribe["country"] = widget.sportData['countryId'];
    subscribe["groups"] = market == "" ? ['BMG_MAIN'] : [market];
    subscribe["tournament"] = widget.sportData['id'];
    subscribe["matchIds"] = widget.sportData['matchIds'];
    subscribe["isFavorite"] = false;

    StoreProvider.of<AppState>(context).dispatch(
        SetPrematchSubscribeListAction(prematchSubscribeList: subscribe));
  }

  void generateUnSubscribe() {
    final Map subscribe = {};
    subscribe["sport"] = widget.sportData['sportId'];
    subscribe["country"] = widget.sportData['countryId'];
    subscribe["groups"] = StoreProvider.of<AppState>(context)
                .state
                .prematchBetdomainsGroup
                .length >
            0
        ? StoreProvider.of<AppState>(context).state.prematchBetdomainsGroup[0]
            ['activeGroup']
        : ['BMG_MAIN'];
    subscribe["tournament"] = widget.sportData['id'];
    subscribe["matchIds"] = widget.sportData['matchIds'];
    subscribe["isFavorite"] = false;

    StoreProvider.of<AppState>(context).dispatch(
        SetPrematchUnSubscribeListAction(prematchUnSubscribeList: subscribe));

    StoreProvider.of<AppState>(context)
        .dispatch(RemovePrematchBetDomainsAction(prematchBetDomains: {}));

    StoreProvider.of<AppState>(context).dispatch(
        RemovePrematchBetdomainsGroupAction(prematchBetdomainsGroup: {}));
  }

  marketChange(val) {
    setState(() {
      market = val;
    });
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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          /*if (oldViewModel!.webSocketReConnect !=
              viewModel.webSocketReConnect) {
            generateSubscribe();
          }*/
        },
        builder: (context, state) {
          state.prematchMatch.sort((a, b) {
            int date = a["startDate"].compareTo(b["startDate"]);
            if (date != 0) return date;
            return a['matchId'].compareTo(b['matchId']);
          });
          return Scaffold(
              appBar: AppBar(
                title: Text(widget.sportData['name']),
                backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => widget.previousPage(),
                ),
              ),
              body: state.prematchMatch.length > 0 &&
                      state.prematchBetDomains.length > 0
                  ? Column(children: [
                      PrematchGroupsFilter(
                        groupsData: state.prematchBetdomainsGroup,
                        marketChange: (val) {
                          marketChange(val);
                        },
                      ),
                      Expanded(
                          child: ListView.builder(
                              itemCount: state.prematchMatch.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return Container(
                                    key: Key(
                                        "${state.prematchMatch[index]['matchId']}"),
                                    constraints: new BoxConstraints(
                                      minHeight: 150.0,
                                      minWidth: 5.0,
                                    ),
                                    alignment: Alignment.center,
                                    child: new SportTournamentDataBody(
                                        matchData: state.prematchMatch[index],
                                        index: index,
                                        betDomainsData:
                                            state.prematchBetDomains[0][
                                                state.prematchMatch[index]
                                                    ['matchId']],
                                        key: Key(
                                            "${state.prematchMatch[index]['matchId']}")));
                              }))
                    ])
                  : Center(child: CircularProgressIndicator()));
        });
  }
}
