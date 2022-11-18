import 'app_state.dart';
import 'actions.dart';

AppState reducer(AppState state, dynamic action) => AppState(
    liveInfo: _liveInfoReducer(state, action),
    liveInfoCommon: _liveInfoCommonReducer(state, action),
    liveMatches: _liveMatchesReducer(state, action),
    liveMatchesMeta: _liveMatchesMetaReducer(state, action),
    odds: _oddsAddReducer(state, action),
    horsesOdds: _horsesOddsAddReducer(state, action),
    dogsOdds: _dogsOddsAddReducer(state, action),
    userId: _userIdAddReducer(state, action),
    authorization: _authorizationAddReducer(state, action),
    userData: _userDataAddReducer(state, action),
    userDataObj: _userDataObjAddReducer(state, action),
    bonusBalance: _bonusBalanceAddReducer(state, action),
    oddsBetDomainInfo: _oddsBetDomainInfoAddReducer(state, action),
    matchObj: _matchObjAddReducer(state, action),
    limits: _limitsAddReducer(state, action),
    currency: _currencyAddReducer(state, action),
    prematchInfo: _prematchInfoReducer(state, action),
    prematchSubscribeList: _prematchSubscribeListReducer(state, action),
    prematchMatch: _prematchMatchReducer(state, action),
    prematchUnSubscribeList: _prematchUnSubscribeListReducer(state, action),
    prematchBetDomains: _prematchBetDomainsReducer(state, action),
    prematchBetdomainsGroup: prematchBetdomainsGroupReducer(state, action),
    matchDetailsMatchData: _matchDetailsMatchDataReducer(state, action),
    matchDetailsBetDomains: _matchDetailsBetDomainsReducer(state, action),
    matchDetailsSubscribeList: _matchDetailsSubscribeListReducer(state, action),
    matchDetailsUnSubscribeList:
        _matchDetailsUnSubscribeListReducer(state, action),
    myBetsTickets: _myBetsTicketsReducer(state, action),
    activeBonus: _activeBonusReducer(state, action),
    topTournamentList: _topTournamentListReducer(state, action),
    selectedTopTournament: _selectedTopTournamentReducer(state, action),
    selectedTopTournamentData: _selectedTopTournamentDataReducer(state, action),
    popularMatchesData: _popularMatchesDataReducer(state, action),
    popularMatchesMetaData: _popularMatchesMetaDataReducer(state, action),
    showErrorDialog: _showErrorDialogReducer(state, action),
    webSocketReConnect: _webSocketReConnectReducer(state, action),
    racesSportName: _racesSportNameReducer(state, action),
    racesTournamentList: _racesTournamentListReducer(state, action),
    racesTournamentListCommon:
        _racesTournamentListCommonReducer(state, action));

_liveInfoReducer(AppState state, dynamic action) {
  if (action is SetliveInfoAction) {
    List data = [];

    action.liveInfo.forEach((sport) => {
          sport['countries'].forEach((country) => {
                country['tournaments'].forEach((tournament) => {
                      tournament['matchIds'].forEach((e) => {
                            data.add({
                              'matchId': e.toString(),
                              'countryId': country['id'].toString(),
                              'sportId': sport['id'].toString(),
                              'startDate': tournament['matchMenuDtos'] != null
                                  ? tournament['matchMenuDtos']
                                      .firstWhere((element) =>
                                          element['matchId'] == e)['startDate']
                                      .toString()
                                  : "0"
                            }),
                          })
                    })
              })
        });

    return data;
  } else if (action is RemoveliveInfoAction) {
    List data = state.liveInfo;

    final index = data.indexWhere(
        (element) => element['matchId'] == action.liveInfo['matchId']);

    if (index >= 0) {
      data.removeAt(index);
    }

    return data;
  } else {
    return state.liveInfo;
  }
}

_liveInfoCommonReducer(AppState state, dynamic action) {
  if (action is SetliveInfoCommonAction) {
    return action.liveInfoCommon;
  } else if (action is RemoveliveInfoCommonAction) {
    return [];
  } else {
    return state.liveInfoCommon;
  }
}

_liveMatchesReducer(AppState state, dynamic action) {
  if (action is SetliveMatchesAction) {
    List data = state.liveMatches;
    if (action.liveMatches.length > 0) {
      final index = state.liveMatches.indexWhere(
          (element) => element['matchId'] == action.liveMatches['matchId']);

      if (index >= 0) {
        state.liveMatches[index] = action.liveMatches;
      } else {
        data.add(action.liveMatches);
      }
    }
    //data.add(action.liveMatches)

    return data;
  } else if (action is SetliveMatchesStatusAction) {
    final index = state.liveMatches.indexWhere(
        (element) => element['matchId'] == action.liveMatches['matchId']);
    if (index >= 0) {
      state.liveMatches[index]['liveBetStatus'] = action.liveMatches['status'];
      // match.liveBetStatus = 16 //action.payload.matchStatusMessage
    }
    return state.liveMatches;
  } else
    return state.liveMatches;
}

_liveMatchesMetaReducer(AppState state, dynamic action) {
  if (action is SetliveMatchesMetaAction) {
    List data = state.liveMatchesMeta;
    if (action.liveMatchesMeta.length > 0) {
      final index = data.indexWhere(
          (element) => element['matchId'] == action.liveMatchesMeta['matchId']);

      if (index >= 0) {
        data[index] = action.liveMatchesMeta;
      } else {
        data.add(action.liveMatchesMeta);
      }
    }
    //data.add(action.liveMatchesMeta)

    return data;
  } else
    return state.liveMatchesMeta;
}

_prematchInfoReducer(AppState state, dynamic action) {
  if (action is SetPrematchInfoAction) {
    List data = action.prematchInfo;

    return data;
  } else if (action is RemovePrematchInfoAction) {
    List data = action.prematchInfo;
    return data;
  } else {
    return state.prematchInfo;
  }
}

_prematchSubscribeListReducer(AppState state, dynamic action) {
  List data = [];
  if (action is SetPrematchSubscribeListAction) {
    data.add(action.prematchSubscribeList);
    return data;
  } else if (action is RemovePrematchSubscribeListAction) {
    return data;
  } else {
    return state.prematchSubscribeList;
  }
}

_prematchUnSubscribeListReducer(AppState state, dynamic action) {
  List data = [];
  if (action is SetPrematchUnSubscribeListAction) {
    data.add(action.prematchUnSubscribeList);
    return data;
  } else if (action is RemovePrematchUnSubscribeListAction) {
    return data;
  } else {
    return state.prematchUnSubscribeList;
  }
}

_oddsAddReducer(AppState state, dynamic action) {
  List data = state.odds;
  if (action is SetOddsAction) {
    if (action.odds.length > 0) {
      final index = state.odds
          .indexWhere((element) => element['oddId'] == action.odds['oddId']);

      if (index >= 0) {
        state.odds[index] = action.odds;
      } else {
        data = [...data, action.odds];
        //return state.odds;
      }
    }
    //data.add(action.odds)

  } else if (action is RemoveOddsAction) {
    if (action.odds.length > 0) {
      data = data
          .where((element) => element['oddId'] != action.odds['oddId'])
          .toList();
    }
  } else if (action is RemoveAllOddsAction) {
    data = action.odds;
  }
  return [...data];
}

_horsesOddsAddReducer(AppState state, dynamic action) {
  List data = state.horsesOdds;
  if (action is SetHorsesOddsAction) {
    if (action.horsesOdds.length > 0) {
      final index = state.horsesOdds.indexWhere(
          (element) => element['oddId'] == action.horsesOdds['oddId']);

      if (index >= 0) {
        state.horsesOdds[index] = action.horsesOdds;
      } else {
        data = [...data, action.horsesOdds];
        //return state.odds;
      }
    }
    //data.add(action.odds)

  } else if (action is RemoveHorsesOddsAction) {
    if (action.horsesOdds.length > 0) {
      data = data
          .where((element) => element['oddId'] != action.horsesOdds['oddId'])
          .toList();
    }
  } else if (action is RemoveAllHorsesOddsAction) {
    data = action.horsesOdds;
  }
  return [...data];
}

_dogsOddsAddReducer(AppState state, dynamic action) {
  List data = state.dogsOdds;
  if (action is SetDogsOddsAction) {
    if (action.dogsOdds.length > 0) {
      final index = state.dogsOdds.indexWhere(
          (element) => element['oddId'] == action.dogsOdds['oddId']);

      if (index >= 0) {
        state.dogsOdds[index] = action.dogsOdds;
      } else {
        data = [...data, action.dogsOdds];
        //return state.odds;
      }
    }
    //data.add(action.odds)

  } else if (action is RemoveDogsOddsAction) {
    if (action.dogsOdds.length > 0) {
      data = data
          .where((element) => element['oddId'] != action.dogsOdds['oddId'])
          .toList();
    }
  } else if (action is RemoveAllDogsOddsAction) {
    data = action.dogsOdds;
  }
  return [...data];
}

_userIdAddReducer(AppState state, dynamic action) {
  if (action is SetUserIdAction) {
    return action.userId;
  }
  return state.userId;
}

_authorizationAddReducer(AppState state, dynamic action) {
  if (action is SetAuthorizationAction) {
    return action.authorization;
  }
  return state.authorization;
}

_bonusBalanceAddReducer(AppState state, dynamic action) {
  if (action is SetBonusBalanceAction) {
    return action.bonusBalance;
  }
  return state.bonusBalance;
}

_oddsBetDomainInfoAddReducer(AppState state, dynamic action) {
  if (action is SetOddsBetDomainInfoAction) {
    List data = state.oddsBetDomainInfo;

    final index = data.indexWhere((element) =>
        element['betDomainId'] == action.oddsBetDomainInfo['betDomainId']);

    if (index >= 0) {
      data[index] = action.oddsBetDomainInfo;
      return data;
    } else {
      data = [...data, action.oddsBetDomainInfo];
      return data;
    }
  } else if (action is RemoveOddsBetDomainInfoAction) {
    List data = state.oddsBetDomainInfo;

    if (action.oddsBetDomainInfo.length > 0) {
      data = data
          .where((element) =>
              element['betDomainId'] != action.oddsBetDomainInfo['betDomainId'])
          .toList();
    }

    return data;
  } else if (action is UpdateStatusOddsBetDomainInfoAction) {
    List data = state.oddsBetDomainInfo;

    final index = data.indexWhere((element) =>
        element['betDomainId'].toString() ==
        action.oddsBetDomainInfo['betdomainIdToStatusMap'].keys.first);

    if (index >= 0) {
      data[index]['status'] = action.oddsBetDomainInfo['betdomainIdToStatusMap']
          [data[index]['betDomainId'].toString()];
      return data;
    } else {
      return data;
    }
  } else {
    return state.oddsBetDomainInfo;
  }
}

_matchObjAddReducer(AppState state, dynamic action) {
  List data = state.matchObj;
  if (action is SetMatchObjAction) {
    final index = state.matchObj
        .indexWhere((element) => element['OddId'] == action.matchObj['OddId']);

    if (index >= 0) {
      state.matchObj[index] = action.matchObj;
    } else {
      data = [...data, action.matchObj];
      //return state.matchObj;
    }

    //data.add(action.matchObj)

  } else if (action is RemoveMatchObjAction) {
    data = data
        .where((element) => element['OddId'] != action.matchObj['oddId'])
        .toList();
  } else if (action is RemoveAllMatchObjAction) {
    data = [];
  }
  return data;
}

_limitsAddReducer(AppState state, dynamic action) {
  if (action is SetLimitsAction) {
    return action.limits;
  }
  return state.limits;
}

_currencyAddReducer(AppState state, dynamic action) {
  if (action is SetCurrencyAction) {
    return action.currency;
  }
  return state.currency;
}

_prematchMatchReducer(AppState state, dynamic action) {
  if (action is SetPrematchMatchAction) {
    List data = [];
    List matches = action.prematchMatch;
    Map matchesInfo = {};

    matches.forEach((match) {
      matchesInfo[match['matchId']] = {
        'betdomainSize': match['betdomainSize'],
        'matchId': match['matchId'],
        'startDate': match['startDate'],
        'state': match['state'],
        'liveBetStatus': match['liveBetStatus'],
        'isLiveBet': match['isLiveBet'],
        'matchtocompetitors': match['matchtocompetitors'],
        'matchCode': match['code'],
        'sourceType': match['sourceType'],
        'outrightType': match['outrightType'],
        'sportId': match['sport']['sportId']
      };
      data.add(matchesInfo[match['matchId']]);
    });

    return data;
  } else if (action is RemovePrematchMatchAction) {
    return [];
  } else {
    return state.prematchMatch;
  }
}

_prematchBetDomainsReducer(AppState state, dynamic action) {
  if (action is SetPrematchBetDomainsAction) {
    List data = [];
    List matches = action.prematchBetDomains['matchs'];
    Map matchesInfo = {};
    matches.forEach((match) {
      matchesInfo[match['matchId']] = match['betdomains'];
    });
    data.add(matchesInfo);
    return data;
  } else if (action is RemovePrematchBetDomainsAction) {
    return [];
  } else {
    return state.prematchBetDomains;
  }
}

prematchBetdomainsGroupReducer(AppState state, dynamic action) {
  if (action is SetPrematchBetdomainsGroupAction) {
    List data = [];
    List matches = action.prematchBetdomainsGroup['prematchBetdomainGroups'];

    matches.forEach((element) {
      if (element['sort'] == null) {
        element['sort'] = 99999;
      }
    });

    Map matchesInfo = {};
    List<int> matchList = [];

    action.prematchBetdomainsGroup['matchs'].forEach((match) {
      matchList.add(match['matchId']);
    });

    action.prematchBetdomainsGroup['prematchBetdomainGroups']
        .sort((a, b) => a["sort"].compareTo(b["sort"]) as int);

    matchesInfo['sport'] = action.prematchBetdomainsGroup['sport']['sportId'];
    matchesInfo['sportName'] =
        action.prematchBetdomainsGroup['sport']['defaultName'];
    matchesInfo['country'] = action.prematchBetdomainsGroup['country'];
    matchesInfo['tournament'] = action.prematchBetdomainsGroup['tournamentId'];
    matchesInfo['groups'] =
        action.prematchBetdomainsGroup['prematchBetdomainGroups'];
    matchesInfo['matchList'] = matchList;
    matchesInfo['activeGroup'] = action.prematchBetdomainsGroup['activeGroup'];

    data.add(matchesInfo);

    return data;
  } else if (action is RemovePrematchBetdomainsGroupAction) {
    return [];
  } else {
    return state.prematchBetdomainsGroup;
  }
}

_matchDetailsMatchDataReducer(AppState state, dynamic action) {
  List data = [];
  if (action is SetMatchDetailsMatchDataAction) {
    Map match = action.matchDetailsMatchData;
    Map matchesInfo = {};
    if (match['isLiveBet']) {
      match['liveBetdomainGroups']
          .sort((a, b) => a["sort"].compareTo(b["sort"]) as int);
    } else {
      match['prematchBetdomainGroups']
          .sort((a, b) => a["sort"].compareTo(b["sort"]) as int);
    }

    matchesInfo[match['matchId']] = {
      'tournamentName': match['tournamentName'],
      'tournamentId': match['tournamentId'],
      'country': match['country']['countryId'],
      'matchId': match['matchId'],
      'startDate': match['startDate'],
      'state': match['state'],
      'liveBetStatus': match['liveBetStatus'],
      'isLiveBet': match['isLiveBet'],
      'matchtocompetitors': match['matchtocompetitors'],
      'matchCode': match['code'],
      'sourceType': match['sourceType'],
      'venue': match['venue'] != null ? match['venue'] : null,
      'sport': match['sport'],
      'betdomainGroups': match['isLiveBet']
          ? match['liveBetdomainGroups']
          : match['prematchBetdomainGroups']
    };
    data.add(matchesInfo[match['matchId']]);

    return data;
  } else if (action is RemoveMatchDetailsMatchDataAction) {
    return [];
  } else {
    return state.matchDetailsMatchData;
  }
}

_matchDetailsBetDomainsReducer(AppState state, dynamic action) {
  if (action is SetMatchDetailsDomainsAction) {
    List data = [];
    List betDomains = action.matchDetailsBetDomains['betdomains'];
    List betDomainsList = [];
    betDomains.forEach((betDomain) {
      betDomainsList.add(betDomain['betDomainId']);
    });

    data = [
      ...state.matchDetailsBetDomains
          .where((e) => !betDomainsList.contains(e['betDomainId']))
          .toList(),
      ...betDomains
    ];

    return data;
  } else if (action is UpdatetMatchDetailsDomainsAction) {
    var st = state.matchDetailsBetDomains.map((e) {
      if (e['matchId'] == action.matchDetailsBetDomains['matchId'] &&
          action.matchDetailsBetDomains['betdomainIdToStatusMap']
              .containsKey(e['betDomainId'].toString())) {
        e['status'] = action.matchDetailsBetDomains['betdomainIdToStatusMap']
            [e['betDomainId'].toString()];
      }
      return e;
    }).toList();

    return [...st];
  } else if (action is RemoveMatchDetailsBetDomainsAction) {
    return [];
  } else {
    return state.matchDetailsBetDomains;
  }
}

_matchDetailsSubscribeListReducer(AppState state, dynamic action) {
  List data = state.matchDetailsSubscribeList;

  if (action is SetMatchDetailsSubscribeListAction) {
    final index = data.indexWhere((e) =>
        e['matchId'] == action.matchDetailsSubscribeList['matchId'] &&
        e['groups'][0] == action.matchDetailsSubscribeList['groups'][0]);

    if (index >= 0) {
      data[index] = action.matchDetailsSubscribeList;
    } else {
      data = [...data, action.matchDetailsSubscribeList];
    }
    return data;
  } else if (action is RemoveMatchDetailsSubscribeListAction) {
    final index = data.indexWhere((e) =>
        e['matchId'] == action.matchDetailsSubscribeList['matchId'] &&
        e['groups'][0] == action.matchDetailsSubscribeList['groups'][0]);

    if (index >= 0) {
      data.removeAt(index);
    }
    return data;
  } else {
    return state.matchDetailsSubscribeList;
  }
}

_matchDetailsUnSubscribeListReducer(AppState state, dynamic action) {
  List data = [];
  if (action is SetMatchDetailsUnSubscribeListAction) {
    data.add(action.matchDetailsUnSubscribeList);
    return [...state.matchDetailsUnSubscribeList, ...data];
  } else if (action is RemovematchDetailsUnSubscribeListAction) {
    return [...data];
  } else {
    return state.matchDetailsUnSubscribeList;
  }
}

_userDataAddReducer(AppState state, dynamic action) {
  if (action is SetUserDataAction) {
    Map newUserDataFormat = {};
    action.userData[0].forEach((e) {
      newUserDataFormat[e['name']] = e['value'];
    });
    return [newUserDataFormat];
  } else if (action is RemoveUserDataAction) {
    return [];
  } else {
    return state.userData;
  }
}

_userDataObjAddReducer(AppState state, dynamic action) {
  if (action is SetUserDataAction) {
    return [...action.userData];
  } else if (action is RemoveUserDataAction) {
    return [];
  } else {
    return state.userDataObj;
  }
}

_myBetsTicketsReducer(AppState state, dynamic action) {
  if (action is SetMyBetsTicketsAction) {
    List data = state.myBetsTickets;

    action.myBetsTickets.forEach((e) {
      final index =
          data.indexWhere((val) => e['ticketNbr'] == val['ticketNbr']);
      if (index != -1) {
        data[index] = e;
      } else {
        data.add(e);
      }
    });

    return [...data];
  } else if (action is RemoveMyBetsTicketsAction) {
    return [];
  } else
    return state.myBetsTickets;
}

_activeBonusReducer(AppState state, dynamic action) {
  if (action is SetActiveBonusAction) {
    return action.activeBonus;
  } else if (action is RemoveActiveBonusAction) {
    return {};
  } else {
    return state.activeBonus;
  }
}

_topTournamentListReducer(AppState state, dynamic action) {
  if (action is SetTopTournamentListAction) {
    return action.topTournamentList;
  } else if (action is RemoveTopTournamentListAction) {
    return [];
  } else {
    return state.topTournamentList;
  }
}

_selectedTopTournamentReducer(AppState state, dynamic action) {
  if (action is SetSelectedTopTournamentAction) {
    return action.selectedTopTournament;
  } else if (action is RemoveSelectedTopTournamentAction) {
    return {};
  } else {
    return state.selectedTopTournament;
  }
}

_selectedTopTournamentDataReducer(AppState state, dynamic action) {
  if (action is SetSelectedTopTournamentDataAction) {
    return action.selectedTopTournamentData;
  } else if (action is RemoveSelectedTopTournamentDataAction) {
    return {};
  } else if (action is UpdateSelectedTopTournamentMatchDataAction) {
    if (state.selectedTopTournamentData['matchs'].length > 0) {
      action.selectedTopTournamentData['matchs'].forEach((newMatch) {
        final index = state.selectedTopTournamentData['matchs']
            .indexWhere((element) => element['matchId'] == newMatch['matchId']);

        if (index != -1) {
          state.selectedTopTournamentData['matchs'][index] = newMatch;
        } else {
          state.selectedTopTournamentData['matchs'].add(newMatch);
        }
      });
    }
    return state.selectedTopTournamentData;
  } else if (action is UpdateSelectedTopTournamentBetDomainStatusDataAction) {
    if (state.selectedTopTournamentData['matchs'] != null) {
      final index = state.selectedTopTournamentData['matchs'].indexWhere(
          (element) =>
              element['matchId'] ==
              action.selectedTopTournamentData['matchId']);
      if (index == -1) {
        return state.selectedTopTournamentData;
      } else {
        action.selectedTopTournamentData['betdomainIdToStatusMap']
            .forEach((key, e) {
          final ind = state.selectedTopTournamentData['matchs'][index]
                  ['betdomains']
              .indexWhere((el) => el['betDomainId'] == int.parse(key));
          if (ind != -1) {
            state.selectedTopTournamentData['matchs'][index]['betdomains'][ind]
                ['status'] = e;
          }
        });
      }
      return state.selectedTopTournamentData;
    }
  } else {
    return state.selectedTopTournamentData;
  }
}

_popularMatchesDataReducer(AppState state, dynamic action) {
  if (action is SetpPopularMatchesDataAction) {
    return action.popularMatchesData;
  } else if (action is RemovePopularMatchesDataAction) {
    return [];
  } else if (action is UpdatePopularMatchesDataAction) {
    if (state.popularMatchesData.length > 0) {
      action.popularMatchesData.forEach((newMatch) {
        final index = state.popularMatchesData
            .indexWhere((element) => element['matchId'] == newMatch['matchId']);

        if (index != -1) {
          state.popularMatchesData[index] = newMatch;
        } else {
          state.popularMatchesData.add(newMatch);
        }
      });
    }
    return state.popularMatchesData;
  } else if (action is RemoveMatchPopularMatchesDataAction) {
    if (state.popularMatchesData.length > 0) {
      final index = state.popularMatchesData.indexWhere(
          (element) => element['matchId'] == action.popularMatchesData);
      if (index != -1) {
        state.popularMatchesData.sublist(index);
      }
      return state.popularMatchesData;
    }
  } else {
    return state.popularMatchesData;
  }
}

_popularMatchesMetaDataReducer(AppState state, dynamic action) {
  if (action is SetPopularMatchesMetaDataAction) {
    return action.popularMatchesMetaData;
  } else if (action is RemovePopularMatchesMetaDataAction) {
    return [];
  } else {
    return state.popularMatchesMetaData;
  }
}

_showErrorDialogReducer(AppState state, dynamic action) {
  if (action is SetShowErrorDialogAction) {
    return action.showErrorDialog;
  } else {
    return state.showErrorDialog;
  }
}

_webSocketReConnectReducer(AppState state, dynamic action) {
  if (action is SetWebSocketReConnectAction) {
    return action.webSocketReConnect;
  } else {
    return state.webSocketReConnect;
  }
}

_racesSportNameReducer(AppState state, dynamic action) {
  if (action is SetRacesSportNameAction) {
    return action.racesSportName;
  } else {
    return state.racesSportName;
  }
}

_racesTournamentListReducer(AppState state, dynamic action) {
  if (action is SetRacesTournamentListAction) {
    return action.racesTournamentList;
  } else if (action is RemoveRacesTournamentListAction) {
    return [];
  } else {
    return state.racesTournamentList;
  }
}

_racesTournamentListCommonReducer(AppState state, dynamic action) {
  if (action is SetRacesTournamentListCommonAction) {
    List data = [];
    action.racesTournamentListCommon.forEach((sport) => {
          sport['countries'].forEach((country) => {
                country['tournaments'].forEach((tournament) => {
                      tournament['matchIds'].forEach((e) => {
                            data.add({
                              'matchId': e.toString(),
                              'countryId': country['id'].toString(),
                              'sportId': sport['id'].toString(),
                              'startDate': tournament['matchMenuDtos'] != null
                                  ? tournament['matchMenuDtos']
                                      .firstWhere((element) =>
                                          element['matchId'] == e)['startDate']
                                      .toString()
                                  : "0",
                              'status': tournament['matchMenuDtos'] != null
                                  ? tournament['matchMenuDtos']
                                      .firstWhere((element) =>
                                          element['matchId'] == e)['status']
                                      .toString()
                                  : "0"
                            }),
                          })
                    })
              })
        });
    data.sort((a, b) => a["startDate"].compareTo(b["startDate"]) as int);
    return data;
  } else if (action is RemoveRacesTournamentListCommonAction) {
    return [];
  } else {
    return state.racesTournamentListCommon;
  }
}
