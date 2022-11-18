import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/actions.dart';
import 'dart:convert';
import '../Utils/stomp.dart' as stomp;
import '../config/defaultConfig.dart' as config;
import 'raceCountryBoard.dart';
import 'racesBoard.dart';
import 'racesMenu.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../services/storage_service.dart';

class Races extends StatefulWidget {
  final store;

  const Races({Key? key, this.store}) : super(key: key);

  @override
  RacesState createState() => RacesState();
}

class RacesState extends State<Races> {
  dynamic unsubscribeRacesInfo;
  dynamic unsubscribeRacesData;
  dynamic unsubscribeMatchDetailsData;
  int racesSportName = 0;
  int racesSportType = 0;
  List countries = [];
  bool liveStreamEnabled = false;
  String liveStreamUrl = "";

  void unSubscribeRacesData() {
    unsubscribeRacesData(unsubscribeHeaders: {'id': 'racesData'});
  }

  void subscribeRacesData(e) {
    if (stomp.stompClient.connected) {
      if (unsubscribeRacesData != null) {
        unSubscribeRacesData();
      }

      unsubscribeRacesData = stomp.stompClient.subscribe(
          destination:
              '/racePanel/${e['sport']['sport']}/${e['match']}/${e['group']}',
          headers: {'id': '/racePanel/${e['match']}'},
          callback: (frame) {
            var result = jsonDecode(frame.body!);
            if (frame.body == "not found") {
              widget.store.dispatch(RemoveSelectedTopTournamentDataAction(
                  selectedTopTournamentData: {}));
            }
            if (result['tournamentDto'] != null) {
              Map newData = {};
              newData['sport'] =
                  result['tournamentDto']['sport']['defaultName'];
              newData['tournament'] = result['tournamentDto'];

              widget.store.dispatch(UpdateSelectedTopTournamentMatchDataAction(
                  selectedTopTournamentData: newData));
              return;
            }
            if (result != null && result['betdomainStatusMessage'] != null) {
              widget.store.dispatch(
                  UpdateSelectedTopTournamentBetDomainStatusDataAction(
                      selectedTopTournamentData:
                          result['betdomainStatusMessage']));

              return;
            }
          });
    }
  }

  void unSubscribeMatchDetails(newSubscribe) {
    unsubscribeMatchDetailsData(unsubscribeHeaders: {
      'id':
          '/matchDetails/${newSubscribe['sport']}/${newSubscribe['match']}/${newSubscribe['groups'][0]}'
    });
  }

  void subscribeMatchDetails(newSubscribe) {
    if (stomp.stompClient.connected) {
      widget.store.dispatch(RemoveMatchDetailsSubscribeListAction(
          matchDetailsSubscribeList: newSubscribe));
      unsubscribeMatchDetailsData = stomp.stompClient.subscribe(
        destination:
            '/matchs/${newSubscribe['sport']}/${newSubscribe['match']}/${newSubscribe['groups'][0]}',
        headers: {
          'id':
              '/matchDetails/${newSubscribe['sport']}/${newSubscribe['match']}/${newSubscribe['groups'][0]}'
        },
        callback: (frame) {
          var result = jsonDecode(frame.body!);
          if (result['match'] != null) {
            widget.store.dispatch(SetMatchDetailsMatchDataAction(
                matchDetailsMatchData: result['match']));

            widget.store.dispatch(SetMatchDetailsDomainsAction(
                matchDetailsBetDomains: result['match']));
          } else if (result['betdomainStatusMessage'] != null) {
            widget.store.dispatch(UpdatetMatchDetailsDomainsAction(
                matchDetailsBetDomains: result['betdomainStatusMessage']));
          }

          /*else if (result['betdomainStatusMessage'] != null) {
                      widget.store.dispatch(UpdateStatusOddsBetDomainInfoAction(
                          oddsBetDomainInfo: result['betdomainStatusMessage']));
                    }*/
          /*widget.store.dispatch(
                SetPrematchInfoAction(prematchInfo: result['sportCategories']));*/
          /*widget.store.dispatch(RemoveMatchDetailsSubscribeListAction(
              matchDetailsSubscribeList: newSubscribe));*/
        },
      );
    }
  }

  void getLiveStreamUrl() async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');


    if (accessToken!.length > 0) {
      var url = Uri(
        scheme: config.protocol,
        host: config.hostname,
        path: 'betting-api-gateway/user/rest/races/getRaceInfo',
      );

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          setState(() {
            liveStreamUrl = result['phenixEmbedUrl'];
          });
        } else {
          debugPrint('failed to load live stream data');
        }
      });
    }
  }

  handleSportChange(selectedSport) {
    if (racesSportName != selectedSport) {
      widget.store.dispatch(SetRacesSportNameAction(
          racesSportName: selectedSport == 0 ? "horses" : "dogs"));
      setState(() {
        racesSportName = selectedSport;
      });
      subscribeRacesInfo();
    }
  }

  handleSportTypeChange(val) {
    if (racesSportType != val) {
      setState(() {
        racesSportType = val;
      });
      //subscribeRacesInfo();
    }
  }

  toggleLiveStream() {
    if (!liveStreamEnabled && liveStreamUrl == "") {
      getLiveStreamUrl();
    }
    setState(() {
      liveStreamEnabled = !liveStreamEnabled;
    });
  }

  subscribeRacesInfo() {
    if (unsubscribeRacesInfo != null) {
      unsubscribeRacesInfo(unsubscribeHeaders: {'id': 'RacesInfo'});
    }
    unsubscribeRacesInfo = stomp.stompClient.subscribe(
      destination: racesSportName == 0 ? '/sis/HR/menu' : '/sis/DG/menu',
      headers: {'id': 'RacesInfo'},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['sportCategories'] != null) {
          widget.store.dispatch(SetRacesTournamentListAction(
              racesTournamentList: result['sportCategories']));
          widget.store.dispatch(SetRacesTournamentListCommonAction(
              racesTournamentListCommon: result['sportCategories']));
        }
      },
    );
  }

  initState() {
    super.initState();
    readJson();
    if (stomp.stompClient.connected) {
      subscribeRacesInfo();
    }
    widget.store.dispatch(SetRacesSportNameAction(
        racesSportName: racesSportName == 0 ? "horses" : "dogs"));
  }

  @override
  void dispose() {
    widget.store.dispatch(SetRacesSportNameAction(racesSportName: ""));
    if (unsubscribeRacesInfo != null) {
      unsubscribeRacesInfo(unsubscribeHeaders: {'id': 'RacesInfo'});
    }
    if (unsubscribeRacesData != null) {
      unsubscribeRacesData(unsubscribeHeaders: {'id': 'racesData'});
    }
    widget.store
        .dispatch(RemoveRacesTournamentListAction(racesTournamentList: []));
    widget.store.dispatch(
        RemoveRacesTournamentListCommonAction(racesTournamentListCommon: []));

    super.dispose();
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/countries/countries.json');
    final data = await json.decode(response);
    setState(() {
      countries = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (viewModel.matchDetailsUnSubscribeList.length > 0 &&
              viewModel.matchDetailsUnSubscribeList.length !=
                  oldViewModel!.matchDetailsUnSubscribeList.length) {
            viewModel.matchDetailsUnSubscribeList.forEach((element) {
              unSubscribeMatchDetails(element);
            });
            widget.store.dispatch(RemovematchDetailsUnSubscribeListAction(
                matchDetailsUnSubscribeList: []));
          }

          if (viewModel.matchDetailsSubscribeList.length > 0 &&
              viewModel.matchDetailsSubscribeList.length !=
                  oldViewModel!.matchDetailsSubscribeList.length) {
            viewModel.matchDetailsSubscribeList.forEach((element) {
              subscribeMatchDetails(element);
            });
          }
          if (oldViewModel!.webSocketReConnect !=
              viewModel.webSocketReConnect) {
            subscribeRacesInfo();
          }
          if (oldViewModel.authorization != viewModel.authorization &&
              !viewModel.authorization &&
              liveStreamEnabled) {
            setState(() {
              liveStreamEnabled = false;
            });
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              RacesMenu(
                  authorization: state.authorization,
                  currentSport: racesSportName,
                  currentSportType: racesSportType,
                  liveStreamEnabled: liveStreamEnabled,
                  sportChange: (selectedSport) {
                    handleSportChange(selectedSport);
                  },
                  sportTypeChange: (racesSportType) {
                    handleSportTypeChange(racesSportType);
                  },
                  toggleLiveStream: () {
                    toggleLiveStream();
                  }),
              state.authorization && liveStreamEnabled && liveStreamUrl != ""
                  ? Container(
                      height: 200,
                      child: InAppWebView(
                          initialUrlRequest:
                              URLRequest(url: Uri.parse(liveStreamUrl))))
                  : SizedBox(),
              Expanded(
                  child: racesSportType == 0
                      ? ListView.builder(
                          itemCount: state.racesTournamentListCommon
                              .where((e) => e['status'] == "1")
                              .toList()
                              .length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Container(
                                key: Key(
                                    "${state.racesTournamentListCommon.where((e) => e['status'] == "1").toList()[index]['matchId']}"),
                                constraints: new BoxConstraints(
                                  minHeight: 200.0,
                                ),
                                alignment: Alignment.center,
                                child: RaceBoard(
                                    index: index,
                                    webSocketReConnect:
                                        state.webSocketReConnect,
                                    raceInfo: state.racesTournamentListCommon
                                        .where((e) => e['status'] == "1")
                                        .toList()[index],
                                    store: widget.store,
                                    liveStreamEnabled: liveStreamEnabled, 
                                    toggleLiveStream: () {
                    toggleLiveStream();
                  }));
                          })
                      : ListView.builder(
                          itemCount:
                              state.racesTournamentList[0]['countries'].length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Container(
                                key: Key(
                                    "races-country-${state.racesTournamentList[0]['countries'][index]['id']}"),
                                constraints: new BoxConstraints(
                                  minHeight: 50.0,
                                  minWidth: 200.0,
                                ),
                                alignment: Alignment.center,
                                child: RaceCountryBoard(
                                    index: index,
                                    countryInfo: state.racesTournamentList[0]
                                        ['countries'][index],
                                    countryCode: countries.firstWhere(
                                                (e) =>
                                                    e['alpha3'] ==
                                                    state.racesTournamentList[0]
                                                            ['countries'][index]
                                                            ['iso3']
                                                        .toLowerCase(),
                                                orElse: () => "") !=
                                            ""
                                        ? countries.firstWhere(
                                            (e) => e['alpha3'] == state.racesTournamentList[0]['countries'][index]['iso3'].toLowerCase(),
                                            orElse: () => "")['alpha2']
                                        : ""));
                          }))
            ],
          );
        });
  }
}
