import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'myBetsModal.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/defaultConfig.dart' as config;

class MyBetsCard extends StatelessWidget {
  const MyBetsCard({
    Key? key,
    this.ticketData,
  }) : super(key: key);

  final ticketData;

  statusColor(String type) {
    switch (type.toLowerCase()) {
      case 'open':
        return Color(0xFFFFFFFF);

      case 'cancelled':
        return Color(0xFF444444);

      case 'pending':
        return Color(0xFFFFDB4D);

      case 'lost':
        return Color(0xFFCC181E);

      case 'won':
        return Color(0xFF42D916);

      case 'cashedout':
        return Color(0xFF375DFF);

      default:
        return Color(0xFFFFFFFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeFormat = "";
    if (config.timeFormat[context.locale.toString()] == 0) {
      timeFormat = "MM/dd/yyyy', 'h:mma";
    } else {
      timeFormat = "MM/dd/yyyy', 'HH:mm:ss";
    }
    return Container(
        margin: const EdgeInsets.all(8.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyBetsModal(
                          number: ticketData['ticketNumber'],
                          code: ticketData['checkSum'],
                          category: ticketData['ticketCategory'],
                        )),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      child: ListTile(
                    title: Text(
                      LocaleKeys.ticketNumber.tr(),
                      style: Theme.of(context).primaryTextTheme.subtitle1,
                    ),
                    subtitle: Text(
                      ticketData['ticketNumber'],
                      style: TextStyle(fontSize: 15.0, color: Colors.white),
                    ),
                  )),
                  Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.grey,
                      indent: 20,
                      endIndent: 20),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                            child: ListTile(
                          title: Text(
                            LocaleKeys.games.tr(),
                            style: Theme.of(context).primaryTextTheme.subtitle1,
                          ),
                          subtitle: Text(
                            DateFormat(timeFormat).format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    ticketData['createdAt'])),
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.white),
                          ),
                        ))),
                    Expanded(
                        flex: 1,
                        child: Container(
                            child: ListTile(
                          title: Text(
                            LocaleKeys.stake.tr(),
                            style: Theme.of(context).primaryTextTheme.subtitle1,
                          ),
                          subtitle: Text(
                            ticketData['totalStake'].toString(),
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.white),
                          ),
                        ))),
                  ]),
                  Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.grey,
                      indent: 20,
                      endIndent: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Text(
                          ticketData['ticketCategory'],
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.end,
                                children: [
                                  Text(
                                    LocaleKeys.details.tr(),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.grey),
                                  ),
                                  Icon(Icons.arrow_forward,
                                      color: Colors.grey, size: 20),
                                ],
                              )))
                    ],
                  ),
                  Divider(
                    height: 1,
                    thickness: 4,
                    color: statusColor(ticketData['ticketCategory']),
                  ),
                ],
              ),
            )));
  }
}
