import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class MatchDetailsHeader extends StatelessWidget {
  MatchDetailsHeader(this.matchData, this.metaData, this.collapsed);
  final matchData;
  final metaData;
  final collapsed;

  Widget getScore() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 1,
                    offset: Offset(1, 1), // Shadow position
                  ),
                ],
              ),
              child: Text(
                '${metaData['homeScore'].toString()}',
                style: TextStyle(color: Colors.black, fontSize: 20),
              )),
          Text(':', style: TextStyle(color: Colors.white, fontSize: 30)),
          Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 1,
                    offset: Offset(1, 1), // Shadow position
                  ),
                ],
              ),
              child: Text(
                metaData['awayScore'].toString(),
                style: TextStyle(color: Colors.black, fontSize: 20),
              ))
        ]);
  }

  Widget _showTennisTable() {
    metaData['periods']
        .sort((a, b) => a["periodNumber"].compareTo(b["periodNumber"]) as int);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DataTable(
          dataTextStyle: TextStyle(color: Colors.white),
          headingTextStyle: TextStyle(color: Colors.white),
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Color(0xFF333549).withOpacity(0.6)),
          dataRowColor: MaterialStateColor.resolveWith(
              (states) => Color(0xFF333549).withOpacity(0.3)),
          columnSpacing: 5.0,
          dataRowHeight: 30,
          headingRowHeight: 20,
          columns: <DataColumn>[
            DataColumn(
              label: Center(
                  child: Text(
                LocaleKeys.matchStats.tr(),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            DataColumn(
              label: Center(
                  child: Text(
                LocaleKeys.server.tr(),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            DataColumn(
              label: Center(
                  child: Text(
                LocaleKeys.tennisGS.tr(),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            for (var item in metaData['periods'])
              DataColumn(
                label: Center(
                    child: Text('${item['description']}',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12),
                        textAlign: TextAlign.center)),
              )
          ],
          rows: <DataRow>[
            DataRow(cells: [
              DataCell(Text(
                  matchData['matchtocompetitors'][0]['competitor']
                      ['defaultName'],
                  style: TextStyle(fontSize: 12))),
              DataCell(
                metaData['currentServer'] == 0
                    ? Icon(Icons.sports_baseball, size: 15)
                    : Text(''),
              ),
              DataCell(
                Text(metaData['homeGamescore'].toString(),
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center),
              ),
              for (var item in metaData['periods'])
                DataCell(
                  Text('${item['homeScore']}',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                )
            ]),
            DataRow(cells: [
              DataCell(
                Text(
                    matchData['matchtocompetitors'][1]['competitor']
                        ['defaultName'],
                    style: TextStyle(fontSize: 12)),
              ),
              DataCell(metaData['currentServer'] != 0
                  ? Icon(Icons.sports_baseball, size: 15, color: Colors.white)
                  : Text('')),
              DataCell(
                Text(metaData['awayGamescore'].toString(),
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center),
              ),
              for (var item in metaData['periods'])
                DataCell(
                  Text('${item['awayScore']}',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                )
            ])
          ])
    ]);
  }

  Widget _showSoccerTable() {
    metaData['periods']
        .sort((a, b) => a["periodNumber"].compareTo(b["periodNumber"]) as int);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DataTable(
          dataTextStyle: TextStyle(color: Colors.white),
          headingTextStyle: TextStyle(color: Colors.white),
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Color(0xFF333549).withOpacity(0.6)),
          dataRowColor: MaterialStateColor.resolveWith(
              (states) => Color(0xFF333549).withOpacity(0.3)),
          columnSpacing: 1.0,
          dataRowHeight: 30,
          headingRowHeight: 20,
          columns: <DataColumn>[
            DataColumn(
              label: Center(
                  child: Text(
                LocaleKeys.matchStats.tr(),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            DataColumn(
              label: Center(
                  child: SizedBox(
                width: 8.0,
                height: 12.0,
                child: const DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.red),
                ),
              )),
            ),
            DataColumn(
              label: Center(
                  child: SizedBox(
                width: 8.0,
                height: 12.0,
                child: const DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.yellow),
                ),
              )),
            ),
            DataColumn(
              label: Center(
                  child: Icon(Icons.rounded_corner,
                      size: 15, color: Colors.white)),
            ),
            for (var item in metaData['periods'])
              DataColumn(
                label: Center(
                    child: Text('${item['description']}',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12),
                        textAlign: TextAlign.center)),
              )
          ],
          rows: <DataRow>[
            DataRow(cells: [
              DataCell(Container(
                  width: 80,
                  child: Text(
                      matchData['matchtocompetitors'][0]['competitor']
                          ['defaultName'],
                      style: TextStyle(fontSize: 10)))),
              DataCell(
                Text(metaData['competitors'][0]['redCards'].toString(),
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center),
              ),
              DataCell(Text(
                  metaData['competitors'][0]['yellowCards'].toString(),
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center)),
              DataCell(Text(
                  metaData['competitors'][0]['cornerKicks'].toString(),
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center)),
              for (var item in metaData['periods'])
                DataCell(
                  Text('${item['homeScore']}',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                )
            ]),
            DataRow(cells: [
              DataCell(
                Container(
                    width: 80,
                    child: Text(
                        matchData['matchtocompetitors'][1]['competitor']
                            ['defaultName'],
                        style: TextStyle(fontSize: 10))),
              ),
              DataCell(
                Text(metaData['competitors'][1]['redCards'].toString(),
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center),
              ),
              DataCell(Text(
                  metaData['competitors'][1]['yellowCards'].toString(),
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center)),
              DataCell(Text(
                  metaData['competitors'][1]['cornerKicks'].toString(),
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center)),
              for (var item in metaData['periods'])
                DataCell(
                  Text('${item['awayScore']}',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                )
            ])
          ])
    ]);
  }

  Widget _showBasketBallTable() {
    metaData['periods']
        .sort((a, b) => a["periodNumber"].compareTo(b["periodNumber"]) as int);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DataTable(
          dataTextStyle: TextStyle(color: Colors.white),
          headingTextStyle: TextStyle(color: Colors.white),
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Color(0xFF333549).withOpacity(0.6)),
          dataRowColor: MaterialStateColor.resolveWith(
              (states) => Color(0xFF333549).withOpacity(0.3)),
          columnSpacing: 5.0,
          dataRowHeight: 30,
          headingRowHeight: 20,
          columns: <DataColumn>[
            DataColumn(
              label: Center(
                  child: Text(
                LocaleKeys.matchStats.tr(),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )),
            ),
            for (var item in metaData['periods'])
              DataColumn(
                label: Center(
                    child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${item['description'][0]}st ",
                      ),
                      WidgetSpan(
                        child: Icon(Icons.timer, size: 15, color: Colors.white),
                      ),
                    ],
                  ),
                )),
              )
          ],
          rows: <DataRow>[
            DataRow(cells: [
              DataCell(Text(
                  matchData['matchtocompetitors'][0]['competitor']
                      ['defaultName'],
                  style: TextStyle(fontSize: 12))),
              for (var item in metaData['periods'])
                DataCell(
                  Text('${item['homeScore']}',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                )
            ]),
            DataRow(cells: [
              DataCell(
                Text(
                    matchData['matchtocompetitors'][1]['competitor']
                        ['defaultName'],
                    style: TextStyle(fontSize: 12)),
              ),
              for (var item in metaData['periods'])
                DataCell(
                  Text('${item['awayScore']}',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                )
            ])
          ])
    ]);
  }

  getTable(id) {
    switch (id) {
      case 1:
        return _showSoccerTable();
      case 2:
        return _showBasketBallTable();
      case 5:
        return _showTennisTable();
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (matchData != null) {
      matchData['matchtocompetitors']
          .sort((a, b) => a["homeTeam"].compareTo(b["homeTeam"]) as int);
    }
    return SingleChildScrollView(
        child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF0D5611),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
            ),
            margin: EdgeInsets.only(bottom: 5.0),
            child: Column(
              children: [
                AnimatedClipRect(
                    open: !collapsed,
                    horizontalAnimation: false,
                    verticalAnimation: true,
                    alignment: Alignment.center,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    reverseCurve: Curves.easeIn,
                    child: Container(
                        child: matchData['venue'] != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  matchData['venue']['country']
                                              ['defaultName'] !=
                                          null
                                      ? Text(
                                          '${matchData['venue']['country']['defaultName']}, ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                              fontSize: 13))
                                      : SizedBox(),
                                  Text(
                                      matchData['venue']['city'] != null
                                          ? matchData['venue']['city']
                                          : '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white54,
                                          fontSize: 13))
                                ],
                              )
                            : SizedBox())),
                SizedBox(height: 10),
                AnimatedClipRect(
                    open: !collapsed,
                    horizontalAnimation: false,
                    verticalAnimation: true,
                    alignment: Alignment.center,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    reverseCurve: Curves.easeIn,
                    child: Container(
                        child: matchData['venue'] != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(matchData['tournamentName'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white54,
                                          fontSize: 13))
                                ],
                              )
                            : SizedBox())),
                metaData == null ? SizedBox(height: 10) : SizedBox(),
                AnimatedClipRect(
                    open: !collapsed,
                    horizontalAnimation: false,
                    verticalAnimation: true,
                    alignment: Alignment.center,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    reverseCurve: Curves.easeIn,
                    child: Container(
                        child: metaData == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      DateFormat('MMMMd')
                                          .format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  matchData['startDate']))
                                          .toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white54,
                                          fontSize: 13))
                                ],
                              )
                            : SizedBox())),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                        child: Text(
                            '${matchData['matchtocompetitors'][0]['competitor']['defaultName']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15),
                            textAlign: TextAlign.center)),
                  ],
                ),
                metaData == null ? SizedBox() : getScore(),
                Text(
                    matchData['matchtocompetitors'][1]['competitor']
                        ['defaultName'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15),
                    textAlign: TextAlign.center),
                SizedBox(height: 10),
                metaData == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              child: Text(
                            DateFormat('Hm')
                                .format(DateTime.fromMillisecondsSinceEpoch(
                                    matchData['startDate']))
                                .toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20),
                          ))
                        ],
                      )
                    : SizedBox(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      metaData != null
                          ? Text(metaData['matchStatus'] != null
                              ? metaData['matchStatus']
                              : '')
                          : SizedBox(),
                      SizedBox(width: 5),
                      metaData != null
                          ? Text(metaData['eventTime'] != null
                              ? "${metaData['eventTime']} MIN"
                              : '')
                          : SizedBox()
                    ]),
                SizedBox(height: 5),
                AnimatedClipRect(
                    open: !collapsed,
                    horizontalAnimation: false,
                    verticalAnimation: true,
                    alignment: Alignment.center,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    reverseCurve: Curves.easeIn,
                    child: Container(
                        child: metaData != null
                            ? getTable(matchData['sport']['sportId'])
                            : SizedBox()))
              ],
            )));
  }
}

class AnimatedClipRect extends StatefulWidget {
  @override
  _AnimatedClipRectState createState() => _AnimatedClipRectState();

  final Widget child;
  final bool open;
  final bool horizontalAnimation;
  final bool verticalAnimation;
  final Alignment alignment;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve? reverseCurve;

  ///The behavior of the controller when [AccessibilityFeatures.disableAnimations] is true.
  final AnimationBehavior animationBehavior;

  const AnimatedClipRect({
    Key? key,
    required this.child,
    required this.open,
    this.horizontalAnimation = true,
    this.verticalAnimation = true,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.animationBehavior = AnimationBehavior.normal,
  }) : super(key: key);
}

class _AnimatedClipRectState extends State<AnimatedClipRect>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(
        duration: widget.duration,
        reverseDuration: widget.reverseDuration ?? widget.duration,
        vsync: this,
        value: widget.open ? 1.0 : 0.0,
        animationBehavior: widget.animationBehavior);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve ?? widget.curve,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.open
        ? _animationController.forward()
        : _animationController.reverse();

    return ClipRect(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return Align(
            alignment: widget.alignment,
            heightFactor: widget.verticalAnimation ? _animation.value : 1.0,
            widthFactor: widget.horizontalAnimation ? _animation.value : 1.0,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
