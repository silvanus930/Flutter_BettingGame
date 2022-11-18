import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/defaultConfig.dart' as config;
import '../../services/storage_service.dart';

class MyBonusItemProfile extends StatefulWidget {
  final bonusData;
  final activeBonus;

  const MyBonusItemProfile({Key? key, this.bonusData, this.activeBonus})
      : super(key: key);
  @override
  State<MyBonusItemProfile> createState() => MyBonusItemProfileState();
}

class MyBonusItemProfileState extends State<MyBonusItemProfile> {
  bool showMore = false;
  Map bonusLimits = {};
  String timeFormat = "";

  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getBonusConditions() async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/ticket/load-abc-byid'));
      try {
        Map data = {'abcId': widget.bonusData['accountBonusCampaignId']};
        var body = json.encode(data);
        await http
            .post(url,
                headers: {
                  "content-type": "application/json",
                  "Authorization": accessToken,
                },
                body: body)
            .then((response) {
          var result = jsonDecode(response.body);
          if (response.statusCode == 200 && result['response'].isNotEmpty) {
            setState(() {
              bonusLimits = result['response'];
            });
          }
        });
      } on Exception catch (_) {
        debugPrint('Could not get bonus limits');
      }
    }
  }

  getMoreBonusText() {
    if (widget.bonusData['type'] == 'First deposit') {
      return widget.bonusData['blocked'] && widget.bonusData['unblockBypass']
          ? Text(LocaleKeys.Bonus_More_Blocked_FirstDeposit.tr(args: [
              widget.bonusData['totalRolloverAmountToUnblock'] != null
                  ? widget.bonusData['totalRolloverAmountToUnblock']
                  : ""
            ]))
          : widget.bonusData['blocked'] && !widget.bonusData['unblockBypass']
              ? Text(LocaleKeys.Bonus_More_ToUnblock_FirstDeposit.tr(args: [
                  widget.bonusData['totalRolloverAmountToUnblock'].toString(),
                  bonusLimits['minOdds'] != null
                      ? bonusLimits['minOdds'].toString()
                      : "",
                  bonusLimits['minTotalOdds'] != null
                      ? bonusLimits['minTotalOdds'].toString()
                      : "",
                  bonusLimits['minTipps'] != null
                      ? bonusLimits['minTipps'].toString()
                      : ""
                ]))
              : !widget.bonusData['blocked']
                  ? Text(
                      LocaleKeys.Bonus_More_Conditions_FirstDeposit.tr(args: [
                      widget.bonusData['name'] != null
                          ? widget.bonusData['name']
                          : "",
                      bonusLimits['minOdds'] != null
                          ? bonusLimits['minOdds'].toString()
                          : "",
                      bonusLimits['minTotalOdds'] != null
                          ? bonusLimits['minTotalOdds'].toString()
                          : "",
                      bonusLimits['minTipps'] != null
                          ? bonusLimits['minTipps'].toString()
                          : ""
                    ]))
                  : Text("");
    }

    if (widget.bonusData['type'] == 'Regular') {
      return Text(LocaleKeys.Bonus_More_Conditions_Regular.tr(args: [
        widget.bonusData['name'] != null ? widget.bonusData['name'] : "",
        bonusLimits['minOdds'] != null ? bonusLimits['minOdds'].toString() : "",
        bonusLimits['minTotalOdds'] != null
            ? bonusLimits['minTotalOdds'].toString()
            : "",
        bonusLimits['minTipps'] != null
            ? bonusLimits['minTipps'].toString()
            : ""
      ]));
    }

    if (widget.bonusData['type'] == 'TournamentFreebet') {
      return Text(LocaleKeys.Bonus_More_Conditions_Freebet.tr(args: [
        widget.bonusData['availableAmount'] != null
            ? widget.bonusData['availableAmount'].toString()
            : "",
        widget.bonusData['name'] != null ? widget.bonusData['name'] : "",
        bonusLimits['minOdds'] != null ? bonusLimits['minOdds'].toString() : "",
        bonusLimits['minTotalOdds'] != null
            ? bonusLimits['minTotalOdds'].toString()
            : "",
        bonusLimits['minTipps'] != null
            ? bonusLimits['minTipps'].toString()
            : ""
      ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (config.timeFormat[context.locale.toString()] == 0) {
      timeFormat = "MM/dd', 'h:mma";
    } else {
      timeFormat = "MM/dd', 'HH:mm:ss";
    }
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.green,
              width: widget.activeBonus.isNotEmpty &&
                      widget.activeBonus['accountBonusCampaignId'] ==
                          widget.bonusData['accountBonusCampaignId']
                  ? 3
                  : 0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                decoration: new BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 1.0,
                          offset: Offset(0.0, 0.75))
                    ],
                    color: Theme.of(context).indicatorColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: ListTile(
                  leading: Icon(Icons.paid, size: 30.0, color: Colors.black87),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.bonusData['name'],
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                        widget.bonusData['blocked']
                            ? Icon(Icons.lock,
                                size: 25.0, color: Colors.black87)
                            : SizedBox()
                      ]),
                )),
            Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                child: Text(
                    '${LocaleKeys.expires.tr()}: ${DateFormat(timeFormat).format(DateTime.fromMillisecondsSinceEpoch(widget.bonusData['activeTill']))}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    textAlign: TextAlign.end)),
            Container(
                padding:
                    const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
                child: ListTile(
                    title: Text(
                      '${LocaleKeys.bonusAmount.tr()}: ${widget.bonusData['availableAmount']}',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: widget.bonusData['type'] == 'First deposit'
                          ? Text(
                              widget.bonusData['blocked'] &&
                                      widget.bonusData['forced'] &&
                                      widget.bonusData['unblockBypass']
                                  ? '${LocaleKeys.placeToUnblockBonus.tr()} ${widget.bonusData['name']}'
                                  : widget.bonusData['blocked'] &&
                                          widget.bonusData['unblockBypass']
                                      ? LocaleKeys.placeBonusAmount.tr(args: [
                                          widget.bonusData[
                                              'totalRolloverAmountToUnblock'].toString()
                                        ])
                                      : widget.bonusData['blocked'] &&
                                              !widget.bonusData['unblockBypass']
                                          ? LocaleKeys
                                              .placeBonusAmountQualifying
                                              .tr(args: [
                                              widget.bonusData[
                                                  'totalRolloverAmountToUnblock'].toString()
                                            ])
                                          : !widget.bonusData['blocked']
                                              ? LocaleKeys
                                                  .placeBonusAmountConvert
                                                  .tr(args: [
                                                  widget.bonusData[
                                                      'rolloveredAmount'].toString()
                                                ])
                                              : "",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            )
                          : widget.bonusData['type'] == 'Regular'
                              ? Text(
                                  widget.bonusData['separateUsage']
                                      ? LocaleKeys.useBonusToBetConditions
                                          .tr(args: [widget.bonusData['name']])
                                      : LocaleKeys.useBonusToBet
                                          .tr(args: [widget.bonusData['name']]),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                )
                              : widget.bonusData['type'] == 'TournamentFreebet'
                                  ? Text(
                                      LocaleKeys.selectPlaceBonus
                                          .tr(args: [widget.bonusData['name']]),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    )
                                  : SizedBox(),
                    ))),
            AnimatedSize(
                duration: Duration(milliseconds: 200),
                child: DefaultTextStyle(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 15.0, bottom: 15.0, right: 15.0),
                      height: showMore && bonusLimits.isNotEmpty ? null : 0.0,
                      child: getMoreBonusText(),
                    ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const SizedBox(width: 8),
                TextButton(
                  child: Text(showMore && bonusLimits.isNotEmpty
                      ? LocaleKeys.less.tr().toUpperCase()
                      : LocaleKeys.more.tr().toUpperCase()),
                  onPressed: () {
                    if (!showMore && bonusLimits.isEmpty) {
                      getBonusConditions();
                    }
                    setState(() {
                      showMore = !showMore;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ));
  }
}
