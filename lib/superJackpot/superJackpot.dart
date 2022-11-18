import 'dart:math';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import 'package:flutter_betting_app/betslip/BSLogic.dart';
import 'package:flutter_betting_app/generated/locale_keys.g.dart';
import 'package:flutter_betting_app/superJackpot/matchData.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:convert';
import '../config/defaultConfig.dart' as config;
import 'package:http/http.dart' as http;
import '../../services/storage_service.dart';
import 'results/superJackpotResults.dart';

class SuperJackpot extends StatefulWidget {
  const SuperJackpot({Key? key}) : super(key: key);

  @override
  SuperJackpotState createState() => SuperJackpotState();
}

class SuperJackpotState extends State<SuperJackpot> {
  List jackpotList = [];
  bool jackpotListFetched = false;
  int activeJackpotId = -1;
  Map jackpotData = {};
  List odds = [];
  List matchObjList = [];
  var formatter = NumberFormat("#,##0.00", "en_US");
  bool placeButtonLock = false;

  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getJackpotList());
  }

  Future<void> _showDialog(error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(error == null ? 'Bet Accepted' : 'Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(error != null
                    ? error
                    : "Your ${jackpotData['name'].toUpperCase()} bet is accepted"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.ok.tr()),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  countSplit() {
    double count = 0;
    odds.forEach((e) => {
          if (odds
                  .where((val) => e['matchId'] == val['matchId'])
                  .toList()
                  .length >
              1)
            {count = count + 1}
        });
    return count / 2;
  }

  doubleStake(stake, repeat) {
    var result = stake;
    for (var i = 0; i < repeat; i++) {
      result = result * 2;
    }
    return result;
  }

  getJackpotList() async {
    final getParams = {'lang': context.locale.toString()};
    setState(() {
      jackpotListFetched = false;
    });
    var url = Uri(
      scheme: config.protocol,
      host: config.hostname,
      path: 'betting-api-gateway/user/rest/jackpot/get-superjackpots',
      queryParameters: getParams,
    );

    await http.get(url, headers: {"content-type": "application/json"}).then(
        (response) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['response'] != null) {
          result['response']
              .sort((a, b) => a["sort"].compareTo(b["sort"]) as int);
          setState(() {
            jackpotList = result['response'];
          });
          if (activeJackpotId == -1) {
            int jackpotId = activeJackpotId = jackpotList.firstWhere(
                (val) => val['state'] == 1,
                orElse: () => {'id': -1})['id'];
            if (jackpotId != -1) {
              setState(() {
                activeJackpotId = jackpotId;
              });
              getJackpotData(jackpotId);
            }
          }
        }
      } else {
        debugPrint('error');
      }
      setState(() {
        jackpotListFetched = true;
      });
    });
  }

  getJackpotData(id) async {
    setState(() {
      jackpotListFetched = false;
    });

    final getParams = {
      'jackpotId': id.toString(),
      'lang': context.locale.toString()
    };

    var url = Uri(
      scheme: config.protocol,
      host: config.hostname,
      path: 'betting-api-gateway/user/rest/jackpot/get-superjackpot',
      queryParameters: getParams,
    );

    await http.get(url, headers: {"content-type": "application/json"}).then(
        (response) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          jackpotData = result['response'];
        });
      } else {
        debugPrint('error');
      }
    });
    setState(() {
      jackpotListFetched = true;
    });
  }

  requestBody() {
    Map obj = {};
    double splitTickets = countSplit();
    List matchObjArr = matchObjList;

    for (int i = 0; i < matchObjList.length; i++) {
      matchObjArr[i]['odds'] = odds
          .where((val) => matchObjArr[i]['matchId'] == val['matchId'])
          .toList();
    }

    obj['totalProbability'] = "2";
    obj['stakeAmount'] = splitTickets > 0
        ? this.doubleStake(jackpotData['stake'], splitTickets)
        : jackpotData['stake'];
    obj['reofferRefId'] = "";
    obj['betType'] = splitTickets > 0 ? "sjc" : "sjp";
    obj['maxWin'] = jackpotData['amount'];
    obj['minBet'] = 0.5;
    obj['pageType'] = 0;
    obj['bonusPercent'] = 1;
    obj['bonusValue'] = 0;
    obj['stakeTax'] = 0;
    obj['useBonusBalanceFrom'] = "";
    obj['superJpId'] = jackpotData['id'];
    obj['values'] = matchObjArr;

    return obj;
  }

  addMatchObj(matchData, tip) {
    if (matchObjList.firstWhere((val) => val['matchId'] == matchData['id'],
            orElse: () => null) !=
        null) {
      if (odds.firstWhere((val) => val['id'] == tip['svrOddID'],
              orElse: () => null) !=
          null) {
        if (odds.where((val) => val['matchId'] == matchData['id']).length ==
            1) {
          setState(() {
            matchObjList = matchObjList
                .where((e) => e['matchId'] != matchData['id'])
                .toList();
            odds =
                odds.where((val) => val['matchId'] != matchData['id']).toList();
          });
        } else {
          List newOdds = odds.where((e) => e['id'] != tip['svrOddID']).toList();
          setState(() {
            odds = newOdds;
          });
        }
        return;
      } else {
        Map odd = {
          'value': tip['odd'],
          'id': tip['svrOddID'],
          'tag': "",
          'matchCode': tip['tipDetailsWS']['matchCode'],
          'matchId': matchData['id'],
        };
        setState(() {
          odds = [...odds, odd];
        });
        return;
      }
    }

    Map matchObj = {};

    matchObj['matchId'] = matchData['id'];
    matchObj['btrMatchId'] = 0;
    matchObj['isOutrightType'] = false;
    matchObj['betTitle'] = "uno";
    matchObj['betTitleType'] = "Match Bet";

    Map odd = {
      'value': tip['odd'],
      'id': tip['svrOddID'],
      'tag': "",
      'matchCode': tip['tipDetailsWS']['matchCode'],
      'matchId': matchData['id'],
    };

    setState(() {
      matchObjList = [...matchObjList, matchObj];
      odds = [...odds, odd];
    });
  }

  sendRequest() async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');
    var error;

    setState(() {
      placeButtonLock = true;
    });

    if (accessToken!.length > 0) {
      final store = StoreProvider.of<AppState>(context);
      Map requestBodyObj = requestBody();
      if (requestBodyObj['stakeAmount'] >
          store.state.bonusBalance[0]['realAvailableAmount']) {
        error = "Not enough funds to place bet";
      }

      if (config.stakeTaxEnabled) {
        requestBodyObj['stakeTax'] = (requestBodyObj['stakeAmount'] -
                minusVAT(requestBodyObj['stakeAmount'], config.stakeTaxPercent))
            .toStringAsFixed(2);
        requestBodyObj['stakeAmount'] =
            minusVAT(requestBodyObj['stakeAmount'], config.stakeTaxPercent);
      }

      if (error == null) {
        var url = (Uri.parse(
            '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/ticket/apply'));

        await http
            .post(url,
                headers: {
                  "content-type": "application/json",
                  "Authorization": accessToken,
                },
                body: json.encode(requestBodyObj))
            .then((response) {
          if (response.statusCode == 200) {
            setState(() {
              matchObjList = [];
              odds = [];
            });
            _showDialog(null);
          } else {
            var result = jsonDecode(response.body);
            if (result['errors'].length > 0) {
              _showDialog(result['errors'][0]['message']);
            }
          }
        });
      } else {
        _showDialog(error);
      }
    }

    setState(() {
      placeButtonLock = false;
    });
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  T getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
  }

  pickedRandomly() async {
    setState(() {
      matchObjList = [];
      odds = [];
    });
    jackpotData['markets']
        .forEach((e) => {addMatchObj(e, getRandomElement(e['tips']))});
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {},
        builder: (context, state) {
          List activeJackpotList =
              jackpotList.where((val) => val['state'] != 3).toList();
          String untilTime = '';
          int untilDays = -1;
          var splitTickets = countSplit();
          if (jackpotData.isNotEmpty) {
            untilTime = DateFormat('MMMM dd, yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(jackpotData['expireAt']));
            untilDays = daysBetween(DateTime.now(),
                DateTime.fromMillisecondsSinceEpoch(jackpotData['expireAt']));
          }
          return Scaffold(
            appBar: AppBar(
              title: Image.asset(config.imageLocation + "logo/logo_header.png",
                  fit: BoxFit.contain, height: 32),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () => {Navigator.pop(context)}),
              actions: <Widget>[
                LoginAction(),
              ],
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              activeJackpotList.length > 0
                  ? DefaultTabController(
                      initialIndex: 0,
                      length: activeJackpotList.length, // length of tabs
                      child: Container(
                        color: Theme.of(context).colorScheme.onBackground,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: TabBar(
                              labelPadding: EdgeInsets.all(20),
                              onTap: (index) {
                                int id = activeJackpotList[index]['id'];
                                if (id != activeJackpotId) {
                                  setState(() {
                                    activeJackpotId =
                                        activeJackpotList[index]['id'];
                                    jackpotData = {};
                                  });
                                  getJackpotData(id);
                                }
                              },
                              isScrollable: true,
                              indicatorColor: Colors.transparent,
                              labelColor: Theme.of(context).indicatorColor,
                              unselectedLabelColor:
                                  Colors.white.withOpacity(0.6),
                              tabs: [
                                for (final tab in activeJackpotList)
                                  Container(
                                      alignment: Alignment.center,
                                      height: 100,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                flex: 5,
                                                child: Container(
                                                    height: 100,
                                                    padding:
                                                        EdgeInsets.all(1.0),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomRight,
                                                        end: Alignment.topLeft,
                                                        stops: [0.2, 1],
                                                        colors: [
                                                          Color(0xFF1F1111),
                                                          Color(0xFF1F2320),
                                                        ],
                                                      ),
                                                      border: new Border.all(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                    ),
                                                    child: Image.asset(
                                                      config.imageLocation +
                                                          'jackpot/${tab['type']}.png',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/images/top-tournament/x.png',
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ))),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10.0),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  tab['name'].toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ))
                                          ]))
                              ],
                            )),
                      ))
                  : SizedBox(),
              jackpotData.isNotEmpty
                  ? Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(config.imageLocation +
                                    'jackpot/background_${jackpotList.firstWhere((val) => val['id'] == activeJackpotId, orElse: () => null) != null ? jackpotList.firstWhere((val) => val['id'] == activeJackpotId)['type'] : 1}.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(
                                      LocaleKeys.SUPER_JACKPOT_WIN.tr(args: [
                                        formatter
                                            .format(jackpotData['amount'])
                                            .toString(),
                                        state.currency
                                      ]),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  Spacer(),
                                  new IconButton(
                                      icon: new Icon(Icons.history),
                                      onPressed: () => {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SuperJackpotResults(
                                                        jackpotResultsList:
                                                            jackpotList
                                                                .where((val) =>
                                                                    val['state'] ==
                                                                    3)
                                                                .toList(),
                                                      )),
                                            )
                                          }),
                                  new IconButton(
                                      icon: new Icon(Icons.help),
                                      onPressed: () => {
                                            launch(
                                                "${config.protocol}://${config.linkShareDomainUrl}/pages/jackpot/${jackpotList.firstWhere((val) => val['id'] == activeJackpotId, orElse: () => null) != null ? jackpotList.firstWhere((val) => val['id'] == activeJackpotId)['type'] : 1}")
                                          })
                                ]),
                                SizedBox(height: 5),
                                Text(
                                    LocaleKeys.SUPER_JACKPOT_PREDICT.tr(args: [
                                      jackpotData['markets'].length.toString()
                                    ]),
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 5),
                                Text(
                                    jackpotData['state'] != 2
                                        ? LocaleKeys
                                            .SUPER_JACKPOT_ACCEPTED_UNTIL
                                            .tr(args: [
                                            untilTime,
                                            untilDays.toString()
                                          ])
                                        : LocaleKeys
                                            .SUPER_JACKPOT_ACCEPTED_DATE_UNTIL
                                            .tr(args: [
                                            untilTime,
                                          ]),
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 5),
                                Text(
                                    '${formatter.format(jackpotData['stake'])} ${state.currency}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20))
                              ],
                            )),
                        Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(children: [
                              Text(
                                jackpotData['state'] != 2
                                    ? LocaleKeys.SUPER_JACKPOT_PICKED.tr(args: [
                                        matchObjList.length.toString(),
                                        jackpotData['markets'].length.toString()
                                      ])
                                    : LocaleKeys.SUPER_JACKPOT_BETS_SUSPENDED
                                        .tr(),
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(
                                          '${LocaleKeys.stake.tr()}: ${splitTickets > 0 ? formatter.format(this.doubleStake(jackpotData['stake'], splitTickets)) : formatter.format(jackpotData['stake'])} ${state.currency}',
                                          style: TextStyle(fontSize: 15))),
                                  jackpotData['state'] != 2
                                      ? Expanded(
                                          child: Container(
                                              child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: !placeButtonLock &&
                                                    state.authorization &&
                                                    matchObjList.length >=
                                                        jackpotData['markets']
                                                            .length
                                                ? Theme.of(context)
                                                    .indicatorColor
                                                : Color(0xFF808080)
                                                    .withOpacity(0.70),
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          onPressed: !placeButtonLock &&
                                                  state.authorization &&
                                                  matchObjList.length >=
                                                      jackpotData['markets']
                                                          .length
                                              ? () {
                                                  sendRequest();
                                                }
                                              : null,
                                          child: Text(LocaleKeys.placeBet.tr(),
                                              style: TextStyle(
                                                  color: !placeButtonLock &&
                                                          state.authorization &&
                                                          matchObjList.length >=
                                                              jackpotData[
                                                                      'markets']
                                                                  .length
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                          .withOpacity(0.40)),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center),
                                        )))
                                      : SizedBox(),
                                  jackpotData['state'] != 2
                                      ? Expanded(
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSecondary,
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  pickedRandomly();
                                                },
                                                child: Text(
                                                    LocaleKeys
                                                        .SUPER_JACKPOT_PICK_FOR_ME
                                                        .tr(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.right),
                                              )))
                                      : SizedBox()
                                ],
                              ),
                              config.stakeTaxEnabled
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          '${config.stakeTaxName}(${config.stakeTaxPercent.toStringAsFixed(0)}%): ${(jackpotData['stake'] - minusVAT(jackpotData['stake'], config.stakeTaxPercent)).toStringAsFixed(2)} ${state.currency}'))
                                  : SizedBox()
                            ])),
                        Container(
                            child: ListView.builder(
                                itemCount: jackpotData['markets'].length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return Container(
                                      key: Key(
                                          "${jackpotData['markets'][index]['matchId']}"),
                                      constraints: new BoxConstraints(
                                        minHeight: 50.0,
                                        minWidth: 200.0,
                                      ),
                                      alignment: Alignment.center,
                                      child: new MatchData(
                                        matchData: jackpotData['markets']
                                            [index],
                                        index: index,
                                        odds: odds,
                                        matchObj: matchObjList.length > 0
                                            ? matchObjList.firstWhere(
                                                (val) =>
                                                    val['matchId'] ==
                                                    jackpotData['markets']
                                                        [index]['id'],
                                                orElse: () => null)
                                            : null,
                                        addMatchObj: (matchData, tip) {
                                          addMatchObj(matchData, tip);
                                        },
                                        jakpotStatus: jackpotData['state'],
                                        key: Key(
                                            "${jackpotData['markets'][index]['id']}"),
                                      ));
                                })),
                        Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(children: [
                              Text(
                                jackpotData['state'] != 2
                                    ? LocaleKeys.SUPER_JACKPOT_PICKED.tr(args: [
                                        matchObjList.length.toString(),
                                        jackpotData['markets'].length.toString()
                                      ])
                                    : LocaleKeys.SUPER_JACKPOT_BETS_SUSPENDED
                                        .tr(),
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(
                                          '${LocaleKeys.stake.tr()}: ${splitTickets > 0 ? formatter.format(this.doubleStake(jackpotData['stake'], splitTickets)) : formatter.format(jackpotData['stake'])} ${state.currency}',
                                          style: TextStyle(fontSize: 15))),
                                  jackpotData['state'] != 2
                                      ? Expanded(
                                          child: Container(
                                              child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: !placeButtonLock &&
                                                    state.authorization &&
                                                    matchObjList.length >=
                                                        jackpotData['markets']
                                                            .length
                                                ? Theme.of(context)
                                                    .indicatorColor
                                                : Color(0xFF808080)
                                                    .withOpacity(0.70),
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          onPressed: !placeButtonLock &&
                                                  state.authorization &&
                                                  matchObjList.length >=
                                                      jackpotData['markets']
                                                          .length
                                              ? () {
                                                  sendRequest();
                                                }
                                              : null,
                                          child: Text(LocaleKeys.placeBet.tr(),
                                              style: TextStyle(
                                                  color: !placeButtonLock &&
                                                          state.authorization &&
                                                          matchObjList.length >=
                                                              jackpotData[
                                                                      'markets']
                                                                  .length
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                          .withOpacity(0.40)),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center),
                                        )))
                                      : SizedBox(),
                                  jackpotData['state'] != 2
                                      ? Expanded(
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSecondary,
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  pickedRandomly();
                                                },
                                                child: Text(
                                                    LocaleKeys
                                                        .SUPER_JACKPOT_PICK_FOR_ME
                                                        .tr(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.right),
                                              )))
                                      : SizedBox()
                                ],
                              ),
                              config.stakeTaxEnabled
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          '${config.stakeTaxName}(${config.stakeTaxPercent.toStringAsFixed(0)}%): ${(jackpotData['stake'] - minusVAT(jackpotData['stake'], config.stakeTaxPercent)).toStringAsFixed(2)} ${state.currency}'))
                                  : SizedBox()
                            ])),
                      ],
                    )
                  : Center(
                      child: jackpotListFetched
                          ? Text('No results found')
                          : CircularProgressIndicator(),
                    )
            ])),
          );
        });
  }
}
