import 'package:flutter/material.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/defaultConfig.dart' as config;
import '../models/storage_item.dart';
import '../services/storage_service.dart';

class MyBetsListItem extends StatefulWidget {
  final ticketData;
  const MyBetsListItem({Key? key, this.ticketData}) : super(key: key);

  @override
  State<MyBetsListItem> createState() => _MyBetsListItemState();
}

class _MyBetsListItemState extends State<MyBetsListItem> {
  final StorageService _storageService = StorageService();
  bool widgetOpacity = false;
  bool buttonLoader = false;
  String updateClass = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var cashOutRemember = '';

  _MyBetsListItemState() {
    _storageService
        .readSecureData('cashOutRemember')
        .then((val) => setState(() {
              cashOutRemember = val!;
            }));
  }

  @override
  void didUpdateWidget(MyBetsListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ticketData['cashoutAmount'] >
        oldWidget.ticketData['cashoutAmount']) {
      updateClass = 'odd-up';
    }

    if (widget.ticketData['cashoutAmount'] <
        oldWidget.ticketData['cashoutAmount']) {
      updateClass = 'odd-down';
    }

    Future.delayed(const Duration(milliseconds: 10000), () {
      updateClass = '';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleCashoutClick() async {
    setState(() {
      buttonLoader = true;
    });
    String? accessToken = await _storageService.readSecureData('token');
    var url = (Uri.parse(
        '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/ticketCashout/requestTicketCashout/'));

    Map data = {
      'TicketNumber': widget.ticketData['ticketNbr'],
      "CashoutAmount": widget.ticketData['cashoutAmount'],
      'TicketStatus': widget.ticketData['TicketStatus'],
      'serverTime': widget.ticketData['serverTime'],
    };
    var body = json.encode(data);

    await http
        .post(url,
            headers: {
              "content-type": "application/json",
              'credentials': 'include',
              "authorization": accessToken!,
            },
            body: body)
        .then((response) {
      if (response.statusCode == 200) {
        debugPrint('Cashed out');
        _storageService
        .readSecureData('cashOutRemember')
        .then((val) => setState(() {
              cashOutRemember = val!;
            }));
      } else {
        throw "Data error";
      }
    });
  }

  Widget drawStatusIcon(int status, bool won) {
    if (status == 6 && won) return Icon(Icons.done, color: Colors.green);
    if (status == 6 && !won) return Icon(Icons.close, color: Colors.red);
    if (status == 8 || status == 9)
      return Icon(Icons.cached, color: Colors.yellow);
    return SizedBox();
  }

  Widget drawFooter(ticketData) {
    /*Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }*/

    if (ticketData['ticketStatus'] == 5 && ticketData['won'])
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Staus: ',
                  style: Theme.of(context).primaryTextTheme.subtitle1,
                ),
                TextSpan(
                  text: LocaleKeys.won.tr(),
                ),
              ],
            ),
          ));
    if (ticketData['ticketStatus'] == 5 && !ticketData['won'])
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Staus: ',
                  style: Theme.of(context).primaryTextTheme.subtitle1,
                ),
                TextSpan(
                  text: LocaleKeys.lost.tr(),
                ),
              ],
            ),
          ));
    if (ticketData['ticketStatus'] == 7)
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Cashed out: ',
                  style: Theme.of(context).primaryTextTheme.subtitle1,
                ),
                TextSpan(text: ticketData['cashedOut'].toString()),
              ],
            ),
          ));

    if (ticketData['ticketStatus'] == 10)
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: LocaleKeys.cashoutApproved.tr(),
                ),
              ],
            ),
          ));
    if (ticketData['ticketStatus'] == 9)
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: LocaleKeys.cashoutRejected.tr(),
                ),
                TextSpan(
                  text:
                      '${LocaleKeys.cashoutErrorCode.tr()}: ${ticketData['lastTicketCashoutLogCode'].toString()}',
                ),
              ],
            ),
          ));

    if (ticketData['ticketStatus'] == 4)
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: LocaleKeys.cashoutProcessing.tr(),
                ),
              ],
            ),
          ));

    if (ticketData['ticketStatus'] == 6)
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: LocaleKeys.cashoutRechecking.tr(),
                ),
              ],
            ),
          ));

    if (ticketData['ticketStatus'] == 0 && buttonLoader)
      return Container(
          padding: const EdgeInsets.all(10.0),
          child: CircularProgressIndicator());

    if (ticketData['ticketStatus'] != 2)
      return Container(
          padding: const EdgeInsets.all(15.0),
          child: Opacity(
              opacity: ticketData['ticketStatus'] != 0 ? 0.4 : 1,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: ticketData['ticketStatus'] != 0
                            ? Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Icon(Icons.lock),
                              )
                            : SizedBox(),
                      ),
                      WidgetSpan(
                          child: Stack(
                        alignment: Alignment.center,
                        //textDirection: TextDirection.rtl,
                        fit: StackFit.loose,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            child: Icon(
                                updateClass == "odd-up"
                                    ? Icons.arrow_drop_up
                                    : updateClass == "odd-down"
                                        ? Icons.arrow_drop_down
                                        : null,
                                size: 25,
                                color: updateClass == "odd-down"
                                    ? Colors.red
                                    : Colors.green),
                            right: -25,
                            top: -5.0,
                          ),
                          Text(
                              '${LocaleKeys.cashoutAmount.tr()}: ${ticketData['cashoutAmount']}',
                              style: TextStyle(color: Colors.white)),
                        ],
                      )),
                    ],
                  ),
                ),
                onPressed: ticketData['ticketStatus'] != 0
                    ? null
                    : cashOutRemember == 'true'
                        ? () {
                            handleCashoutClick();
                          }
                        : () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  bool isChecked = false;
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                    return AlertDialog(
                                      content: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Text(
                                                      LocaleKeys.aboutToCashout
                                                          .tr(args: [
                                                        ticketData[
                                                                'cashoutAmount']
                                                            .toString()
                                                      ]),
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ))),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(LocaleKeys.rememberChoice
                                                      .tr()),
                                                  Checkbox(
                                                      value: isChecked,
                                                      onChanged: (checked) {
                                                        setState(() {
                                                          isChecked = checked!;
                                                        });
                                                      })
                                                ],
                                              )
                                            ],
                                          )),
                                      title: Text(LocaleKeys.cashout.tr()),
                                      actions: <Widget>[
                                        InkWell(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Text(LocaleKeys.yes.tr())),
                                          onTap: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _storageService.writeSecureData(
                                                  StorageItem('cashOutRemember',
                                                      'true'));
                                              handleCashoutClick();
                                              Navigator.of(context).pop();
                                            }
                                          },
                                        ),
                                        InkWell(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Text(
                                                  '${LocaleKeys.no.tr()}')),
                                          onTap: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // Do something like updating SharedPreferences or User Settings etc.
                                              Navigator.of(context).pop();
                                            }
                                          },
                                        )
                                      ],
                                    );
                                  });
                                });
                          },
              )));
    return SizedBox();
  }

  Widget drawFirstTwoTips(List<dynamic> tipsData) {
    return new Wrap(
        children: tipsData
            .map((e) => new Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.all(10.0),
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                    children: [
                                      TextSpan(
                                        text: '${e['betdomainName']} - ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: e['oddName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ))),
                        Expanded(
                            child: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.all(10.0),
                                child: Text(e['odd'].toString(),
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)))),
                      ],
                    ),
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        child: (e['sourceType'] != 20 &&
                                e['sourceType'] != 21 &&
                                !e['isOutrightType'])
                            ? RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white),
                                  children: [
                                    WidgetSpan(
                                      child: drawStatusIcon(
                                          e['marketStatus'], e['won']),
                                    ),
                                    TextSpan(
                                      text: '${e['homeCompetitorName']} - ',
                                    ),
                                    TextSpan(
                                      text: e['awayCompetitorName'],
                                    ),
                                  ],
                                ),
                              )
                            : RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white),
                                  children: [
                                    WidgetSpan(
                                      child: drawStatusIcon(
                                          e['marketStatus'], e['won']),
                                    ),
                                    TextSpan(
                                      text: '${e['oddName']}',
                                    ),
                                  ],
                                ),
                              )),
                    Divider(
                        height: 1,
                        thickness: 2,
                        color: Colors.grey.withOpacity(0.2),
                        indent: 20,
                        endIndent: 20),
                  ],
                )))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: widgetOpacity ? 0.6 : 1,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 10,
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: widget.ticketData['tips'].length > 1
                                  ? Text(
                                      '${LocaleKeys.multiple.tr()}${widget.ticketData['tips'].length}',
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white))
                                  : Text(LocaleKeys.single.tr(),
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.white)))),
                      Expanded(
                          child: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.all(10.0),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white),
                                  children: [
                                    TextSpan(
                                      text: '${LocaleKeys.stake.tr()}: ',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .subtitle1,
                                    ),
                                    TextSpan(
                                      text:
                                          widget.ticketData['stake'].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )))
                    ],
                  )),
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              children: [
                                TextSpan(
                                  text: '${LocaleKeys.odds.tr()}: ',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .subtitle1,
                                ),
                                TextSpan(
                                  text: widget.ticketData['odds']
                                      .toStringAsFixed(2),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              children: [
                                TextSpan(
                                  text: '${LocaleKeys.possibleWinning.tr()}: ',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .subtitle1,
                                ),
                                TextSpan(
                                  text: widget.ticketData['possibleWinning']
                                      .toStringAsFixed(2),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.grey,
                      indent: 20,
                      endIndent: 20),
                  drawFirstTwoTips(widget.ticketData['tips'].length > 2
                      ? widget.ticketData['tips'].sublist(0, 2)
                      : widget.ticketData['tips']),
                  widget.ticketData['tips'].length > 2
                      ? ExpansionTile(
                          title: Text(LocaleKeys.moreTips.tr()),
                          children: [
                              drawFirstTwoTips(
                                  widget.ticketData['tips'].sublist(2))
                            ])
                      : SizedBox(),
                  drawFooter(widget.ticketData)
                ],
              )),
        ));
  }
}
