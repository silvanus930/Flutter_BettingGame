import 'package:flutter/material.dart';
import 'package:flutter_betting_app/matchDetails/matchDetailsRacesData.dart/matchDetailsDataForecast.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import 'matchDetailsDataTricast.dart';

late var store;

class RacesDataForecastTricast extends StatefulWidget {
  final matchData;
  final betDomains;

  const RacesDataForecastTricast({Key? key, this.matchData, this.betDomains})
      : super(key: key);

  @override
  State<RacesDataForecastTricast> createState() =>
      _RacesDataForecastTricastState();
}

class _RacesDataForecastTricastState extends State<RacesDataForecastTricast> {
  int tabBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {},
        builder: (context, state) {
          return DefaultTabController(
              length: widget.betDomains
                  .where((e) =>
                      e['betDomainNumber'] == 2001 ||
                      e['betDomainNumber'] == 2002)
                  .toList()
                  .length,
              child: Column(children: [
                TabBar(
                  onTap: (index) {
                    setState(() {
                      tabBarIndex = index;
                    });
                  },
                  tabs: [
                    for (var item in widget.betDomains
                        .where((e) =>
                            e['betDomainNumber'] == 2001 ||
                            e['betDomainNumber'] == 2002)
                        .toList())
                      Tab(text: item['betdomainName'])
                  ],
                ),
                tabBarIndex == 0
                    ? MatchDetailsDataForecast(
                        matchData: widget.matchData,
                        betDomains: widget.betDomains)
                    : MatchDetailsDataTricast(
                        matchData: widget.matchData,
                        betDomains: widget.betDomains)
              ]));
        });
  }
}
