import 'package:flutter/material.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
//import 'dart:async';
import 'package:intl/intl.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/defaultConfig.dart' as config;

const betStatuses = {
  'Opened': {'color': Colors.white54, 'text': "Opened"},
  'Cancelled': {'color': Colors.grey, 'text': "Cancelled"},
  'Lost': {'color': Colors.red, 'text': "Lost"},
  'Won': {'color': Colors.green, 'text': "Won"},
  'Refund': {'color': Colors.blue, 'text': "Refund"},
  'HalfWon': {'color': Colors.orange, 'text': "Half-won"},
  'HalfLost': {'color': Colors.orange, 'text': "Half-lost"}
};

class MyBetsModal extends StatefulWidget {
  final number;
  final code;
  final category;
  final ticket;
  const MyBetsModal(
      {Key? key, this.number, this.code, this.category, this.ticket})
      : super(key: key);

  @override
  MyBetsModalState createState() => MyBetsModalState();
}

class MyBetsModalState extends State<MyBetsModal> {
  String timeFormat = "";
  handleBetType(type) {
    switch (type) {
      case 'sng':
        return LocaleKeys.single.tr();
      case 'cmb':
        return LocaleKeys.ticketCombo.tr();
      case 'cmp':
        return LocaleKeys.ticketComboSplit.tr();
      case 'syp':
        return LocaleKeys.ticketSystemSplit.tr();
      case 'sys':
        return '${LocaleKeys.system.tr()} ${widget.ticket['bets']['betWS'][0]['systemX'].toString() + "/" + widget.ticket['bets']['betWS'][0]['systemY'].toString() + (widget.ticket['bets']['betWS'][0]['tips2BetMulti']['tipWS'].length > 0 ? " + " + widget.ticket['bets']['betWS'][0]['tips2BetMulti']['tipWS'].length.toString() + " bankers " : "")}';
      default:
        return '';
    }
  }

  handleTicketType(type) {
    switch (type) {
      case 0:
        return LocaleKeys.prematch.tr();
      case 1:
        return LocaleKeys.live.tr();
      case 2:
        return LocaleKeys.ticketMixed.tr();
      case 10:
        return LocaleKeys.ticketV_Sports.tr();
      case 20:
        return LocaleKeys.ticketHorseRaces.tr();
      case 21:
        return LocaleKeys.ticketGreyhoundRaces.tr();
      default:
        return '';
    }
  }

  getStatus(tipWS) {
    var won = tipWS['won'];
    var calculated = tipWS['calculated'];
    var eventCancelled = tipWS['tipDetailsWS']['eventCancelled'];
    var voidStatus = tipWS['tipDetailsWS']['voidStatus'];

    var status;

    if (eventCancelled != null) {
      status = betStatuses['Cancelled'];
    } else if (!calculated) {
      status = betStatuses['Opened'];
    } else if (won) {
      if (voidStatus == "R")
        status = betStatuses['Refund'];
      else if (voidStatus == "HW")
        status = betStatuses['HalfWon'];
      else if (voidStatus == "HL")
        status = betStatuses['HalfLost'];
      else
        status = betStatuses['Won'];
    } else {
      status = betStatuses['Lost'];
    }

    return status;
  }

  void initState() {
    super.initState();
    //WidgetsBinding.instance?.addPostFrameCallback((_) => );
  }

  Widget getMatches(List<dynamic> strings) {
    return new Wrap(
        children: strings
            .map((item) => new Container(
                margin:
                    EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: [
                      Row(children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(children: [
                                Icon(Icons.bookmark,
                                    color: getStatus(item)['color']),
                                Text(
                                  getStatus(item)['text'],
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                            )),
                        Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                item['tipDetailsWS']['eventName'],
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                item['tipDetailsWS']['ligaName'],
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                      ]),
                      Divider(
                          height: 1,
                          thickness: 2,
                          color: Colors.grey,
                          indent: 20,
                          endIndent: 20),
                      Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: '${LocaleKeys.result.tr()}: ',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .subtitle2,
                                        ),
                                        TextSpan(
                                          text: item['tipDetailsWS']
                                                      ['result'] !=
                                                  null
                                              ? item['tipDetailsWS']['result']
                                              : '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )),
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: '${LocaleKeys.market.tr()}: ',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .subtitle2,
                                        ),
                                        TextSpan(
                                          text: item['tipDetailsWS']
                                              ['betDomainName'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )),
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: '${LocaleKeys.date.tr()}: ',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .subtitle2,
                                        ),
                                        TextSpan(
                                          text: DateFormat(timeFormat).format(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      item['tipDetailsWS']
                                                          ['startdate'])),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ))
                            ])),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: '${LocaleKeys.outcome.tr()}: ',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .subtitle2,
                                        ),
                                        TextSpan(
                                          text: item['tipDetailsWS']['tip'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )),
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: '${LocaleKeys.odd.tr()}: ',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .subtitle2,
                                        ),
                                        TextSpan(
                                          text: item['odd'].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )),
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${LocaleKeys.correctOutcome.tr()}: ',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .subtitle2,
                                        ),
                                        TextSpan(
                                          text: item['tipDetailsWS']
                                                      ['winnerTip'] !=
                                                  null
                                              ? item['tipDetailsWS']
                                                      ['winnerTip']
                                                  .toString()
                                              : '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ))
                            ])),
                      ]),
                    ])))
            .toList());
  }

  findCategory(ticket) {
    if (!ticket['calculated']) {
      return LocaleKeys.open.tr();
    } else if (ticket['calculated'] && ticket['won']) {
      return LocaleKeys.won.tr();
    } else if (ticket['calculated'] && !ticket['won']) {
      return LocaleKeys.lost.tr();
    } else {
      return LocaleKeys.ticketUnknown.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = "MM/dd/yyyy', 'h:mma:ss";
          } else {
            timeFormat = "MM/dd/yyyy', 'HH:mm:ss";
          }
          return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.ticket.tr()),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: widget.ticket['bets'] != null
                  ? ListView(
                      children: [
                        Container(
                            margin:
                                EdgeInsets.only(left: 15, top: 15, right: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ListView(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                children: [
                                  Row(children: [
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.couponCode.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      subtitle: Text(
                                        widget.code,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.ticketNumber.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      subtitle: Text(
                                        widget.ticket['ticketNbr'],
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    ))
                                  ]),
                                  Divider(
                                      height: 1,
                                      thickness: 2,
                                      color: Colors.grey,
                                      indent: 20,
                                      endIndent: 20),
                                  Row(children: [
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.acceptedAt.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      subtitle: Text(
                                        DateFormat(timeFormat).format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                widget.ticket['acceptedTime'])),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.paidOutAt.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      subtitle: Text(
                                        widget.ticket['paid']
                                            ? DateFormat(timeFormat).format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        widget.ticket[
                                                            'paidTime']))
                                            : LocaleKeys.notPaid.tr(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    ))
                                  ]),
                                  Divider(
                                      height: 1,
                                      thickness: 2,
                                      color: Colors.grey,
                                      indent: 20,
                                      endIndent: 20),
                                  Row(children: [
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.totalStake.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      subtitle: Text(
                                        widget.ticket['stake'].toString(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.possibleWin.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      subtitle: Text(
                                        widget.ticket['bets']['betWS'][0]
                                                ['maxWin']
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    ))
                                  ]),
                                  Row(children: [
                                    config.stakeTaxEnabled &&
                                            widget.ticket['stakeTax'] != null
                                        ? Expanded(
                                            child: ListTile(
                                            title: Text(
                                              "${config.stakeTaxName}(-${config.stakeTaxPercent}%)",
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .subtitle1,
                                            ),
                                            subtitle: Text(
                                              widget.ticket['stakeTax'].toString(),
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.white),
                                            ),
                                          ))
                                        : SizedBox(),
                                    config.profitTaxEnabled &&
                                            widget.ticket['profitTax'] != null
                                        ? Expanded(
                                            child: ListTile(
                                            title: Text(
                                                "${config.profitTaxName}(-${config.profitTaxPercent}%)",
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .subtitle1),
                                            subtitle: Text(
                                              widget.ticket['profitTax']
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.white),
                                            ),
                                          ))
                                        : SizedBox()
                                  ]),
                                  Divider(
                                      height: 1,
                                      thickness: 2,
                                      color: Colors.grey,
                                      indent: 20,
                                      endIndent: 20),
                                  ListTile(
                                    title: Text(
                                      LocaleKeys.status.tr(),
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .subtitle1,
                                    ),
                                    subtitle: Text(
                                      findCategory(widget.ticket),
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                    ),
                                  )
                                ])),
                        Container(
                            margin: EdgeInsets.only(
                                left: 15, top: 5, right: 15, bottom: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ListView(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                children: [
                                  Row(children: [
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.ticketType.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle2,
                                      ),
                                      subtitle: Text(
                                        handleTicketType(
                                            widget.ticket['ticketTyp']),
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.betType.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle2,
                                      ),
                                      subtitle: Text(
                                        handleBetType(widget.ticket['bets']
                                            ['betWS'][0]['betType']),
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        'Total Odds',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle2,
                                      ),
                                      subtitle: Text(
                                        widget.ticket['bets']['betWS'][0]
                                                ['maxOdd']
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                    ))
                                  ]),
                                  Divider(
                                      height: 1,
                                      thickness: 2,
                                      color: Colors.grey,
                                      indent: 20,
                                      endIndent: 20),
                                  Row(children: [
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.combinations.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle2,
                                      ),
                                      subtitle: Text(
                                        widget.ticket['bets']['betWS'][0]
                                                ['rows']
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                    Expanded(
                                        child: ListTile(
                                      title: Text(
                                        LocaleKeys.paymentAmount.tr(),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle2,
                                      ),
                                      subtitle: Text(
                                        widget.ticket['payAmount'].toString(),
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                  ]),
                                ])),
                        getMatches(widget.ticket['bets']['betWS'][0]['bankTips']
                            ['tipWS']),
                        getMatches(widget.ticket['bets']['betWS'][0]
                            ['tips2BetMulti']['tipWS'])
                      ],
                    )
                  : Center(child: CircularProgressIndicator()));
        });
  }
}
