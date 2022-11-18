import 'package:flutter/material.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class MyBetsListItemSettled extends StatefulWidget {
  final ticketData;
  const MyBetsListItemSettled({Key? key, this.ticketData}) : super(key: key);

  @override
  State<MyBetsListItemSettled> createState() => _MyBetsListItemSettledState();
}

class _MyBetsListItemSettledState extends State<MyBetsListItemSettled> {
  bool widgetOpacity = false;

  @override
  void didUpdateWidget(MyBetsListItemSettled oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget drawStatusIcon(int status, bool won, int stat) {
    if (status == 6 && won) return Icon(Icons.done, color: Colors.green);
    if (status == 6 && !won && stat == 2)
      return Icon(Icons.close, color: Colors.red);
    if (status == 8 || status == 9)
      return Icon(Icons.cached, color: Colors.black);
    return SizedBox();
  }

  Widget drawFooter(int status, bool won, var cashedOut) {
    if (status == 5 && won)
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
    if (status == 5 && !won)
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
    if (status == 7)
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
                  text: '${LocaleKeys.cashedOut.tr()}: ',
                  style: Theme.of(context).primaryTextTheme.subtitle1,
                ),
                TextSpan(text: cashedOut.toString()),
              ],
            ),
          ));
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
                                      child: drawStatusIcon(e['marketStatus'],
                                          e['won'], e['status']),
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
                                      child: drawStatusIcon(e['marketStatus'],
                                          e['won'], e['status']),
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
                  drawFooter(
                      widget.ticketData['ticketStatus'],
                      widget.ticketData['won'],
                      widget.ticketData['cashoutAmount'])
                ],
              )),
        ));
  }
}
