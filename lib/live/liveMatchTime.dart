import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_countdown_timer/index.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class LiveMatchTime extends StatelessWidget {
  LiveMatchTime(
      this.matchStatus,
      this.startDate,
      this.eventTime,
      this.liveBetStatus,
      this.liveMetaStatus,
      this.statusEnded,
      this.stoppageTime,
      this.stoppageTimeAnnounced);
  final matchStatus;
  final startDate;
  final eventTime;
  final liveBetStatus;
  final liveMetaStatus;
  final statusEnded;
  final stoppageTime;
  final stoppageTimeAnnounced;

  List liveMetaStatusList = [
    30,
    31,
    33,
    81,
    524,
    301,
    302,
    303,
    304,
    305,
    306,
    421,
    422,
    423,
    424,
    425,
    426,
    427,
    428,
    429,
    430,
    431,
    432,
    433,
    434,
    435,
    436,
    437,
    438,
    439
  ];

  var statusColor = Color(0xFF008000);
  var statusColorSecond = Color(0xFF70AD3A);
  @override
  Widget build(BuildContext context) {
    if ([15].contains(liveBetStatus) && statusEnded == false)
      statusColor = Color(0xFF008000);
    statusColorSecond = Color(0xFF70AD3A);
    if ([15].contains(liveBetStatus) &&
        liveMetaStatusList.contains(liveMetaStatus) &&
        statusEnded == false) {
      statusColor = Color(0xFFF5E13E);
      statusColorSecond = Color(0xFF605900);
    } else if ([16, 18].contains(liveBetStatus) && statusEnded == false) {
      statusColor = Color(0xFF808080);
      statusColorSecond = Color(0xFF7C807D);
    } else if ([17, 8].contains(liveBetStatus) || statusEnded == true) {
      statusColor = Color(0xFF0000FF);
      statusColorSecond = Color(0xFF1350DE);
    } else if ([4, 20].contains(liveBetStatus) && statusEnded == false) {
      statusColor = Color(0xFFFF0000);
      statusColorSecond = Color(0xFFC30E05);
    }
    return Container(
      height: 30,
      padding: EdgeInsets.all(8.0),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              statusColor,
              statusColorSecond,
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CountdownTimer(
            endTime: startDate,
            widgetBuilder: (BuildContext context, CurrentRemainingTime? time) {
              if (time == null) {
                return Text((eventTime != null
                        ? eventTime.split(':')[0] +
                            (stoppageTime != "" && stoppageTime[0] != "0" ? "+${stoppageTime[0].split(":")[0]}'" : "") +
                            (stoppageTimeAnnounced != "" && stoppageTimeAnnounced[0] != "0" 
                                ? " EXTRA ${stoppageTimeAnnounced.split(":")[0]}'"
                                : "") +
                            " ${LocaleKeys.min.tr()}"
                        : " ") +
                    " " +
                    (matchStatus != null ? matchStatus : ""));
              }
              return Text(
                  '${LocaleKeys.startsIn.tr()} ${time.min! < 10 ? 0 : ''}${time.min}:${time.sec! < 10 ? 0 : ''}${time.sec}');
            },
          ),
        ],
      ),
    );
  }
}
