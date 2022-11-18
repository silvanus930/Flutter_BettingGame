import 'package:flutter/material.dart';
import 'betslipListItem.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';
import '../login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'systemList.dart';
import 'package:flutter_betting_app/betslip/BSLogic.dart';
//import 'BSlogic.dart';
import '../config/defaultConfig.dart' as config;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import './myBetsModal.dart';
import 'package:share/share.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../services/storage_service.dart';

class BSForm extends StatefulWidget {
  final currentTab;

  const BSForm({Key? key, this.currentTab}) : super(key: key);

  @override
  State<BSForm> createState() => BSFormState();
}

class BSFormState extends State<BSForm> {
  List variousStakeValue = [];
  String errorText = "";
  String bonusTextAlert = "";
  bool sendRequest = false;
  double totalStake = 0;
  var systemRadioValue = 2;
  bool trigger = true;
  List bankersArray = [];
  List coefsCalcArr = [];
  List lettersArr = [];
  List systemCombos = [];
  List matchObjArr = [];
  List onlyLettersArr = [];
  int uniqeLettersLength = 0;
  Map placedBets = {};
  Map forcedBonus = {};
  var minStake = 0.0;
  var maxStake = 0.0;
  var maxWin = 0.0;
  var minCombination = 0.0;
  var maxCombination = 0.0;
  var maxSystemBet = 0;
  var maxOdd = 0.0;
  final stakeController = TextEditingController();
  var bonusAmount;
  double calculateBonus = 0.0;
  bool keyBoardVisible = false;
  var keyBoardListener;
  double sliderClosedHeight = 60.0;
  double sliderOpenedHeight = 200.0;
  bool sliderOpened = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  getArrayOdds() {
    final store = StoreProvider.of<AppState>(context);
    switch (StoreProvider.of<AppState>(context).state.racesSportName) {
      case "":
        return store.state.odds;
      case "horses":
        return store.state.horsesOdds;
      case "dogs":
        return store.state.dogsOdds;
      default:
        return store.state.odds;
    }
  }

  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        StoreProvider.of<AppState>(context).state.limits.length > 0
            ? requestLimits()
            : null);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FocusScope.of(context).unfocus());

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyBoardListener =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        keyBoardVisible = visible;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(BSForm oldWidget) {
    if (widget.currentTab != oldWidget.currentTab && widget.currentTab != 2) {
      requestLimits();
    }
    super.didUpdateWidget(oldWidget);
  }

  void dispose() {
    if (keyBoardListener != null) {
      keyBoardListener.cancel();
    }
    super.dispose();
  }

  calc(List arr) {
    if (arr.length < 2) return 0;
    List res = [];
    arr.forEach((e) {
      if (res.length == 0)
        res = e;
      else {
        List temp = [];
        e.forEach((el) {
          List temp1 = [];

          res.forEach((elem) {
            temp1.add(elem * el);
          });

          temp = [...temp, ...temp1];
        });

        res = [...temp];
      }
    });

    if (res.length == 0) {
      return 0;
    }
    // console.log("res.reduce((a,b)=>a+b)/res.length",res.reduce((a,b)=>a+b)/res.length)
    return res.reduce((a, b) => a + b) / res.length;
  }

  calcCmbTotalOdds(List matchObj) {
    // console.log("matchObjList:", props.state);
    //apply new odd value. start
    List matchObjArr = matchObj.map((e) {
      return {
        'Value': e['Value'],
        'betMarketId': e['betMarketId'],
        'MatchId': e['MatchId'],
        'OddOd': e['OddId']
      };
    }).toList();
    //apply new odd value. end
    // generateTickets.start
    Map initialObj = {};
    List initialArray = [];

    matchObjArr.forEach((
      e,
    ) =>
        {
          initialObj[e['betMarketId'] + e['MatchId']] = matchObjArr
              .where((el) =>
                  el['betMarketId'] == e['betMarketId'] &&
                  e['MatchId'] == el['MatchId'])
              .map((e) => (e['Value']))
              .toList()
        });
    // console.log("matchObjList2:", Object.values(initialObj));

    initialObj.entries.forEach((e) => initialArray.add(e.value));

    return calc(initialArray);
    // generateTickets.end
  }

  generateLetterArray(List odds, oddId) {
    List tournamentsBets = odds;
    if (oddId != null) {
      odds.map((e) => {e['oddId'] != oddId ? tournamentsBets.add(e) : null});
    }
    var letterHelper =
        new List.filled(tournamentsBets.length, "", growable: true);
    int delta = -1;

    tournamentsBets.asMap().entries.forEach((e) {
      var letterIndCounter = 1;

      List data = [];

      tournamentsBets.forEach((el) => {
            if (e.value['match'] == el['match'] &&
                e.value['betDomainId'] == el['betDomainId'])
              {data.add(1)}
            else
              {data.add(0)}
          });

      var countOfItems = data.where((e) => e == 1).length;

      if (countOfItems == 1) {
        delta += 1;
        letterHelper[e.key] = letterHelper[e.key] == ""
            ? String.fromCharCode(65 + delta)
            : letterHelper[e.key];
      } else if (countOfItems > 1) {
        delta += 1;
        data.asMap().entries.forEach((val) => {
              if (val.value == 1 && letterHelper[val.key] == "")
                {
                  letterHelper[val.key] = String.fromCharCode(65 + delta) +
                      "" +
                      letterIndCounter.toString(),
                  letterIndCounter += 1
                }
              else
                {letterHelper[e.key] = letterHelper[e.key]}
            });
      }

      // console.log("dATA", ind, " : ", data)
    });
    return letterHelper;
  }

  void addvariousStakeValue(newStake) {
    int ind = variousStakeValue
        .indexWhere((element) => element[newStake.keys.first] != null);
    if (ind != -1) {
      variousStakeValue[ind] = newStake;
    } else {
      setState(() {
        this.variousStakeValue = [...variousStakeValue, newStake];
      });
    }
  }

  void radioValueChanged(value) {
    setState(() {
      this.systemRadioValue = value;
    });

    if (widget.currentTab == 2 &&
        onlyLettersArr.length > 2 &&
        getArrayOdds().length > 2) {
      requestLimits();
    }
  }

  void toggleTrigger(val) {
    setState(() {
      this.trigger = val;
    });
  }

  void bankerChanged(val) {
    if (bankersArray.contains(val)) {
      bankersArray.removeWhere((item) => item == val);
    } else {
      bankersArray.add(val);
    }
  }

  void onSendRequest(List matchObj, Map limits, String method) async {
    int acceptedTickets = 0;
    String errorText = "";
    var result;

    setState(() => {sendRequest = true, bonusTextAlert = ""});

    for (Map element in matchObj) {
      var url = method == "place"
          ? (Uri.parse(
              '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/ticket/apply'))
          : (Uri.parse(
              '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/ticket/store'));

      var body = requestBody(element, limits, matchObj);
      bool sendAccepted = true;
      Map bonusActive = StoreProvider.of<AppState>(context).state.activeBonus;

      if (StoreProvider.of<AppState>(context).state.bonusBalance.length > 0 &&
          StoreProvider.of<AppState>(context)
                  .state
                  .bonusBalance[0]['bonusBalances']
                  .firstWhere(
                      (element) =>
                          element['forced'] == true &&
                          element['blocked'] == true,
                      orElse: () => null) !=
              null) {
        List bonusArray = StoreProvider.of<AppState>(context)
            .state
            .bonusBalance[0]['bonusBalances'];
        bonusArray.sort((a, b) => a["activeTill"].compareTo(b["activeTill"]));
        forcedBonus = bonusArray.firstWhere((element) =>
            element['forced'] == true && element['blocked'] == true);
      }

      if (forcedBonus.isNotEmpty && bonusActive.isEmpty) {
        bonusActive = forcedBonus;
      }

      if (bonusActive.isNotEmpty &&
          !(!bonusActive['blocked'] && widget.currentTab == 0)) {
        body['useBonusBalanceFrom'] = bonusActive['accountBonusCampaignId'];
      }

      if (body['stakeAmount'] < minStake && method == "place") {
        sendAccepted = false;
        if (widget.currentTab == 0) {
          setState(() {
            placedBets[element['OddId']] = {
              'accepted': false,
              'errorText': LocaleKeys.betslipStakeBelowMinimum.tr()
            };
          });
        } else {
          errorText = LocaleKeys.betslipStakeBelowMinimum.tr();
        }
      }

      if (body['stakeAmount'] > maxStake && method == "place") {
        sendAccepted = false;
        if (widget.currentTab == 0) {
          setState(() {
            placedBets[element['OddId']] = {
              'accepted': false,
              'errorText': LocaleKeys.betslipStakeExceedsMaximum.tr()
            };
          });
        } else {
          errorText = LocaleKeys.betslipStakeExceedsMaximum.tr();
        }
      }

      if (errorText != "") {
        if (widget.currentTab > 0) {
          _showUnacceptedTickets(errorText);
        }
        sendAccepted = false;
        setState(() => sendRequest = false);
      }

      if (errorText == "" && !sendAccepted) {
        setState(() => sendRequest = false);
      }

      if (sendAccepted &&
          bonusActive.isEmpty &&
          config.stakeTaxEnabled &&
          method == "place") {
        body['stakeTax'] = (body['stakeAmount'] -
                minusVAT(body['stakeAmount'], config.stakeTaxPercent))
            .toStringAsFixed(2);
        body['stakeAmount'] =
            minusVAT(body['stakeAmount'], config.stakeTaxPercent);
        body['maxWin'] =
            (body['stakeAmount'] * body['totalProbability']).toStringAsFixed(2);
      }

      if (sendAccepted) {
        final StorageService _storageService = StorageService();
        String? accessToken = method == "place"
            ? await _storageService.readSecureData('token')
            : "";
        ;
        await http
            .post(url,
                headers: {
                  "content-type": "application/json",
                  "Authorization": method == "place" ? accessToken! : "",
                },
                body: json.encode(body))
            .then((response) async {
          if (response.statusCode == 200) {
            result = jsonDecode(response.body);

            if ((bonusActive.isNotEmpty) &&
                !(!bonusActive['blocked'] && widget.currentTab == 0) &&
                method == "place") {
              await handleBonusBalance();
            }

            if (widget.currentTab == 0) {
              setState(() {
                placedBets[element['OddId']] = {
                  'accepted': true,
                  'code': method == "place"
                      ? result['response']['ticketCode']
                      : result['response']['ticketNewCode'],
                  'method': method
                };
                acceptedTickets++;
              });
            }
            setState(() {
              acceptedTickets++;
            });
          } else {
            var code;
            if (response.body.isNotEmpty) {
              result = jsonDecode(response.body);
              code = result['response']['faultCode'];
              if (code != null) {
                if (code == 217)
                  setState(() {
                    placedBets[result['response']['problemOdds'][0]['oddid']] =
                        {
                      'accepted': false,
                      'errorText': checkErrorCode(code),
                      'errorCode': code,
                      'serverOdds': result['response']['problemOdds'][0]
                          ['serverOddsValue']
                    };
                  });

                if (code == 227) {
                  matchObj.forEach((e) => {
                        if (e['MatchId'].toString() ==
                            result['response']['faultInfo']['parameters']
                                ['parameter'][0]['value'])
                          {
                            setState(() {
                              placedBets[e['OddId']] = {
                                'accepted': false,
                                'errorText': checkErrorCode(code)
                              };
                            })
                          }
                      });
                }

                if (code == 229) {
                  matchObj.forEach((e) => {
                        if (e['MatchId'].toString() ==
                            result['response']['matchId'])
                          {
                            setState(() {
                              placedBets[e['OddId']] = {
                                'accepted': false,
                                'errorText': checkErrorCode(code)
                              };
                            })
                          }
                      });
                }
                if (code != 217 &&
                    code != 227 &&
                    code != 229 &&
                    result['response']['faultInfo']['message'] != null) {
                  _showUnacceptedTickets(
                      result['response']['faultInfo']['message']);
                }
              }
            }

            if (widget.currentTab == 0 && code == null) {
              setState(() {
                placedBets[element['OddId']] = {'accepted': false};
              });
            }
          }
        });

        setState(() => sendRequest = false);
      }

      if (widget.currentTab > 0) {
        break;
      }
    }

    if (widget.currentTab > 0 &&
        acceptedTickets > 0 &&
        (result['response']['ticketCode'] != null ||
            result['response']['ticketNewCode'] != null)) {
      _showAcceptedTickets(
          method == "place"
              ? result['response']['ticketCode']
              : result['response']['ticketNewCode'],
          method);
    }
  }

  void clearBetSlip() {
    StoreProvider.of<AppState>(context)
        .dispatch(RemoveAllMatchObjAction(matchObj: []));
    if (StoreProvider.of<AppState>(context).state.racesSportName == "") {
      StoreProvider.of<AppState>(context)
          .dispatch(RemoveAllOddsAction(odds: []));
    }
    if (StoreProvider.of<AppState>(context).state.racesSportName == "horses") {
      StoreProvider.of<AppState>(context)
          .dispatch(RemoveAllHorsesOddsAction(horsesOdds: []));
    }
    if (StoreProvider.of<AppState>(context).state.racesSportName == "dogs") {
      StoreProvider.of<AppState>(context)
          .dispatch(RemoveAllDogsOddsAction(dogsOdds: []));
    }
  }

  void clearMatch(matchId, oddId) {
    List odds = getArrayOdds();

    int index = odds.indexWhere((element) => element['oddId'] == oddId);

    if (index != -1) {
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return _buildItem(index, animation, true);
      };
      _listKey.currentState!.removeItem(index, builder);
    }

    if (StoreProvider.of<AppState>(context).state.racesSportName == "") {
      StoreProvider.of<AppState>(context)
          .dispatch(RemoveOddsAction(odds: {'match': matchId, 'oddId': oddId}));
    }
    if (StoreProvider.of<AppState>(context).state.racesSportName == "horses") {
      StoreProvider.of<AppState>(context).dispatch(RemoveHorsesOddsAction(
          horsesOdds: {'match': matchId, 'oddId': oddId}));
    }
    if (StoreProvider.of<AppState>(context).state.racesSportName == "dogs") {
      StoreProvider.of<AppState>(context).dispatch(
          RemoveDogsOddsAction(dogsOdds: {'match': matchId, 'oddId': oddId}));
    }

    StoreProvider.of<AppState>(context)
        .dispatch(RemoveMatchObjAction(matchObj: {'oddId': oddId}));
  }

  void clearPlacedBet(oddId) {
    if (placedBets[oddId] != null) {
      Map newMap = {...placedBets};
      newMap.remove(oddId);

      setState(() {
        placedBets = newMap;
      });
    }
  }

  checkErrorCode(code) {
    switch (code) {
      case 217:
        return LocaleKeys.betslipAcceptNewOdds.tr();
      case 227:
        return LocaleKeys.betslipMatchStarted.tr();
      case 229:
        return LocaleKeys.betslipBetAcceptingStop.tr();
      default:
        return '';
    }
  }

  requestBody(var matchObj, Map limits, List matchObjArray) {
    var obj = {};
    var values = [];
    var valuesObject = {};
    List pageType = [];
    String pageTypeResult = "0";
    List bankers = [];
    Map bonusActive = StoreProvider.of<AppState>(context).state.activeBonus;

    if (widget.currentTab > 0) {
      matchObjArray.forEach((element) {
        var valuesObjectMul = {};
        var valuesOdds = values.length > 0
            ? values
                .where((val) => val['matchId'] == element['MatchId'])
                .toList()
            : [];

        if (values.length > 0 && valuesOdds.length > 0) {
          values
              .firstWhere((val) => val['matchId'] == element['MatchId'])['odds']
              .add(element['Odds'][0]);
        }
        if (valuesOdds.length == 0) {
          valuesObjectMul['matchId'] = element['MatchId'];
          valuesObjectMul['btrMatchId'] = element['BtrMatchId'];
          // obj.tournamentId = element.TournamentId;
          valuesObjectMul['isOutrightType'] = element['IsOutrightType'];
          valuesObjectMul['betTitle'] = element['BetTitle'];
          valuesObjectMul['betTitleType'] = element['BetTitleType'];
          valuesObjectMul['odds'] = element['Odds'];
          pageType.add(element['type']);
          if (bankersArray.contains(element['OddId'])) {
            bankers.add(valuesObjectMul);
          } else {
            values.add(valuesObjectMul);
          }
        }
      });
      if (StoreProvider.of<AppState>(context).state.racesSportName == "") {
        if (pageType.contains("prematch") && !pageType.contains("live"))
          pageTypeResult = "0";
        if (!pageType.contains("prematch") && pageType.contains("live"))
          pageTypeResult = "1";
        if (pageType.contains("prematch") && pageType.contains("live"))
          pageTypeResult = "2";
      }
      if (StoreProvider.of<AppState>(context).state.racesSportName == "horses")
        pageTypeResult = "20";
      if (StoreProvider.of<AppState>(context).state.racesSportName == "dogs")
        pageTypeResult = "21";
    } else {
      if (matchObj['Odds'] != null) {
        valuesObject['matchId'] = matchObj['MatchId'];
        valuesObject['btrMatchId'] = matchObj['BtrMatchId'];
        // obj.tournamentId = matchObj.TournamentId;
        valuesObject['isOutrightType'] = matchObj['IsOutrightType'];
        valuesObject['betTitle'] = matchObj['BetTitle'];
        valuesObject['betTitleType'] = matchObj['BetTitleType'];
        valuesObject['odds'] = matchObj['Odds'];
        values.add(valuesObject);
      }
    }

    obj['totalProbability'] = widget.currentTab > 0
        ? (widget.currentTab == 1
            ? calcCmbTotalOdds(matchObjArray)
            : totalSystemCoef(coefsCalcArr, lettersArr, matchObjArray))
        : matchObj['Value'];

    obj['stakeAmount'] = widget.currentTab > 0
        ? totalStake
        : (variousStakeValue.firstWhere(
                    (element) => element[matchObj["OddId"]] != null,
                    orElse: () => null) !=
                null
            ? int.parse(variousStakeValue.firstWhere(
                (element) => element[matchObj["OddId"]] != null,
                orElse: () => null)[matchObj["OddId"]])
            : 0);

    obj['reofferRefId'] = "";
    obj['betType'] = widget.currentTab > 0
        ? (widget.currentTab == 1 ? "cmb" : "sys")
        : "sng";
    obj['useBonusBalanceFrom'] = "";
    obj['bonusPercent'] = "1.00";

    obj['pageType'] = widget.currentTab > 0
        ? pageTypeResult
        : (matchObj["SportId"] == 100
            ? "20"
            : matchObj["SportId"] == 101
                ? "21"
                : matchObj["type"] == "live"
                    ? "1"
                    : "0");

    obj['maxWin'] = obj['stakeAmount'] * obj['totalProbability'];

    if (obj['maxWin'] > maxWin) {
      obj['maxWin'] = maxWin;
    }

    // console.log(" obj.maxWin:", obj.maxWin)
    obj['minBet'] = widget.currentTab == 1
        ? limits['multiple']['minStakeCombiBet']
        : limits['single']['minStakeSingleBet'];
    obj['values'] = widget.currentTab > 0 ? values : [values[0]];
    if (widget.currentTab > 0) {
      obj['bonusValue'] = bonusActive.isEmpty ? calculateBonus : 0;
      obj['bonusPercent'] = bonusActive.isEmpty ? (1 + (bonusAmount / 100)) : 1;

      if (widget.currentTab == 2) {
        //obj.bankers = bankerOdds;
        // console.log("Bankers", bankers)
        obj['bankers'] = bankers;
        obj['numberOfWinners'] = systemRadioValue;
      }
    }

    return obj;
  }

  handleBonusBalance() async {
    final StorageService _storageService = StorageService();

    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/profile/balance-new'));

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) {
        if (response.statusCode == 200) {
          Map bonusActive =
              StoreProvider.of<AppState>(context).state.activeBonus;

          if (forcedBonus.isNotEmpty && bonusActive.isEmpty) {
            bonusActive = forcedBonus;
          }
          var result = jsonDecode(response.body);

          List oldBonusBalance = new List.from(
              StoreProvider.of<AppState>(context).state.bonusBalance);
          StoreProvider.of<AppState>(context).dispatch(
              SetBonusBalanceAction(bonusBalance: [result['response']]));
          List newBonusBalance =
              StoreProvider.of<AppState>(context).state.bonusBalance;

          if (bonusActive.isNotEmpty) {
            var oldBonusObj = oldBonusBalance[0]['bonusBalances'].firstWhere(
                (element) =>
                    element['accountBonusCampaignId'] ==
                    bonusActive['accountBonusCampaignId'],
                orElse: () => {});
            var newBonusObj = newBonusBalance[0]['bonusBalances'].firstWhere(
                (element) =>
                    element['accountBonusCampaignId'] ==
                    bonusActive['accountBonusCampaignId'],
                orElse: () => {});
            oldBonusBalance = new List.from(
                StoreProvider.of<AppState>(context).state.bonusBalance);

            if (newBonusObj.isNotEmpty &&
                newBonusObj['type'] == 'First deposit') {
              bonusTextAlert = newBonusObj['unblockBypass'] &&
                      oldBonusObj['blocked'] &&
                      newBonusObj['blocked']
                  ? LocaleKeys.Betslip_Bonus_Accepted_Continue_ToUnblock.tr(args: [
                      newBonusObj['totalRolloverAmountToUnblock'].toString(),
                      newBonusObj['name']
                    ])
                  : !newBonusObj['unblockBypass'] &&
                          oldBonusObj['blocked'] &&
                          newBonusObj['blocked']
                      ? LocaleKeys.Betslip_Bonus_Accepted_Continue_Qualifying_ToUnblock.tr(
                          args: [
                              newBonusObj['totalRolloverAmountToUnblock']
                                  .toString(),
                              newBonusObj['name']
                            ])
                      : oldBonusObj['blocked'] && !newBonusObj['blocked']
                          ? LocaleKeys.Betslip_Bonus_Unlocked.tr(args: [
                              newBonusObj['name'],
                            ])
                          : !newBonusObj['blocked'] &&
                                  newBonusObj['rolloveredAmount'] >=
                                      newBonusObj['totalRolloverAmount']
                              ? LocaleKeys.Betslip_Bonus_Claim.tr()
                              : newBonusObj['totalRolloverAmount'] == 0
                                  ? LocaleKeys
                                          .Betslip_Bonus_Accepted_Principal_Balance
                                      .tr(args: [
                                      newBonusObj['name'],
                                    ])
                                  : newBonusObj['totalRolloverAmount'] != 0
                                      ? LocaleKeys.Betslip_Bonus_Accepted_RollOver.tr(
                                          args: [
                                              newBonusObj['name'],
                                              newBonusObj['totalRolloverAmount']
                                                  .toString()
                                            ])
                                      : "";
            }

            if (oldBonusObj.isNotEmpty && oldBonusObj['type'] == 'Regular') {
              bonusTextAlert = LocaleKeys.Betslip_Bonus_BetAccepted.tr(
                  args: [oldBonusObj['name']]);
            }

            if (oldBonusObj.isNotEmpty &&
                oldBonusObj['type'] == 'TournamentFreebet') {
              bonusTextAlert = LocaleKeys.Betslip_Bonus_FreeBettAccepted.tr(
                  args: [oldBonusObj['name']]);
            }
          }
          StoreProvider.of<AppState>(context)
              .dispatch(SetActiveBonusAction(activeBonus: {}));
        }
      });
    }
  }

  getSuperBonusAmount() {
    var minOddVal;

    Map getLimits = StoreProvider.of<AppState>(context).state.limits;
    try {
      minOddVal = getLimits['bonusfromodd'];
    } on Exception catch (_) {
      debugPrint('Error');
    }

    if (getLimits.isNotEmpty && minOddVal != null) {
      var bonusAmount;
      switch (widget.currentTab) {
        case 0:
          bonusAmount = 0;
          break;
        case 1:
          bonusAmount = getBonusAmount(prepareCmbTipsize(minOddVal), getLimits);
          break;
        case 2:
          int sysSize = systemRadioValue;
          int bankersArr = bankersArray.length;
          final onlyLetters = new RegExp(r"/\d+/g");
          var lettersArray = lettersArr
              .map((e) {
                if (onlyLetters.hasMatch(e)) return e;
              })
              .where((e) => e != null && e.length > 0 && int.parse(e[0]) == 1)
              .length;
          var resSize = sysSize + bankersArr + lettersArray;
          bonusAmount = getBonusAmount(resSize, getLimits);
          break;
      }
      return bonusAmount;
    } else {
      return 0;
    }
  }

  prepareCmbTipsize(minOddVal) {
    calculate(List arr) {
      if (arr.length < 2) return 0;
      List res = [];
      arr.forEach((e) {
        if (res.length == 0)
          res = e;
        else {
          List temp = [];
          e.forEach((el) {
            List temp1 = [];

            res.forEach((elem) {
              temp1.add(elem.toString() + "/" + el.toString());
            });

            temp = [...temp, ...temp1];
          });

          res = [...temp];
        }
      });

      if (res.length == 0) {
        return 0;
      }
      return res[0];
    }

    calculateCmbTotalOdds(List matchObj) {
      // console.log("matchObjList:", props.state);
      //apply new odd value. start
      List matchObjArr = matchObj.map((e) {
        return {
          'Value': e['Value'],
          'betMarketId': e['betMarketId'],
          'MatchId': e['MatchId'],
          'OddOd': e['OddId']
        };
      }).toList();
      //apply new odd value. end
      // generateTickets.start
      Map initialObj = {};
      List initialArray = [];

      matchObjArr.forEach((
        e,
      ) =>
          {
            initialObj[e['betMarketId'] + e['MatchId']] = matchObjArr
                .where((el) =>
                    el['betMarketId'] == e['betMarketId'] &&
                    e['MatchId'] == el['MatchId'])
                .map((e) => (e['Value']))
                .toList()
          });
      // console.log("matchObjList2:", Object.values(initialObj));

      initialObj.entries.forEach((e) => initialArray.add(e.value));

      return calculate(initialArray);
      // generateTickets.end
    }

    var data = [
      calculateCmbTotalOdds(StoreProvider.of<AppState>(context).state.matchObj)
    ];

    data = data
        .map((e) => e
            .toString()
            .split("/")
            .where((el) => double.parse(el) >= minOddVal.toDouble())
            .toList())
        .map((e) => e.length)
        .toList();
    var minLen;
    List.from(data).forEach(
        (e) => {if (minLen == null) minLen = e, if (e < minLen) minLen = e});

    return minLen;
  }

  Future<void> _showBonusAmountDialog(
      String bonusName, double stake, double amount) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(bonusName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    LocaleKeys.Betslip_Bonus_Placing_Bonus_Principal_Balance.tr(
                        args: [
                      amount.toStringAsFixed(2),
                      bonusName,
                      (stake - amount).toStringAsFixed(2)
                    ])),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.ok.tr()),
              onPressed: () {
                Navigator.of(context).pop();
                onSendRequest(
                    StoreProvider.of<AppState>(context).state.matchObj,
                    StoreProvider.of<AppState>(context).state.limits,
                    "place");
              },
            ),
            TextButton(
              child: Text(LocaleKeys.cancel.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _showAcceptedTickets(code, method) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) =>
            AcceptedCustomAlert(clearBetSlip, bonusTextAlert, code, method));
  }

  Future<void> _showUnacceptedTickets(errorText) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) =>
            UnacceptedCustomAlert(clearBetSlip, errorText));
  }

  Future<void> _showDialogClearBetslip() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.clearBetslip.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(LocaleKeys.ClearBetslip_Dialog.tr()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.no.tr()),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(LocaleKeys.yes.tr()),
              onPressed: () {
                clearBetSlip();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  requestLimits() async {
    Map limits = StoreProvider.of<AppState>(context).state.limits;
    List odds = getArrayOdds();
    var bonusMaxWin = StoreProvider.of<AppState>(context)
                .state
                .activeBonus
                .isNotEmpty &&
            StoreProvider.of<AppState>(context).state.activeBonus['maxWin'] !=
                null
        ? StoreProvider.of<AppState>(context)
            .state
            .activeBonus['maxWin']
            .toDouble()
        : 0.0;

    switch (widget.currentTab) {
      case 0:
        minStake = limits['single']['minStakeSingleBet'];
        maxStake = limits['single']['maxStakeSingleBet'];
        maxWin = limits['single']['maxWinSingleBet'];
        break;
      case 1:
        minStake = limits['multiple']['minStakeCombiBet'];
        maxStake = limits['multiple']['maxStakeCombi'];
        if (limits['multiple']['combiLimits'].firstWhere(
                (e) => e['tipSize'] == odds.length,
                orElse: () => null) !=
            null) {
          maxWin = bonusMaxWin > 0
              ? bonusMaxWin
              : limits['multiple']['combiLimits'].firstWhere(
                  (e) => e['tipSize'] == odds.length,
                  orElse: () => null)['limit'];
        } else {
          maxWin = bonusMaxWin > 0
              ? bonusMaxWin
              : limits['multiple']['combiLimits'].last['limit'];
        }
        minCombination = limits['multiple']['minCombination'];
        maxCombination = limits['multiple']['maxCombination'];
        break;
      case 2:
        final onlyLetters = new RegExp(r"\d+");
        List lettersArr = generateLetterArray(odds, null);
        List onlyLettersArr = lettersArr
            .where((element) => !onlyLetters.hasMatch(element))
            .toList();

        if (onlyLettersArr.length > 2 && odds.length > 2) {
          minStake = limits['system']['minStakeSystemBet'] *
              getSystemBetsCount(systemRadioValue,
                  onlyLettersArr.length - bankersArray.length);
          maxStake = limits['system']['maxStakeSystemBet'];
          maxWin = bonusMaxWin > 0
              ? bonusMaxWin
              : limits['system']['maxWinSystemBet'];
          maxOdd = bonusMaxWin > 0 ? bonusMaxWin : limits['system']['maxOdd'];
          maxSystemBet = limits['system']['maxSystemBet'];
        }
        break;
    }
  }

  Widget _getBody() {
    return Stack(children: <Widget>[
      Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        right: 0,
        child: Container(
          height: 50,
          child: Row(
            children: [
              for (var item in config.stakeButtons)
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.all(2.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[700]),
                          child:
                              Text(item, style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if (item != "MAX") {
                              stakeController.text = stakeController.text != ""
                                  ? (double.parse(stakeController.text) +
                                          double.parse(item))
                                      .toStringAsFixed(0)
                                  : item;
                              setState(() {
                                totalStake = stakeController.text != ""
                                    ? double.parse(stakeController.text)
                                    : double.parse(item);
                              });
                            } else {
                              stakeController.text =
                                  maxStake.toStringAsFixed(0);
                              setState(() {
                                totalStake = maxStake;
                              });
                            }
                          },
                        )))
            ],
          ),
          decoration: BoxDecoration(color: Colors.black),
        ),
      ),
    ]);
  }

  checkSplitTicket(odd) {
    List odds = getArrayOdds();
    int count = 0;
    count = odds
        .where((e) =>
            e['match'] == odd['match'] &&
            e['betDomainId'] == odd['betDomainId'])
        .length;
    return count > 1 ? true : false;
  }

  Widget _buildItem(int index, animation, bool removing) {
    var state = StoreProvider.of<AppState>(context).state;
    return SizeTransition(
        sizeFactor: animation,
        child: removing
            ? Container(height: 150, color: Theme.of(context).cardColor)
            : Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Stack(children: <Widget>[
                  Positioned(
                      right: 0.0,
                      top: 10.0,
                      child: GestureDetector(
                        onTap: !sendRequest
                            ? () {
                                clearMatch(getArrayOdds()[index]['match'],
                                    getArrayOdds()[index]['oddId']);
                              }
                            : null,
                        child: Align(
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 20.0,
                            )),
                      )),
                  getArrayOdds().length > 0
                      ? BetslipListitem(
                          key: Key("${getArrayOdds()[index]['betDomainId']}"),
                          odds: getArrayOdds()[index],
                          split: checkSplitTicket(getArrayOdds()[index]),
                          betDomainData: state.oddsBetDomainInfo.firstWhere(
                              (element) =>
                                  element['betDomainId'] ==
                                  getArrayOdds()[index]['betDomainId'],
                              orElse: () => null),
                          matchObj: state.matchObj,
                          addvariousStakeValue: (stake) {
                            addvariousStakeValue(stake);
                          },
                          clearMatch: (matchId, oddId) {
                            clearMatch(matchId, oddId);
                          },
                          maxWin: maxWin,
                          currentTab: widget.currentTab,
                          lettersArr: lettersArr,
                          bankersArray: bankersArray,
                          bankerChanged: (val) {
                            bankerChanged(val);
                          },
                          toggleTrigger: (val) {
                            toggleTrigger(val);
                          },
                          systemRadioValue: systemRadioValue,
                          sendRequest: sendRequest,
                          placedBets:
                              placedBets[getArrayOdds()[index]['oddId']],
                          clearPlacedBet: (oddId) {
                            clearPlacedBet(oddId);
                          },
                          onSendRequest: (matchObj, limits, method) {
                            onSendRequest(matchObj, limits, method);
                          },
                          activeBonus: state.activeBonus)
                      : SizedBox()
                ])));
  }

  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (viewModel.odds.length != oldViewModel!.odds.length) {
            trigger = true;
            if (widget.currentTab != 2) {
              requestLimits();
            }
          }
          if (oldViewModel.limits.isEmpty && viewModel.limits.isNotEmpty) {
            if (widget.currentTab != 2) {
              requestLimits();
            }
          }
          if (oldViewModel.activeBonus != viewModel.activeBonus) {
            requestLimits();
          }
        },
        builder: (context, state) {
          bonusAmount = getSuperBonusAmount();

          if (widget.currentTab == 1 && trigger == true) {
            final onlyLetters = new RegExp(r"\d+");
            lettersArr = generateLetterArray(getArrayOdds(), null);
            onlyLettersArr = lettersArr
                .where((element) => !onlyLetters.hasMatch(element))
                .toList();
            uniqeLettersLength = lettersArr
                .map((e) => e.substring(0, 1))
                .toList()
                .toSet()
                .toList()
                .length;

            trigger = false;
          }

          if (state.activeBonus.isNotEmpty &&
              state.activeBonus['type'] == 'TournamentFreebet') {
            totalStake = state.activeBonus['availableAmount'] > 0
                ? state.activeBonus['availableAmount']
                : 0;
            stakeController.text =
                state.activeBonus['availableAmount'].toStringAsFixed(2);
          }

          if (widget.currentTab == 2 &&
              trigger == true &&
              state.matchObj.length > 0) {
            final onlyLetters = new RegExp(r"\d+");

            lettersArr = generateLetterArray(getArrayOdds(), null);

            uniqeLettersLength = lettersArr
                .map((e) => e.substring(0, 1))
                .toList()
                .toSet()
                .toList()
                .length;

            onlyLettersArr = lettersArr
                .where((element) => !onlyLetters.hasMatch(element))
                .toList();

            List helpArray = state.matchObj
                .map((e) => state.matchObj
                            .where((val) => val['MatchId'] == e['MatchId'])
                            .toList()
                            .length >
                        1
                    ? 0
                    : 1)
                .toList();

            matchObjArr = [];

            state.matchObj
                .asMap()
                .entries
                .map((entry) => {
                      if (helpArray[entry.key] == 1)
                        {matchObjArr.add(entry.value)}
                    })
                .toList();

            List allOddsArray = state.matchObj.map((e) {
              return e['Value'];
            }).toList();

            systemCombos = systemCombinations(
                onlyLettersArr, systemRadioValue, bankersArray, matchObjArr);

            coefsCalcArr = [];

            systemCombos.forEach(
                (val) => coefsCalcArr.add(coefsCalc(val, allOddsArray)));

            trigger = false;
          }

          String bonusName = "";

          if (state.bonusBalance.length > 0 &&
              state.bonusBalance[0]['bonusBalances'].length > 0 &&
              state.activeBonus.isNotEmpty &&
              state.authorization) {
            bonusName = state.activeBonus['name'];
          }

          String multipleTotal = widget.currentTab == 1 &&
                  uniqeLettersLength > 1 &&
                  getArrayOdds().length > 1
              ? calcCmbTotalOdds(state.matchObj).toStringAsFixed(2)
              : widget.currentTab == 2 &&
                      onlyLettersArr.length > 2 &&
                      getArrayOdds().length > 2
                  ? (totalSystemCoef(coefsCalcArr, lettersArr, state.matchObj))
                      .toStringAsFixed(2)
                  : "0.00";

          if (widget.currentTab > 0) {
            calculateBonus = (totalStake * double.parse(multipleTotal)) > maxWin
                ? ((maxWin / 100) * bonusAmount)
                : (((totalStake * double.parse(multipleTotal)) / 100) *
                    bonusAmount);
          }

          String possibleWin = config.stakeTaxEnabled
              ? (((minusVAT(totalStake, config.stakeTaxPercent))) *
                          double.parse(multipleTotal)) >
                      maxWin
                  ? (maxWin + calculateBonus).toStringAsFixed(2)
                  : (((minusVAT(totalStake, config.stakeTaxPercent))) *
                              double.parse(multipleTotal) +
                          calculateBonus)
                      .toStringAsFixed(2)
              : (totalStake * double.parse(multipleTotal)) > maxWin
                  ? (maxWin + calculateBonus).toStringAsFixed(2)
                  : (totalStake * double.parse(multipleTotal) + calculateBonus)
                      .toStringAsFixed(2);

          checkCashOut() {
            int countCashout = 0;
            int tickets = getArrayOdds().length;

            if (lettersArr.length > 0) {
              countCashout = state.matchObj
                  .where((e) => e['betdomainNumberCanBeCashout'] == true)
                  .length;

              if (countCashout == tickets && state.activeBonus.isEmpty) {
                return true;
              }
            }
          }

          Widget buildDragHandle() => GestureDetector(
              child: Center(
                  child: Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12)))),
              onTap: null);

          checkBonusConditions() {
            if (widget.currentTab != 1) {
              return false;
            }

            if (state.activeBonus['minTipps'] != null &&
                getArrayOdds().length < state.activeBonus['minTipps']) {
              return false;
            }

            if (state.activeBonus['minOdds'] != null &&
                state.matchObj.firstWhere(
                        (element) =>
                            element['Value'] < state.activeBonus['minOdds'],
                        orElse: () => null) !=
                    null) {
              return false;
            }

            if (state.activeBonus['minTotalOdds'] != null &&
                double.parse(multipleTotal) <
                    state.activeBonus['minTotalOdds']) {
              return false;
            }

            if (state.activeBonus['minStake'] != null &&
                !state.activeBonus['mustOnce'] &&
                totalStake < state.activeBonus['minStake']) {
              return false;
            }

            return true;
          }

          EdgeInsetsGeometry _padding = EdgeInsets.zero;

          if (state.activeBonus.isNotEmpty &&
              state.activeBonus['minOdds'] != null &&
              !sliderOpened) {
            _padding = EdgeInsets.only(bottom: sliderClosedHeight);
          } else if (state.activeBonus.isNotEmpty &&
              state.activeBonus['minOdds'] != null &&
              sliderOpened) {
            _padding = EdgeInsets.only(bottom: sliderOpenedHeight);
          } else {
            _padding = EdgeInsets.only(bottom: 0);
          }

          return Scaffold(
              backgroundColor: Theme.of(context).cardColor,
              body:
                  getArrayOdds().length > 0 &&
                          state.oddsBetDomainInfo.length > 0
                      ? Stack(children: <Widget>[
                          AnimatedPadding(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: _padding,
                              child: ListView(
                                children: [
                                  ClipPath(
                                      clipper: MyClipper(),
                                      child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 10.0,
                                              right: 10.0,
                                              top: 15.0),
                                          decoration: BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.white),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              topRight: Radius.circular(5),
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20.0),
                                            child: AnimatedList(
                                                key: _listKey,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                initialItemCount:
                                                    getArrayOdds().length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index,
                                                    animation) {
                                                  return _buildItem(
                                                      index, animation, false);
                                                }),
                                          ))),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: 10.0,
                                          right: 10.0,
                                          bottom: 15.0),
                                      decoration: BoxDecoration(
                                        border:
                                            new Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular(5.0),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.currentTab == 2 &&
                                                  getArrayOdds().length > 2 &&
                                                  onlyLettersArr.length > 2
                                              ? SystemList(
                                                  matchObj: state.matchObj,
                                                  systemRadioValue:
                                                      systemRadioValue,
                                                  lettersArr: lettersArr,
                                                  bankersArrayLength:
                                                      bankersArray.length,
                                                  systemCombos: systemCombos,
                                                  coefsCalcArr: coefsCalcArr,
                                                  toggleTrigger: (val) {
                                                    toggleTrigger(val);
                                                  },
                                                  radioValueChanged: (value) {
                                                    radioValueChanged(value);
                                                  })
                                              : SizedBox(),
                                          ((widget.currentTab == 1 &&
                                                      uniqeLettersLength > 1 &&
                                                      getArrayOdds().length >
                                                          1) ||
                                                  (widget.currentTab == 2 &&
                                                      onlyLettersArr.length >
                                                          2 &&
                                                      getArrayOdds().length >
                                                          2))
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  alignment: Alignment.center,
                                                  decoration: new BoxDecoration(
                                                      color: Theme.of(context)
                                                          .indicatorColor),
                                                  child: Text(
                                                      "${LocaleKeys.totalOdds.tr()}: $multipleTotal",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .surface),
                                                      textAlign:
                                                          TextAlign.center))
                                              : SizedBox(height: 0, width: 0),
                                          widget.currentTab == 1 &&
                                                  uniqeLettersLength ==
                                                      getArrayOdds().length &&
                                                  checkCashOut() == true
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  alignment: Alignment.center,
                                                  decoration: new BoxDecoration(
                                                      color: Colors.blue),
                                                  child: Text(
                                                      LocaleKeys.ticketCashout
                                                          .tr(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                      textAlign:
                                                          TextAlign.center))
                                              : SizedBox(height: 0, width: 0),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: !state.authorization
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    alignment: Alignment.center,
                                                    margin: EdgeInsets.all(20),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 5,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: InkWell(
                                                      child: Text(
                                                        LocaleKeys.pleaseLogin
                                                            .tr(),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15),
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LoginPage()),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(),
                                              child: widget.currentTab > 0
                                                  ? Column(children: [
                                                      bonusAmount > 0 &&
                                                              state.activeBonus
                                                                  .isEmpty
                                                          ? Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                  RichText(
                                                                    text:
                                                                        new TextSpan(
                                                                      // Note: Styles for TextSpans must be explicitly defined.
                                                                      // Child text spans will inherit styles from parent
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            16.0,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      children: <
                                                                          TextSpan>[
                                                                        new TextSpan(
                                                                            text:
                                                                                '${LocaleKeys.bonus.tr()}($bonusAmount%): '),
                                                                        new TextSpan(
                                                                            text:
                                                                                calculateBonus.toStringAsFixed(2),
                                                                            style: new TextStyle(fontWeight: FontWeight.bold)),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ])
                                                          : SizedBox(),
                                                      ((widget.currentTab ==
                                                                      1 &&
                                                                  uniqeLettersLength >
                                                                      1 &&
                                                                  getArrayOdds()
                                                                          .length >
                                                                      1) ||
                                                              (widget.currentTab == 2 &&
                                                                  uniqeLettersLength >
                                                                      2 &&
                                                                  getArrayOdds()
                                                                          .length >
                                                                      2))
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          15.0),
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    RichText(
                                                                      text:
                                                                          new TextSpan(
                                                                        // Note: Styles for TextSpans must be explicitly defined.
                                                                        // Child text spans will inherit styles from parent
                                                                        style:
                                                                            new TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        children: <
                                                                            TextSpan>[
                                                                          new TextSpan(
                                                                              text: '${LocaleKeys.possibleWin.tr()}: '),
                                                                          new TextSpan(
                                                                              text: '$possibleWin',
                                                                              style: new TextStyle(fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                        width:
                                                                            100.0,
                                                                        height:
                                                                            35.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.grey.withOpacity(0.5),
                                                                              spreadRadius: 3,
                                                                              blurRadius: 7,
                                                                              offset: Offset(0, 5),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              stakeController,
                                                                          enabled: state.activeBonus['type'] == 'TournamentFreebet'
                                                                              ? false
                                                                              : true,
                                                                          style:
                                                                              TextStyle(color: Colors.black),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              this.totalStake = value.length > 0 ? double.parse(value) : 0;
                                                                            });
                                                                          },
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                          ],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                Colors.white,
                                                                            contentPadding:
                                                                                EdgeInsets.all(10.0),
                                                                            alignLabelWithHint:
                                                                                true,
                                                                            border:
                                                                                OutlineInputBorder(),
                                                                            hintText:
                                                                                LocaleKeys.stake.tr(),
                                                                          ),
                                                                        ))
                                                                  ]))
                                                          : SizedBox(),
                                                      config.stakeTaxEnabled &&
                                                              widget.currentTab >
                                                                  0 &&
                                                              state.activeBonus
                                                                  .isEmpty
                                                          ? Column(children: [
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    RichText(
                                                                      text:
                                                                          new TextSpan(
                                                                        // Note: Styles for TextSpans must be explicitly defined.
                                                                        // Child text spans will inherit styles from parent
                                                                        style:
                                                                            new TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        children: [
                                                                          new TextSpan(
                                                                              text: '${config.stakeTaxName}(-${config.stakeTaxPercent}%): '),
                                                                          new TextSpan(
                                                                              text: '${(totalStake - minusVAT(totalStake, config.stakeTaxPercent)).toStringAsFixed(2)}',
                                                                              style: new TextStyle(fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ]),
                                                              SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    RichText(
                                                                      text:
                                                                          new TextSpan(
                                                                        // Note: Styles for TextSpans must be explicitly defined.
                                                                        // Child text spans will inherit styles from parent
                                                                        style:
                                                                            new TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        children: <
                                                                            TextSpan>[
                                                                          new TextSpan(
                                                                              text: 'Stake after ${config.stakeTaxName}: '),
                                                                          new TextSpan(
                                                                              text: '${(minusVAT(totalStake, config.stakeTaxPercent))}',
                                                                              style: new TextStyle(fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ]),
                                                              SizedBox(
                                                                  height: 10)
                                                            ])
                                                          : SizedBox(),
                                                      config.profitTaxEnabled &&
                                                              widget.currentTab >
                                                                  0 &&
                                                              state.activeBonus
                                                                  .isEmpty &&
                                                              double.parse(
                                                                      possibleWin) >=
                                                                  config
                                                                      .profitTaxMinIncome
                                                          ? Column(children: [
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    RichText(
                                                                      text:
                                                                          new TextSpan(
                                                                        // Note: Styles for TextSpans must be explicitly defined.
                                                                        // Child text spans will inherit styles from parent
                                                                        style:
                                                                            new TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        children: [
                                                                          new TextSpan(
                                                                              text: '${config.profitTaxName}(-${config.profitTaxPercent}%): '),
                                                                          new TextSpan(
                                                                              text: '${(minusProfitTax(double.parse(possibleWin), config.profitTaxPercent, config.stakeTaxEnabled ? minusVAT(totalStake, config.stakeTaxPercent) : totalStake)).toStringAsFixed(2)}',
                                                                              style: new TextStyle(fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ]),
                                                              SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    RichText(
                                                                      text:
                                                                          new TextSpan(
                                                                        // Note: Styles for TextSpans must be explicitly defined.
                                                                        // Child text spans will inherit styles from parent
                                                                        style:
                                                                            new TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        children: <
                                                                            TextSpan>[
                                                                          new TextSpan(
                                                                              text: 'Net payout: '),
                                                                          new TextSpan(
                                                                              text: '${(double.parse(possibleWin) - (minusProfitTax(double.parse(possibleWin), config.profitTaxPercent, config.stakeTaxEnabled ? minusVAT(totalStake, config.stakeTaxPercent) : totalStake))).toStringAsFixed(2)}',
                                                                              style: new TextStyle(fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ]),
                                                              SizedBox(
                                                                  height: 10)
                                                            ])
                                                          : SizedBox(),
                                                      ((widget.currentTab ==
                                                                      1 &&
                                                                  uniqeLettersLength >
                                                                      1 &&
                                                                  getArrayOdds()
                                                                          .length >
                                                                      1) ||
                                                              (widget.currentTab == 2 &&
                                                                  onlyLettersArr
                                                                          .length >
                                                                      2 &&
                                                                  getArrayOdds()
                                                                          .length >
                                                                      2))
                                                          ? TextButton(
                                                              onPressed: state
                                                                          .authorization &&
                                                                      !sendRequest &&
                                                                      (state.activeBonus.isNotEmpty &&
                                                                              checkBonusConditions() ||
                                                                          state
                                                                              .activeBonus
                                                                              .isEmpty)
                                                                  ? () {
                                                                      state.activeBonus.isNotEmpty &&
                                                                              state.activeBonus['type'] ==
                                                                                  'Regular' &&
                                                                              state.activeBonus['availableAmount'] <
                                                                                  totalStake
                                                                          ? _showBonusAmountDialog(
                                                                              state.activeBonus[
                                                                                  'name'],
                                                                              totalStake,
                                                                              state.activeBonus[
                                                                                  'availableAmount'])
                                                                          : onSendRequest(
                                                                              state.matchObj,
                                                                              state.limits,
                                                                              "place");
                                                                    }
                                                                  : null,
                                                              style: TextButton.styleFrom(
                                                                  padding: EdgeInsets.only(
                                                                      top: 15.0,
                                                                      bottom:
                                                                          15.0,
                                                                      right: 40,
                                                                      left: 40),
                                                                  backgroundColor: state
                                                                              .authorization &&
                                                                          !sendRequest &&
                                                                          (state.activeBonus.isNotEmpty && checkBonusConditions() ||
                                                                              state
                                                                                  .activeBonus.isEmpty)
                                                                      ? Theme.of(
                                                                              context)
                                                                          .indicatorColor
                                                                      : Color(0xFF808080)
                                                                          .withOpacity(
                                                                              0.70)),
                                                              child: state.activeBonus
                                                                          .isNotEmpty &&
                                                                      !(!state.activeBonus[
                                                                              'blocked'] &&
                                                                          widget.currentTab ==
                                                                              0) &&
                                                                      state
                                                                          .authorization
                                                                  ? Column(
                                                                      children: [
                                                                          Text(
                                                                              LocaleKeys.placeWith.tr(),
                                                                              style: TextStyle(color: Colors.grey[600])),
                                                                          Text(
                                                                              bonusName,
                                                                              style: TextStyle(color: state.authorization ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface.withOpacity(0.40), fontSize: 20))
                                                                        ])
                                                                  : Text(
                                                                      LocaleKeys
                                                                          .placeBet
                                                                          .tr(),
                                                                      style: TextStyle(
                                                                          color: state.authorization
                                                                              ? Theme.of(context).colorScheme.surface
                                                                              : Theme.of(context).colorScheme.surface.withOpacity(0.40),
                                                                          fontSize: 20),
                                                                    ),
                                                            )
                                                          : SizedBox(),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            TextButton.icon(
                                                                onPressed: () {
                                                                  _showDialogClearBetslip();
                                                                },
                                                                icon: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 20.0,
                                                                ),
                                                                label: Text(
                                                                    LocaleKeys
                                                                        .clearBetslip
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.6)))),
                                                            TextButton.icon(
                                                                onPressed: () {
                                                                  onSendRequest(
                                                                      state
                                                                          .matchObj,
                                                                      state
                                                                          .limits,
                                                                      "save");
                                                                },
                                                                icon: Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 20.0,
                                                                ),
                                                                label: Text(
                                                                    LocaleKeys
                                                                        .save
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.6)))),
                                                          ])
                                                    ])
                                                  : Column(children: [
                                                      TextButton(
                                                        style: TextButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 15.0,
                                                                    bottom:
                                                                        15.0,
                                                                    right: 40,
                                                                    left: 40),
                                                            backgroundColor: state
                                                                        .authorization &&
                                                                    !sendRequest &&
                                                                    (state.activeBonus.isNotEmpty &&
                                                                            checkBonusConditions() ||
                                                                        state.activeBonus
                                                                            .isEmpty)
                                                                ? Theme.of(
                                                                        context)
                                                                    .indicatorColor
                                                                : Color(0xFF808080)
                                                                    .withOpacity(
                                                                        0.70)),
                                                        onPressed: state
                                                                    .authorization &&
                                                                !sendRequest &&
                                                                (state.activeBonus
                                                                            .isNotEmpty &&
                                                                        checkBonusConditions() ||
                                                                    state
                                                                        .activeBonus
                                                                        .isEmpty)
                                                            ? () {
                                                                state.activeBonus
                                                                            .isNotEmpty &&
                                                                        state.activeBonus['type'] ==
                                                                            'Regular' &&
                                                                        state.activeBonus['availableAmount'] <
                                                                            totalStake
                                                                    ? _showBonusAmountDialog(
                                                                        state.activeBonus[
                                                                            'name'],
                                                                        totalStake,
                                                                        state.activeBonus[
                                                                            'availableAmount'])
                                                                    : onSendRequest(
                                                                        state
                                                                            .matchObj,
                                                                        state
                                                                            .limits,
                                                                        "place");
                                                              }
                                                            : null,
                                                        child: state.activeBonus
                                                                    .isNotEmpty &&
                                                                !(!state.activeBonus[
                                                                        'blocked'] &&
                                                                    widget.currentTab ==
                                                                        0) &&
                                                                state
                                                                    .authorization
                                                            ? Column(children: [
                                                                Text(
                                                                    LocaleKeys
                                                                        .placeWith
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey[600])),
                                                                Text(bonusName,
                                                                    style: TextStyle(
                                                                        color: state.authorization
                                                                            ? Theme.of(context)
                                                                                .colorScheme
                                                                                .surface
                                                                            : Theme.of(context).colorScheme.surface.withOpacity(
                                                                                0.40),
                                                                        fontSize:
                                                                            20))
                                                              ])
                                                            : Text(
                                                                LocaleKeys
                                                                    .placeBet
                                                                    .tr(),
                                                                style: TextStyle(
                                                                    color: state
                                                                            .authorization
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .surface
                                                                        : Theme.of(context)
                                                                            .colorScheme
                                                                            .surface
                                                                            .withOpacity(
                                                                                0.40),
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                      ),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            TextButton.icon(
                                                                onPressed: () {
                                                                  _showDialogClearBetslip();
                                                                },
                                                                icon: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 20.0,
                                                                ),
                                                                label: Text(
                                                                    LocaleKeys
                                                                        .clearBetslip
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.6)))),
                                                            TextButton.icon(
                                                                onPressed: () {
                                                                  onSendRequest(
                                                                      state
                                                                          .matchObj,
                                                                      state
                                                                          .limits,
                                                                      "save");
                                                                },
                                                                icon: Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 20.0,
                                                                ),
                                                                label: Text(
                                                                    LocaleKeys
                                                                        .save
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.6)))),
                                                          ]),
                                                    ]),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              )),
                          keyBoardVisible && widget.currentTab > 0
                              ? _getBody()
                              : SizedBox(),
                          state.activeBonus.isNotEmpty &&
                                  state.activeBonus['minOdds'] != null
                              ? SlidingUpPanel(
                                  minHeight: 60,
                                  maxHeight: 230,
                                  onPanelOpened: () => setState(() {
                                    sliderOpened = true;
                                  }),
                                  onPanelClosed: () => setState(() {
                                    sliderOpened = false;
                                  }),
                                  parallaxEnabled: true,
                                  parallaxOffset: .5,
                                  panel: DefaultTextStyle(
                                      style: TextStyle(color: Colors.black),
                                      child: Padding(
                                          padding: new EdgeInsets.all(10.0),
                                          child: Column(children: [
                                            buildDragHandle(),
                                            SizedBox(height: 10),
                                            Center(
                                                child: RichText(
                                              text: TextSpan(
                                                children: <InlineSpan>[
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Text(
                                                      "${LocaleKeys.bonusConditions.tr()} ",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 23),
                                                    ),
                                                  ),
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Icon(
                                                        checkBonusConditions()
                                                            ? Icons
                                                                .check_circle_outline
                                                            : Icons
                                                                .highlight_off,
                                                        color:
                                                            checkBonusConditions()
                                                                ? Colors.green
                                                                : Colors.red,
                                                        size: 30),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            SizedBox(height: 10),
                                            state.activeBonus['ticketTypes'] !=
                                                    null
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                        Flexible(
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10.0),
                                                                child: Text(
                                                                    "${state.activeBonus['name']} ${LocaleKeys.Bonus_Should_Be.tr()}:"))),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: <
                                                                InlineSpan>[
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Text(
                                                                  "${LocaleKeys.multiple.tr()} ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Icon(
                                                                    widget.currentTab ==
                                                                            1
                                                                        ? Icons
                                                                            .check_circle_outline
                                                                        : Icons
                                                                            .highlight_off,
                                                                    color: widget.currentTab ==
                                                                            1
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                    size: 30),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ])
                                                : SizedBox(),
                                            state.activeBonus['minTipps'] !=
                                                    null
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                        Text(LocaleKeys
                                                            .selections
                                                            .tr()),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: <
                                                                InlineSpan>[
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Text(
                                                                  "${LocaleKeys.over.tr()} ${state.activeBonus['minTipps']}",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Icon(
                                                                    getArrayOdds().length <
                                                                            state.activeBonus[
                                                                                'minTipps']
                                                                        ? Icons
                                                                            .highlight_off
                                                                        : Icons
                                                                            .check_circle_outline,
                                                                    color: getArrayOdds().length <
                                                                            state.activeBonus[
                                                                                'minTipps']
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .green,
                                                                    size: 30),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ])
                                                : SizedBox(),
                                            !state.activeBonus['mustOnce'] &&
                                                    state.activeBonus[
                                                            'minStake'] !=
                                                        null
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                        Text(LocaleKeys.minStake
                                                            .tr()),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: <
                                                                InlineSpan>[
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Text(
                                                                  "${LocaleKeys.over.tr()} ${state.activeBonus['minStake']}",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Icon(
                                                                    totalStake <
                                                                            state.activeBonus[
                                                                                'minStake']
                                                                        ? Icons
                                                                            .highlight_off
                                                                        : Icons
                                                                            .check_circle_outline,
                                                                    color: totalStake <=
                                                                            state.activeBonus[
                                                                                'minTipps']
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .green,
                                                                    size: 30),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ])
                                                : SizedBox(),
                                            state.activeBonus['minOdds'] !=
                                                        null &&
                                                    state.activeBonus[
                                                            'minOdds'] >
                                                        1
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                        Text(
                                                            "${LocaleKeys.either_selection_odds.tr()}:"),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: <
                                                                InlineSpan>[
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Text(
                                                                  "${LocaleKeys.over.tr()} ${state.activeBonus['minOdds']}",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                  alignment:
                                                                      PlaceholderAlignment
                                                                          .middle,
                                                                  child: Icon(
                                                                      state.matchObj.firstWhere((element) => element['Value'] < state.activeBonus['minOdds'], orElse: () => null) ==
                                                                              null
                                                                          ? Icons
                                                                              .check_circle_outline
                                                                          : Icons
                                                                              .highlight_off,
                                                                      color: state.matchObj.firstWhere((element) => element['Value'] < state.activeBonus['minOdds'], orElse: () => null) ==
                                                                              null
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                                      size:
                                                                          30)),
                                                            ],
                                                          ),
                                                        )
                                                      ])
                                                : SizedBox(),
                                            state.activeBonus['minTotalOdds'] !=
                                                        null &&
                                                    state.activeBonus[
                                                            'minTotalOdds'] >
                                                        1
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                        Text(
                                                            "${LocaleKeys.totalOdds.tr().toLowerCase()}:"),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: <
                                                                InlineSpan>[
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Text(
                                                                  "${LocaleKeys.over.tr()} ${state.activeBonus['minTotalOdds']}",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Icon(
                                                                    double.parse(multipleTotal) >=
                                                                            state.activeBonus[
                                                                                'minTotalOdds']
                                                                        ? Icons
                                                                            .check_circle_outline
                                                                        : Icons
                                                                            .highlight_off,
                                                                    color: double.parse(multipleTotal) >=
                                                                            state.activeBonus[
                                                                                'minTotalOdds']
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                    size: 30),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ])
                                                : SizedBox(),
                                          ]))),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18.0),
                                      topRight: Radius.circular(18.0)),
                                )
                              : SizedBox(),
                        ])
                      : Center(child: Text(LocaleKeys.empty.tr())));
        });
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.addOval(
        Rect.fromCircle(center: Offset(0.0, size.height - 20), radius: 20.0));
    path.addOval(Rect.fromCircle(
        center: Offset(size.width, size.height - 20), radius: 20.0));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AcceptedCustomAlert extends StatelessWidget {
  AcceptedCustomAlert(
      this.clearBetSlip, this.bonusText, this.code, this.method);
  final clearBetSlip;
  final bonusText;
  final code;
  final method;

  @override
  Widget build(BuildContext context) {
    void handleCouponCode(code) async {
      final StorageService _storageService = StorageService();
      String? accessToken = await _storageService.readSecureData('token');

      if (accessToken!.length > 0) {
        final getParams = {'lang': context.locale.toString()};

        var url = Uri(
          scheme: config.protocol,
          host: config.hostname,
          path: 'betting-api-gateway/user/rest/ticket/getByCode/$code',
          queryParameters: getParams,
        );

        await http.get(url, headers: {
          "content-type": "application/json",
          "Authorization": accessToken
        }).then((response) {
          if (response.statusCode == 200) {
            var result = jsonDecode(response.body);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyBetsModal(
                        ticket: result['response'],
                        code: code,
                      )),
            );
          } else {}
        });
      }
    }

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: new Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                  child: Column(
                    children: [
                      Text(
                        method == "place"
                            ? LocaleKeys.betAccepted.tr()
                            : LocaleKeys.bookingAccepted.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        method == "place"
                            ? LocaleKeys.checkStatusMyBets.tr()
                            : LocaleKeys.bookingCodeValidation.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent),
                              child: Text(code,
                                  style: TextStyle(
                                      color: Colors.yellow[900], fontSize: 20)),
                              onPressed: method == "place"
                                  ? () {
                                      handleCouponCode(code);
                                    }
                                  : null,
                            ),
                            IconButton(
                                icon: new Icon(Icons.share,
                                    color: Colors.yellow[900]),
                                onPressed: () => {
                                      Share.share(
                                          '${config.protocol}://${config.linkShareDomainUrl}/sport?${method == "place" ? 'coupon_code' : 'booking_code'}=$code')
                                    }),
                          ]),
                      bonusText.length > 0
                          ? Text(
                              bonusText,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          clearBetSlip();
                          Navigator.of(context).pop();
                        },
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.green),
                        child: Text(
                          LocaleKeys.ok.tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ]),
            Positioned(
                top: -45,
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 45,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                )),
          ],
        ));
  }
}

class UnacceptedCustomAlert extends StatelessWidget {
  UnacceptedCustomAlert(this.clearBetSlip, this.errorText);
  final clearBetSlip;
  final errorText;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            ListView(shrinkWrap: true, children: [
              Container(
                decoration: BoxDecoration(
                  border: new Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                  child: Column(
                    children: [
                      Text(
                        LocaleKeys.betUnAccepted.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        errorText,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: Text(LocaleKeys.remove.tr(),
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                clearBetSlip();
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: Text(LocaleKeys.save.tr(),
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ]),
                    ],
                  ),
                ),
              )
            ]),
            Positioned(
                top: -45,
                child: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  radius: 45,
                  child: Icon(
                    Icons.priority_high,
                    color: Colors.white,
                    size: 50,
                  ),
                )),
          ],
        ));
  }
}
