class SetliveInfoAction {
  final List liveInfo;
  SetliveInfoAction({required this.liveInfo});
}

class RemoveliveInfoAction {
  final Map liveInfo;

  RemoveliveInfoAction({required this.liveInfo});
}

class SetliveInfoCommonAction {
  final List liveInfoCommon;

  SetliveInfoCommonAction({required this.liveInfoCommon});
}

class RemoveliveInfoCommonAction {
  final List liveInfoCommon;

  RemoveliveInfoCommonAction({required this.liveInfoCommon});
}

class SetliveMatchesAction {
  final Map liveMatches;

  SetliveMatchesAction({required this.liveMatches});
}

class SetliveMatchesStatusAction {
  final Map liveMatches;
  SetliveMatchesStatusAction({required this.liveMatches});
}

class SetliveMatchesMetaAction {
  final Map liveMatchesMeta;

  SetliveMatchesMetaAction({required this.liveMatchesMeta});
}

class SetPrematchInfoAction {
  final List prematchInfo;
  SetPrematchInfoAction({required this.prematchInfo});
}

class RemovePrematchInfoAction {
  final List prematchInfo;

  RemovePrematchInfoAction({required this.prematchInfo});
}

class SetOddsAction {
  final Map odds;

  SetOddsAction({required this.odds});
}

class RemoveOddsAction {
  final Map odds;

  RemoveOddsAction({required this.odds});
}

class RemoveAllOddsAction {
  final List odds;

  RemoveAllOddsAction({required this.odds});
}

class SetHorsesOddsAction {
  final Map horsesOdds;

  SetHorsesOddsAction({required this.horsesOdds});
}

class RemoveHorsesOddsAction {
  final Map horsesOdds;

  RemoveHorsesOddsAction({required this.horsesOdds});
}

class RemoveAllHorsesOddsAction {
  final List horsesOdds;

  RemoveAllHorsesOddsAction({required this.horsesOdds});
}

class SetDogsOddsAction {
  final Map dogsOdds;

  SetDogsOddsAction({required this.dogsOdds});
}

class RemoveDogsOddsAction {
  final Map dogsOdds;

  RemoveDogsOddsAction({required this.dogsOdds});
}

class RemoveAllDogsOddsAction {
  final List dogsOdds;

  RemoveAllDogsOddsAction({required this.dogsOdds});
}

class SetUserIdAction {
  final int userId;

  SetUserIdAction({required this.userId});
}

class SetAuthorizationAction {
  final bool authorization;

  SetAuthorizationAction({required this.authorization});
}

class SetBonusBalanceAction {
  final List bonusBalance;

  SetBonusBalanceAction({required this.bonusBalance});
}

class SetOddsBetDomainInfoAction {
  final Map oddsBetDomainInfo;

  SetOddsBetDomainInfoAction({required this.oddsBetDomainInfo});
}

class RemoveOddsBetDomainInfoAction {
  final Map oddsBetDomainInfo;

  RemoveOddsBetDomainInfoAction({required this.oddsBetDomainInfo});
}

class UpdateStatusOddsBetDomainInfoAction {
  final Map oddsBetDomainInfo;

  UpdateStatusOddsBetDomainInfoAction({required this.oddsBetDomainInfo});
}

class SetMatchObjAction {
  final Map matchObj;

  SetMatchObjAction({required this.matchObj});
}

class RemoveMatchObjAction {
  final Map matchObj;

  RemoveMatchObjAction({required this.matchObj});
}

class RemoveAllMatchObjAction {
  final List matchObj;

  RemoveAllMatchObjAction({required this.matchObj});
}

class SetLimitsAction {
  final Map limits;

  SetLimitsAction({required this.limits});
}

class SetCurrencyAction {
  final String currency;

  SetCurrencyAction({required this.currency});
}

class SetPrematchSubscribeListAction {
  final Map prematchSubscribeList;

  SetPrematchSubscribeListAction({required this.prematchSubscribeList});
}

class RemovePrematchSubscribeListAction {
  final List prematchSubscribeList;

  RemovePrematchSubscribeListAction({required this.prematchSubscribeList});
}

class SetPrematchUnSubscribeListAction {
  final Map prematchUnSubscribeList;

  SetPrematchUnSubscribeListAction({required this.prematchUnSubscribeList});
}

class RemovePrematchUnSubscribeListAction {
  final List prematchUnSubscribeList;

  RemovePrematchUnSubscribeListAction({required this.prematchUnSubscribeList});
}

class SetPrematchMatchAction {
  final List prematchMatch;

  SetPrematchMatchAction({required this.prematchMatch});
}

class RemovePrematchMatchAction {
  final List prematchMatch;

  RemovePrematchMatchAction({required this.prematchMatch});
}

class SetPrematchBetDomainsAction {
  final Map prematchBetDomains;

  SetPrematchBetDomainsAction({required this.prematchBetDomains});
}

class RemovePrematchBetDomainsAction {
  final Map prematchBetDomains;

  RemovePrematchBetDomainsAction({required this.prematchBetDomains});
}

class SetPrematchBetdomainsGroupAction {
  final Map prematchBetdomainsGroup;

  SetPrematchBetdomainsGroupAction({required this.prematchBetdomainsGroup});
}

class RemovePrematchBetdomainsGroupAction {
  final Map prematchBetdomainsGroup;

  RemovePrematchBetdomainsGroupAction({required this.prematchBetdomainsGroup});
}

class SetMatchDetailsSubscribeListAction {
  final Map matchDetailsSubscribeList;

  SetMatchDetailsSubscribeListAction({required this.matchDetailsSubscribeList});
}

class RemoveMatchDetailsSubscribeListAction {
  final Map matchDetailsSubscribeList;

  RemoveMatchDetailsSubscribeListAction(
      {required this.matchDetailsSubscribeList});
}

class SetMatchDetailsUnSubscribeListAction {
  final Map matchDetailsUnSubscribeList;

  SetMatchDetailsUnSubscribeListAction(
      {required this.matchDetailsUnSubscribeList});
}

class RemovematchDetailsUnSubscribeListAction {
  final List matchDetailsUnSubscribeList;

  RemovematchDetailsUnSubscribeListAction(
      {required this.matchDetailsUnSubscribeList});
}

class SetMatchDetailsMatchDataAction {
  final Map matchDetailsMatchData;

  SetMatchDetailsMatchDataAction({required this.matchDetailsMatchData});
}

class RemoveMatchDetailsMatchDataAction {
  final List matchDetailsMatchData;

  RemoveMatchDetailsMatchDataAction({required this.matchDetailsMatchData});
}

class SetMatchDetailsDomainsAction {
  final Map matchDetailsBetDomains;

  SetMatchDetailsDomainsAction({required this.matchDetailsBetDomains});
}

class UpdatetMatchDetailsDomainsAction {
  final Map matchDetailsBetDomains;

  UpdatetMatchDetailsDomainsAction({required this.matchDetailsBetDomains});
}

class RemoveMatchDetailsBetDomainsAction {
  final Map matchDetailsBetDomains;

  RemoveMatchDetailsBetDomainsAction({required this.matchDetailsBetDomains});
}

class SetUserDataAction {
  final List userData;

  SetUserDataAction({required this.userData});
}

class RemoveUserDataAction {
  final List userData;

  RemoveUserDataAction({required this.userData});
}

class SetMyBetsTicketsAction {
  final List myBetsTickets;

  SetMyBetsTicketsAction({required this.myBetsTickets});
}

class RemoveMyBetsTicketsAction {
  final List myBetsTickets;

  RemoveMyBetsTicketsAction({required this.myBetsTickets});
}

class SetActiveBonusAction {
  final Map activeBonus;

  SetActiveBonusAction({required this.activeBonus});
}

class RemoveActiveBonusAction {
  final Map activeBonus;

  RemoveActiveBonusAction({required this.activeBonus});
}

class SetTopTournamentListAction {
  final List topTournamentList;

  SetTopTournamentListAction({required this.topTournamentList});
}

class RemoveTopTournamentListAction {
  final List topTournamentList;

  RemoveTopTournamentListAction({required this.topTournamentList});
}

class SetSelectedTopTournamentAction {
  final Map selectedTopTournament;

  SetSelectedTopTournamentAction({required this.selectedTopTournament});
}

class RemoveSelectedTopTournamentAction {
  final Map selectedTopTournament;

  RemoveSelectedTopTournamentAction({required this.selectedTopTournament});
}

class SetSelectedTopTournamentDataAction {
  final Map selectedTopTournamentData;

  SetSelectedTopTournamentDataAction({required this.selectedTopTournamentData});
}

class UpdateSelectedTopTournamentMatchDataAction {
  final Map selectedTopTournamentData;

  UpdateSelectedTopTournamentMatchDataAction(
      {required this.selectedTopTournamentData});
}

class UpdateSelectedTopTournamentBetDomainStatusDataAction {
  final Map selectedTopTournamentData;

  UpdateSelectedTopTournamentBetDomainStatusDataAction(
      {required this.selectedTopTournamentData});
}

class RemoveSelectedTopTournamentDataAction {
  final Map selectedTopTournamentData;

  RemoveSelectedTopTournamentDataAction(
      {required this.selectedTopTournamentData});
}

class SetpPopularMatchesDataAction {
  final List popularMatchesData;

  SetpPopularMatchesDataAction({required this.popularMatchesData});
}

class UpdatePopularMatchesDataAction {
  final List popularMatchesData;

  UpdatePopularMatchesDataAction({required this.popularMatchesData});
}

class RemovePopularMatchesDataAction {
  final List popularMatchesData;

  RemovePopularMatchesDataAction({required this.popularMatchesData});
}

class RemoveMatchPopularMatchesDataAction {
  final int popularMatchesData;

  RemoveMatchPopularMatchesDataAction({required this.popularMatchesData});
}

class SetPopularMatchesMetaDataAction {
  final List popularMatchesMetaData;

  SetPopularMatchesMetaDataAction({required this.popularMatchesMetaData});
}

class RemovePopularMatchesMetaDataAction {
  final List popularMatchesMetaData;

  RemovePopularMatchesMetaDataAction({required this.popularMatchesMetaData});
}

class SetShowErrorDialogAction {
  final bool showErrorDialog;

  SetShowErrorDialogAction({required this.showErrorDialog});
}

class SetWebSocketReConnectAction {
  final int webSocketReConnect;

  SetWebSocketReConnectAction({required this.webSocketReConnect});
}

class SetRacesTournamentListAction {
  final List racesTournamentList;

  SetRacesTournamentListAction({required this.racesTournamentList});
}

class RemoveRacesTournamentListAction {
  final List racesTournamentList;

  RemoveRacesTournamentListAction({required this.racesTournamentList});
}

class SetRacesTournamentListCommonAction {
  final List racesTournamentListCommon;

  SetRacesTournamentListCommonAction({required this.racesTournamentListCommon});
}

class RemoveRacesTournamentListCommonAction {
  final List racesTournamentListCommon;

  RemoveRacesTournamentListCommonAction(
      {required this.racesTournamentListCommon});
}

class SetRacesSportNameAction {
  final String racesSportName;

  SetRacesSportNameAction({required this.racesSportName});
}
