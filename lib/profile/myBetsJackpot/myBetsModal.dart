import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
//import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../config/defaultConfig.dart' as config;
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';

const betStatuses = {
  'Opened': {'color': Colors.white54, 'text': "Opened"},
  'Cancelled': {'color': Colors.grey, 'text': "Cancelled"},
  'Lost': {'color': Colors.red, 'text': "Lost"},
  'Won': {'color': Colors.green, 'text': "Won"},
  'Refund': {'color': Colors.blue, 'text': "Refund"},
  'HalfWon': {'color': Colors.orange, 'text': "Half-won"},
  'HalfLost': {'color': Colors.orange, 'text': "Half-lost"}
};

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

class MyBetsModal extends StatefulWidget {
  final number;
  final code;
  final category;
  const MyBetsModal({Key? key, this.number, this.code, this.category})
      : super(key: key);

  @override
  MyBetsModalState createState() => MyBetsModalState();
}

class MyBetsModalState extends State<MyBetsModal> {
  Map ticket = {};
  String timeFormat = "";

  void fetchTickets() async {
    if (widget.number != null && widget.code != null) {
      final getParams = {
        'number': widget.number.toString(),
        'code': widget.code.toString(),
        'lang': 'en',
      };

      final StorageService _storageService = StorageService();
      String? accessToken = await _storageService.readSecureData('token');

      if (accessToken!.length > 0) {
        var url = Uri(
          scheme: config.protocol,
          host: config.hostname,
          path: 'betting-api-gateway/user/rest/statistics/ticket',
          queryParameters: getParams,
        );

        await http.get(url, headers: {
          "content-type": "application/json",
          "Authorization": accessToken
        }).then((response) {
          var result = jsonDecode(response.body);

          setState(() {
            ticket = result['response'];
          });
        });
      }
    }
  }

  handleTicketType(type) {
    switch (type) {
      case 'sjp':
        return 'Jackpot';
      case 'sjc':
        return 'Jackpot Combi';
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

  findSplitOutcome(match, matchArr) {
    Map splitMatch = matchArr.firstWhere(
        (e) =>
            e['svrOddID'] != match['svrOddID'] &&
            e['tipDetailsWS']['matchORMID'] ==
                match['tipDetailsWS']['matchORMID'],
        orElse: () => {});

    if (splitMatch.isNotEmpty) {
      return 'or ${splitMatch['tipDetailsWS']['tip']}';
    }

    return "";
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => fetchTickets());
  }

  Widget getMatches(List<dynamic> strings) {
    List filteredArr = [...strings];
    return new Wrap(
        children: filteredArr
            .unique((e) => e['tipDetailsWS']['matchORMID'])
            .map((item) => new Card(
                margin:
                    EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 5),
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
                                          text:
                                              '${item['tipDetailsWS']['tip']} ${findSplitOutcome(item, strings)}',
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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = "MM/dd/yyyy', 'h:mma";
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
                actions: <Widget>[LoginAction()],
              ),
              body: ticket['bets'] != null
                  ? ListView(
                      children: [
                        Card(
                            margin:
                                EdgeInsets.only(left: 15, top: 15, right: 15),
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
                                        ticket['code'],
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
                                        ticket['ticketNbr'],
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
                                                ticket['acceptedTime'])),
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
                                        ticket['paid']
                                            ? DateFormat(timeFormat).format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        ticket['paidTime']))
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
                                        ticket['stake'].toString(),
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
                                        ticket['bets']['betWS'][0]['maxWin']
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                    ))
                                  ]),
                                  Row(children: [
                                    config.stakeTaxEnabled &&
                                            ticket['stakeTax'] != null
                                        ? Expanded(
                                            child: ListTile(
                                            title: Text(
                                              "${config.stakeTaxName}(-${config.stakeTaxPercent}%)",
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .subtitle1,
                                            ),
                                            subtitle: Text(
                                              ticket['stakeTax'].toString(),
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.white),
                                            ),
                                          ))
                                        : SizedBox(),
                                    config.profitTaxEnabled &&
                                            ticket['profitTax'] != null
                                        ? Expanded(
                                            child: ListTile(
                                            title: Text(
                                                "${config.profitTaxName}(-${config.profitTaxPercent}%)",
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .subtitle1),
                                            subtitle: Text(
                                              ticket['profitTax'].toString(),
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
                                      widget.category,
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                    ),
                                  )
                                ])),
                        Card(
                            margin: EdgeInsets.only(
                                left: 15, top: 5, right: 15, bottom: 15),
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
                                        handleTicketType(ticket['bets']['betWS']
                                            [0]['betType']),
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                    )),
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
                                        ticket['bets']['betWS'][0]['rows']
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
                                        ticket['payAmount'].toString(),
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white),
                                      ),
                                    )),
                                  ]),
                                ])),
                        getMatches(
                            ticket['bets']['betWS'][0]['bankTips']['tipWS']),
                        getMatches(ticket['bets']['betWS'][0]['tips2BetMulti']
                            ['tipWS'])
                      ],
                    )
                  : Center(child: CircularProgressIndicator()));
        });
  }
}
