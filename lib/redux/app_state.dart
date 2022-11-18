class AppState {
  final List liveInfo;
  final List liveMatches;
  final List liveMatchesMeta;
  final List odds;
  final List horsesOdds;
  final List dogsOdds;
  final List liveInfoCommon;
  final List prematchInfo;
  final int userId;
  final bool authorization;
  final List bonusBalance;
  final List oddsBetDomainInfo;
  final List matchObj;
  final Map limits;
  final String currency;
  final List prematchSubscribeList;
  final List prematchUnSubscribeList;
  final List prematchMatch;
  final List prematchBetDomains;
  final List prematchBetdomainsGroup;
  final List matchDetailsMatchData;
  final List matchDetailsSubscribeList;
  final List matchDetailsUnSubscribeList;
  final List matchDetailsBetDomains;
  final List userData;
  final List userDataObj;
  final List myBetsTickets;
  final Map activeBonus;
  final List topTournamentList;
  final Map selectedTopTournament;
  final Map selectedTopTournamentData;
  final List popularMatchesData;
  final List popularMatchesMetaData;
  final bool showErrorDialog;
  final int webSocketReConnect;
  final List racesTournamentList;
  final List racesTournamentListCommon;
  final String racesSportName;

  AppState(
      {required this.liveInfo,
      required this.liveMatches,
      required this.liveMatchesMeta,
      required this.odds,
      required this.horsesOdds,
      required this.dogsOdds,
      required this.liveInfoCommon,
      required this.prematchInfo,
      required this.userId,
      required this.authorization,
      required this.bonusBalance,
      required this.oddsBetDomainInfo,
      required this.matchObj,
      required this.limits,
      required this.currency,
      required this.prematchSubscribeList,
      required this.prematchUnSubscribeList,
      required this.prematchMatch,
      required this.prematchBetDomains,
      required this.prematchBetdomainsGroup,
      required this.matchDetailsMatchData,
      required this.matchDetailsBetDomains,
      required this.matchDetailsSubscribeList,
      required this.matchDetailsUnSubscribeList,
      required this.userData,
      required this.userDataObj,
      required this.myBetsTickets,
      required this.activeBonus,
      required this.topTournamentList,
      required this.selectedTopTournament,
      required this.selectedTopTournamentData,
      required this.popularMatchesData,
      required this.popularMatchesMetaData,
      required this.showErrorDialog,
      required this.webSocketReConnect,
      required this.racesTournamentList,
      required this.racesTournamentListCommon,
      required this.racesSportName});
}
