import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';
import './myBetsModal.dart';
import 'dart:convert';
import '../config/defaultConfig.dart' as config;
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_betting_app/betslip/BSLogic.dart';
import '../services/storage_service.dart';

class BetslipListitem extends StatefulWidget {
  final odds;
  final betDomainData;
  final matchObj;
  final Function addvariousStakeValue;
  final Function bankerChanged;
  final maxWin;
  final currentTab;
  final lettersArr;
  final bankersArray;
  final Function toggleTrigger;
  final systemRadioValue;
  final sendRequest;
  final placedBets;
  final Function clearPlacedBet;
  final Function onSendRequest;
  final split;
  final Function clearMatch;
  final activeBonus;

  const BetslipListitem(
      {Key? key,
      this.odds,
      this.betDomainData,
      this.matchObj,
      required this.addvariousStakeValue,
      required this.bankerChanged,
      required this.clearMatch,
      this.maxWin,
      this.currentTab,
      this.lettersArr,
      this.bankersArray,
      required this.toggleTrigger,
      this.systemRadioValue,
      this.sendRequest,
      this.placedBets,
      required this.clearPlacedBet,
      required this.onSendRequest,
      this.split,
      this.activeBonus})
      : super(key: key);

  @override
  State<BetslipListitem> createState() => BetslipListitemState();
}

class BetslipListitemState extends State<BetslipListitem>
    with TickerProviderStateMixin {
  String updateClass = '';
  String singleStake = '0';
  double serverOddsValue = 0.0;
  bool showTaxInfo = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  void onStakeChnaged(String stake) {
    setState(() {
      singleStake = stake.length > 0 ? stake : '0';
    });
    widget.addvariousStakeValue({widget.odds['oddId']: stake});
  }

  void generateDataObj() {
    List matchObjArray = widget.matchObj;
    Map oddInfo = widget.betDomainData['betslipOdds'].firstWhere(
        (element) => element['oddId'] == widget.odds['oddId'],
        orElse: () => null);
    //allOddsArray = this.props.state.allOddsArray;
    int ind = -1;
    if (matchObjArray.length > 0) {
      ind = matchObjArray
          .indexWhere((element) => element['oddId'] == widget.odds['oddId']);
    }

    if (ind != -1) {
      Map matchObj = matchObjArray[ind];
      matchObj['Odds'][0]['value'] =
          serverOddsValue > 0 ? serverOddsValue : oddInfo['value'];
      StoreProvider.of<AppState>(context)
          .dispatch(SetMatchObjAction(matchObj: matchObj));
    } else {
      final Map matchObj = {};
      // debugger
      // let getVal1 = getVal([this.props.state.tournamentsData], this.props.oddInfo, 1);
      // let getVal3 = getVal([this.props.state.tournamentsData], this.props.oddInfo, 3);
      // let getVal4 = getVal([this.props.state.tournamentsData], this.props.oddInfo, 4);
      // if (getVal1 && getVal3 && getVal4) {
      // let oddInformation =
      // debugger;
      matchObj["Test"] = true;
      matchObj["Value"] =
          serverOddsValue > 0 ? serverOddsValue : oddInfo['value'];
      matchObj["CountryId"] = null; //getVal1.countryId;
      matchObj["SportId"] = widget.odds['sport'];
      matchObj["OddId"] = widget.odds['oddId'];
      matchObj["status"] = widget.betDomainData['status'] != 0;
      matchObj["type"] =
          widget.betDomainData['isLiveBet'] == true ? "live" : "prematch";
      matchObj["isLiveBet"] = widget.betDomainData['isLiveBet'];
      matchObj["Oddtag"] = widget.betDomainData['betdomainName'];
      matchObj["Home"] = widget.odds['sport'] == 100 ||
              widget.odds['sport'] == 101
          ? ""
          : widget.betDomainData['matchName'].split("vs.")[0]; //getVal1.home;
      matchObj["Away"] = widget.odds['sport'] == 100 ||
              widget.odds['sport'] == 101
          ? ""
          : widget.betDomainData['matchName'].split("vs.")[1]; //getVal1.away;
      matchObj["BetTitle"] = oddInfo['information'] != null
          ? oddInfo['information']
          : ""; //getVal3.betTitleName;betdomainShortName
      matchObj["betMarketId"] =
          widget.betDomainData['betDomainId']; //getVal3.id;betDomainId
      matchObj["BetdomainsLength"] = widget.betDomainData['betdomainSize'];
      // matchObj.BetdomainsLength = getVal1.groups.reduce((a, b) => {
      //     return a + b.Markets.length
      // }, 0);
      matchObj["DeleteOdd"] = "DELETE_NEW_ODD";
      matchObj["MatchId"] = widget.odds['match'];
      matchObj["BtrMatchId"] = 0; //getVal1.btrmatchid;
      matchObj["TournamentId"] = widget.betDomainData['tournamentId'];
      matchObj["IsOutrightType"] =
          widget.betDomainData['outrightType']; //getVal1.isOutrightType;
      matchObj["BetTitleType"] =
          widget.betDomainData['betdomainName']; //getVal3.betTitleType;
      matchObj["betdomainNumberCanBeCashout"] =
          widget.betDomainData['betdomainNumberCanBeCashout'];

      matchObj['Odds'] = [
        {
          'value': serverOddsValue > 0 ? serverOddsValue : oddInfo['value'],
          'id': oddInfo['oddId'],
          'tag': "",
          'matchCode': widget.betDomainData['matchCode'] != null
              ? widget.betDomainData['matchCode']
              : 0,
        },
      ];
      // if (!tournamentsCount.includes(getVal3.id)) tournamentsCount.push(getVal3.id);

      if (matchObj['Value'] != 0 && matchObj['Value'] != null) {
        StoreProvider.of<AppState>(context)
            .dispatch(SetMatchObjAction(matchObj: matchObj));
      }
    }
  }

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

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.betDomainData.length > 0 ? generateDataObj() : null);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: 0.0, end: .5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void deactivate() {
    super.deactivate();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(BetslipListitem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.betDomainData['betslipOdds'].firstWhere(
            (element) => element['oddId'] == widget.odds['oddId'],
            orElse: () => null)['value'] >
        oldWidget.betDomainData['betslipOdds'].firstWhere(
            (element) => element['oddId'] == widget.odds['oddId'],
            orElse: () => null)['value']) {
      updateClass = 'odd-up';
    }

    if (widget.betDomainData['betslipOdds'].firstWhere(
            (element) => element['oddId'] == widget.odds['oddId'],
            orElse: () => null)['value'] <
        oldWidget.betDomainData['betslipOdds'].firstWhere(
            (element) => element['oddId'] == widget.odds['oddId'],
            orElse: () => null)['value']) {
      updateClass = 'odd-down';
    }

    int ind = widget.matchObj
        .indexWhere((element) => element['OddId'] == widget.odds['oddId']);

    if (ind == -1 && widget.betDomainData != null) {
      generateDataObj();
    }

    if (ind != -1 &&
        widget.betDomainData != null &&
        oldWidget.betDomainData != null &&
        widget.betDomainData['status'] != oldWidget.betDomainData['status']) {
      generateDataObj();
    }

    if (ind != -1 &&
        oldWidget.betDomainData != null &&
        oldWidget.betDomainData['betslipOdds'] != null &&
        widget.betDomainData != null &&
        widget.betDomainData['betslipOdds'] != null) {
      double oldOdd = oldWidget.betDomainData['betslipOdds'].firstWhere(
          (element) => element['oddId'] == widget.odds['oddId'],
          orElse: () => null)['value'];

      double newOdd = widget.betDomainData['betslipOdds'].firstWhere(
          (element) => element['oddId'] == widget.odds['oddId'],
          orElse: () => null)['value'];

      if (oldOdd != newOdd) {
        generateDataObj();
      }

      // this.generateDataObj()
    }

    Future.delayed(const Duration(milliseconds: 10000), () {
      updateClass = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    Map oddInfo = widget.betDomainData.length > 0
        ? widget.betDomainData['betslipOdds'].firstWhere(
            (element) => element['oddId'] == widget.odds['oddId'],
            orElse: () => null)
        : null;

    int ind = -1;
    bool bankerActive = false;
    bool bankerLock = false;

    if (widget.currentTab == 2) {
      ind = widget.matchObj
          .where((e) => widget.odds['sport'] == e['SportId'])
          .toList()
          .indexWhere((element) => element['OddId'] == widget.odds['oddId']);

      if (widget.bankersArray.contains(widget.odds['oddId'])) {
        bankerActive = true;
      }

      if (widget.systemRadioValue == 2 ||
          widget.lettersArr[ind].replaceAll(new RegExp(r'[^0-9]'), '').length >
              0) {
        bankerLock = true;
      }
    }

    bool betSlipItemStopped = widget.matchObj.firstWhere(
                (element) => element['OddId'] == widget.odds['oddId'],
                orElse: () => null) !=
            null
        ? widget.matchObj.firstWhere(
            (element) => element['OddId'] == widget.odds['oddId'],
            orElse: () => null)['status']
        : false;

    double opacityBetslip =
        betSlipItemStopped || widget.sendRequest || widget.placedBets != null
            ? 0.40
            : 1.00;

    return widget.betDomainData.length > 0
        ? Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Row(children: [
                        widget.currentTab == 2 && ind != -1
                            ? Column(children: [
                                Text('${widget.lettersArr[ind]}',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                InkWell(
                                    onTap: bankerLock && !bankerActive
                                        ? null
                                        : () {
                                            widget.bankerChanged(
                                                widget.odds['oddId']);
                                            widget.toggleTrigger(true);
                                          },
                                    child: Opacity(
                                        opacity: bankerLock && !bankerActive
                                            ? 0.4
                                            : 1,
                                        child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: bankerActive
                                                  ? Color(0xFFFFC500)
                                                  : Colors.grey,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 3,
                                                  blurRadius: 7,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.format_bold,
                                              color: Colors.black,
                                              size: 20,
                                            ))))
                              ])
                            : SizedBox(),
                        Expanded(
                            child: Opacity(
                                opacity: opacityBetslip,
                                child: widget.odds['sport'] == 100 ||
                                        widget.odds['sport'] == 101
                                    ? ticketDetailsRacesWidget(
                                        '${widget.betDomainData['tournamentName']}',
                                        widget.betDomainData['matchStart'] !=
                                                null
                                            ? widget.betDomainData['matchStart']
                                            : 1,
                                        '${widget.betDomainData['betdomainShortName']}',
                                        '${oddInfo['information']}',
                                        '',
                                        '${serverOddsValue > 0 ? serverOddsValue : oddInfo['value']}',
                                        updateClass,
                                        singleStake)
                                    : ticketDetailsWidget(
                                        '${widget.betDomainData['matchName'].split(" vs. ")[0]}',
                                        '${widget.betDomainData['matchName'].split(" vs. ")[1]}',
                                        '${widget.betDomainData['betdomainShortName']}',
                                        '${oddInfo['information']}',
                                        '',
                                        '${serverOddsValue > 0 ? serverOddsValue : oddInfo['value']}',
                                        updateClass,
                                        singleStake)))
                      ]),
                      betSlipItemStopped || widget.sendRequest
                          ? Icon(Icons.lock, size: 64, color: Colors.grey)
                          : widget.placedBets != null &&
                                  widget.placedBets['accepted'] == true
                              ? Container(
                                  decoration: new BoxDecoration(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    color: Color(0xFFFFF1F0).withOpacity(0.7),
                                    /*boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 5),
                                  ),
                                ]*/
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: Icon(Icons.check_circle,
                                                    size: 20,
                                                    color: Colors.green),
                                              ),
                                              TextSpan(
                                                style: TextStyle(
                                                    color: Colors.green[700],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                                text: widget.placedBets[
                                                            'method'] ==
                                                        "place"
                                                    ? " ${LocaleKeys.ticketAccepted.tr()}"
                                                    : " ${LocaleKeys.ticketSaved.tr()}",
                                              ),
                                            ],
                                          ),
                                        ),
                                        widget.placedBets['code'] != null
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent),
                                                      child: Text(
                                                          widget.placedBets[
                                                              'code'],
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .yellow[900],
                                                              fontSize: 20)),
                                                      onPressed: () {
                                                        handleCouponCode(
                                                            widget.placedBets[
                                                                'code']);
                                                      },
                                                    ),
                                                    IconButton(
                                                        icon: new Icon(
                                                            Icons.share,
                                                            color: Colors
                                                                .yellow[900]),
                                                        onPressed: () => {
                                                              Share.share(
                                                                  '${config.protocol}://${config.linkShareDomainUrl}/sport?coupon_code=${widget.placedBets['code']}')
                                                            }),
                                                  ])
                                            : SizedBox(),
                                        SizedBox(height: 5),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          child: Text(LocaleKeys.ok.tr(),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onPressed: () {
                                            widget.clearMatch(
                                                widget.odds['match'],
                                                widget.odds['oddId']);
                                          },
                                        ),
                                      ])))
                              : widget.placedBets != null &&
                                      widget.placedBets['accepted'] == false
                                  ? Container(
                                      decoration: new BoxDecoration(
                                        borderRadius:
                                            new BorderRadius.circular(5.0),
                                        color:
                                            Color(0xFFFFF1F0).withOpacity(0.7),
                                        /*boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 5),
                                  ),
                                ]*/
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  WidgetSpan(
                                                    child: Icon(Icons.warning,
                                                        size: 20,
                                                        color: Colors.red),
                                                  ),
                                                  TextSpan(
                                                    style: TextStyle(
                                                        color: Colors.red[700],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                    text:
                                                        " ${LocaleKeys.ticketUnAccepted.tr()}",
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Text(
                                                widget.placedBets[
                                                            'errorText'] !=
                                                        null
                                                    ? widget
                                                        .placedBets['errorText']
                                                    : "",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                                textAlign: TextAlign.center),
                                            SizedBox(height: 15),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red),
                                                    child: Text(
                                                        widget.placedBets[
                                                                    'errorCode'] ==
                                                                217
                                                            ? LocaleKeys.no.tr()
                                                            : LocaleKeys.remove
                                                                .tr(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    onPressed: widget
                                                                    .placedBets[
                                                                'errorCode'] ==
                                                            217
                                                        ? () {
                                                            setState(() {
                                                              serverOddsValue =
                                                                  widget.placedBets[
                                                                      'serverOdds'];
                                                            });
                                                            generateDataObj();
                                                            widget.clearPlacedBet(
                                                                widget.odds[
                                                                    'oddId']);
                                                          }
                                                        : () {
                                                            widget.clearMatch(
                                                                widget.odds[
                                                                    'match'],
                                                                widget.odds[
                                                                    'oddId']);
                                                          },
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green),
                                                    child: Text(
                                                        widget.placedBets[
                                                                    'errorCode'] ==
                                                                217
                                                            ? LocaleKeys.yes
                                                                .tr()
                                                            : LocaleKeys.save
                                                                .tr(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    onPressed: widget
                                                                    .placedBets[
                                                                'errorCode'] ==
                                                            217
                                                        ? () {
                                                            setState(() {
                                                              serverOddsValue =
                                                                  widget.placedBets[
                                                                      'serverOdds'];
                                                            });
                                                            generateDataObj();
                                                            final store =
                                                                StoreProvider.of<
                                                                            AppState>(
                                                                        context)
                                                                    .state;
                                                            widget.clearPlacedBet(
                                                                widget.odds[
                                                                    'oddId']);
                                                            widget.onSendRequest(
                                                                store.matchObj,
                                                                store.limits,
                                                                "place");
                                                          }
                                                        : () {
                                                            widget.clearPlacedBet(
                                                                widget.odds[
                                                                    'oddId']);
                                                          },
                                                  )
                                                ]),
                                          ])))
                                  : SizedBox()
                    ],
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: const MySeparator(color: Colors.black),
            )
          ])
        : CircularProgressIndicator();
  }

  Widget _buildDetailsButton(possibleWin) {
    if ((config.stakeTaxEnabled &&
            widget.currentTab == 0 &&
            widget.activeBonus.isEmpty) ||
        (config.profitTaxEnabled &&
            widget.currentTab == 0 &&
            widget.activeBonus.isEmpty &&
            double.parse(possibleWin) >= config.profitTaxMinIncome)) {
      return InkWell(
        child: RotationTransition(
            turns: _animation,
            child: Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            )),
        onTap: () {
          setState(() {
            showTaxInfo = !showTaxInfo;
          });
          if (_controller.isDismissed) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        },
      );
    }
    return SizedBox();
  }

  Widget ticketDetailsWidget(
    String firstMatchName,
    String secondMatchName,
    String oddMarket,
    String oddValue,
    String secondTitle,
    String secondDesc,
    oddUpdate,
    String singleStake,
  ) {
    String possibleWin = config.stakeTaxEnabled && widget.activeBonus.isEmpty
        ? (minusVAT(double.parse(singleStake), config.stakeTaxPercent) *
                    double.parse(secondDesc)) >
                widget.maxWin
            ? widget.maxWin.toStringAsFixed(2)
            : (minusVAT(double.parse(singleStake), config.stakeTaxPercent) *
                    double.parse(secondDesc))
                .toStringAsFixed(2)
        : (double.parse(singleStake) * double.parse(secondDesc)) > widget.maxWin
            ? widget.maxWin
            : (double.parse(singleStake) * double.parse(secondDesc))
                .toStringAsFixed(2);
    return Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child:
            // 20%
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                Widget>[
          Text(
            firstMatchName,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              secondMatchName,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          widget.betDomainData['betdomainNumberCanBeCashout'] &&
                  !widget.split &&
                  widget.activeBonus.isEmpty
              ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Tooltip(
                    decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(5.0),
                        color: Colors.grey.withOpacity(0.7)),
                    message: LocaleKeys.marketCashout.tr(),
                    child: Icon(Icons.monetization_on, color: Colors.black87),
                  ),
                  SizedBox(width: 5),
                  Text(
                    oddMarket,
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ])
              : Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    oddMarket,
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                oddValue,
                style: TextStyle(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: oddUpdate == 'odd-up'
                          ? Colors.green
                          : oddUpdate == 'odd-down'
                              ? Colors.red
                              : Colors.white),
                  child: Text(
                    secondDesc,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )),
            ),
          ]),
          widget.currentTab < 1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        width: 100,
                        height: 30,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          onChanged: (value) {
                            onStakeChnaged(value);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: LocaleKeys.stake.tr(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: widget.currentTab < 1
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                    Text("${LocaleKeys.estWin.tr()} ",
                                        style: TextStyle(color: Colors.black)),
                                    Text(possibleWin,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    _buildDetailsButton(possibleWin)
                                  ])
                            : null,
                      ),
                    ])
              : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
          config.stakeTaxEnabled &&
                  widget.currentTab == 0 &&
                  widget.activeBonus.isEmpty
              ? AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                      height: showTaxInfo ? null : 0,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                    text: new TextSpan(
                                      // Note: Styles for TextSpans must be explicitly defined.
                                      // Child text spans will inherit styles from parent
                                      style: new TextStyle(
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        new TextSpan(
                                            text:
                                                '${config.stakeTaxName}(-${config.stakeTaxPercent}%): '),
                                        new TextSpan(
                                            text:
                                                '${(double.parse(singleStake) - minusVAT(double.parse(singleStake), config.stakeTaxPercent)).toStringAsFixed(2)}',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ]),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                    text: new TextSpan(
                                      // Note: Styles for TextSpans must be explicitly defined.
                                      // Child text spans will inherit styles from parent
                                      style: new TextStyle(
                                        color: Colors.black87,
                                      ),
                                      children: <TextSpan>[
                                        new TextSpan(
                                            text:
                                                'Stake after ${config.stakeTaxName}: '),
                                        new TextSpan(
                                            text:
                                                '${(minusVAT(double.parse(singleStake), config.stakeTaxPercent))}',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ]),
                            SizedBox(height: 10)
                          ])))
              : SizedBox(),
          config.profitTaxEnabled &&
                  widget.currentTab == 0 &&
                  widget.activeBonus.isEmpty &&
                  double.parse(possibleWin) >= config.profitTaxMinIncome
              ? AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                      height: showTaxInfo ? null : 0,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                RichText(
                                  text: new TextSpan(
                                    // Note: Styles for TextSpans must be explicitly defined.
                                    // Child text spans will inherit styles from parent
                                    style: new TextStyle(
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      new TextSpan(
                                          text:
                                              '${config.profitTaxName}(-${config.profitTaxPercent}%): '),
                                      new TextSpan(
                                          text:
                                              '${(minusProfitTax(double.parse(possibleWin), config.profitTaxPercent, config.stakeTaxEnabled ? minusVAT(double.parse(singleStake), config.stakeTaxPercent) : double.parse(singleStake))).toStringAsFixed(2)}',
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                RichText(
                                  text: new TextSpan(
                                    // Note: Styles for TextSpans must be explicitly defined.
                                    // Child text spans will inherit styles from parent
                                    style: new TextStyle(
                                      color: Colors.black87,
                                    ),
                                    children: <TextSpan>[
                                      new TextSpan(text: 'Net payout: '),
                                      new TextSpan(
                                          text:
                                              '${(double.parse(possibleWin) - (minusProfitTax(double.parse(possibleWin), config.profitTaxPercent, config.stakeTaxEnabled ? minusVAT(double.parse(singleStake), config.stakeTaxPercent) : double.parse(singleStake)))).toStringAsFixed(2)}',
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ])
                        ],
                      )))
              : SizedBox()
        ]));
  }

  Widget ticketDetailsRacesWidget(
    String name,
    int startDate,
    String oddMarket,
    String oddValue,
    String secondTitle,
    String secondDesc,
    oddUpdate,
    String singleStake,
  ) {
    String timeFormat = "";
    if (config.timeFormat[context.locale.toString()] == 0) {
      timeFormat = 'h:mma';
    } else {
      timeFormat = 'HH:mm';
    }
    String possibleWin = config.stakeTaxEnabled && widget.activeBonus.isEmpty
        ? (minusVAT(double.parse(singleStake), config.stakeTaxPercent) *
                    double.parse(secondDesc)) >
                widget.maxWin
            ? widget.maxWin.toStringAsFixed(2)
            : (minusVAT(double.parse(singleStake), config.stakeTaxPercent) *
                    double.parse(secondDesc))
                .toStringAsFixed(2)
        : (double.parse(singleStake) * double.parse(secondDesc)) > widget.maxWin
            ? widget.maxWin
            : (double.parse(singleStake) * double.parse(secondDesc))
                .toStringAsFixed(2);
    return Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child:
            // 20%
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${DateFormat(timeFormat).format(DateTime.fromMillisecondsSinceEpoch(startDate)).toString()}',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                name,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ]),
          widget.betDomainData['betdomainNumberCanBeCashout'] &&
                  !widget.split &&
                  widget.activeBonus.isEmpty
              ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Tooltip(
                    decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(5.0),
                        color: Colors.grey.withOpacity(0.7)),
                    message: LocaleKeys.marketCashout.tr(),
                    child: Icon(Icons.monetization_on, color: Colors.black87),
                  ),
                  SizedBox(width: 5),
                  Text(
                    oddMarket,
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ])
              : Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    oddMarket,
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                oddValue,
                style: TextStyle(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: oddUpdate == 'odd-up'
                          ? Colors.green
                          : oddUpdate == 'odd-down'
                              ? Colors.red
                              : Colors.white),
                  child: Text(
                    secondDesc,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )),
            ),
          ]),
          widget.currentTab < 1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        width: 100,
                        height: 30,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          onChanged: (value) {
                            onStakeChnaged(value);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: LocaleKeys.stake.tr(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: widget.currentTab < 1
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                    Text("${LocaleKeys.estWin.tr()} ",
                                        style: TextStyle(color: Colors.black)),
                                    Text(possibleWin,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    _buildDetailsButton(possibleWin)
                                  ])
                            : null,
                      ),
                    ])
              : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
          config.stakeTaxEnabled &&
                  widget.currentTab == 0 &&
                  widget.activeBonus.isEmpty
              ? AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                      height: showTaxInfo ? null : 0,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                    text: new TextSpan(
                                      // Note: Styles for TextSpans must be explicitly defined.
                                      // Child text spans will inherit styles from parent
                                      style: new TextStyle(
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        new TextSpan(
                                            text:
                                                '${config.stakeTaxName}(-${config.stakeTaxPercent}%): '),
                                        new TextSpan(
                                            text:
                                                '${(double.parse(singleStake) - minusVAT(double.parse(singleStake), config.stakeTaxPercent)).toStringAsFixed(2)}',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ]),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                    text: new TextSpan(
                                      // Note: Styles for TextSpans must be explicitly defined.
                                      // Child text spans will inherit styles from parent
                                      style: new TextStyle(
                                        color: Colors.black87,
                                      ),
                                      children: <TextSpan>[
                                        new TextSpan(
                                            text:
                                                'Stake after ${config.stakeTaxName}: '),
                                        new TextSpan(
                                            text:
                                                '${(minusVAT(double.parse(singleStake), config.stakeTaxPercent))}',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ]),
                            SizedBox(height: 10)
                          ])))
              : SizedBox(),
          config.profitTaxEnabled &&
                  widget.currentTab == 0 &&
                  widget.activeBonus.isEmpty &&
                  double.parse(possibleWin) >= config.profitTaxMinIncome
              ? AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                      height: showTaxInfo ? null : 0,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                RichText(
                                  text: new TextSpan(
                                    // Note: Styles for TextSpans must be explicitly defined.
                                    // Child text spans will inherit styles from parent
                                    style: new TextStyle(
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      new TextSpan(
                                          text:
                                              '${config.profitTaxName}(-${config.profitTaxPercent}%): '),
                                      new TextSpan(
                                          text:
                                              '${(minusProfitTax(double.parse(possibleWin), config.profitTaxPercent, config.stakeTaxEnabled ? minusVAT(double.parse(singleStake), config.stakeTaxPercent) : double.parse(singleStake))).toStringAsFixed(2)}',
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                RichText(
                                  text: new TextSpan(
                                    // Note: Styles for TextSpans must be explicitly defined.
                                    // Child text spans will inherit styles from parent
                                    style: new TextStyle(
                                      color: Colors.black87,
                                    ),
                                    children: <TextSpan>[
                                      new TextSpan(text: 'Net payout: '),
                                      new TextSpan(
                                          text:
                                              '${(double.parse(possibleWin) - (minusProfitTax(double.parse(possibleWin), config.profitTaxPercent, config.stakeTaxEnabled ? minusVAT(double.parse(singleStake), config.stakeTaxPercent) : double.parse(singleStake)))).toStringAsFixed(2)}',
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ])
                        ],
                      )))
              : SizedBox()
        ]));
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
