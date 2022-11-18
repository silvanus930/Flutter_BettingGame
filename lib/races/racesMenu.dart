import 'package:flutter/material.dart';
import '../config/defaultConfig.dart' as config;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_betting_app/presentation/app_icons.dart';

import '../login_page.dart';

class RacesMenu extends StatefulWidget {
  final authorization;
  final currentSport;
  final currentSportType;
  final liveStreamEnabled;
  final Function sportChange;
  final Function sportTypeChange;
  final Function toggleLiveStream;
  const RacesMenu(
      {Key? key,
      this.authorization,
      this.currentSport,
      this.currentSportType,
      this.liveStreamEnabled,
      required this.sportTypeChange,
      required this.sportChange,
      required this.toggleLiveStream})
      : super(key: key);

  @override
  State<RacesMenu> createState() => RacesMenuState();
}

class RacesMenuState extends State<RacesMenu> {
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void didUpdateWidget(RacesMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            color: Theme.of(context).colorScheme.onBackground),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  config.sisHorsesEnabled
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                                child: IconButton(
                              color: widget.currentSport == 0
                                  ? Theme.of(context).indicatorColor
                                  : Theme.of(context).colorScheme.onPrimary,
                              icon: const Icon(
                                AppIcons.I29,
                              ),
                              onPressed: () {
                                widget.sportChange(0);
                              },
                            )),
                            Text('Horses',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: widget.currentSport == 0
                                        ? Theme.of(context).indicatorColor
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary))
                          ],
                        )
                      : SizedBox(),
                  config.sisDogsEnabled
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              color: widget.currentSport == 1
                                  ? Theme.of(context).indicatorColor
                                  : Theme.of(context).colorScheme.onPrimary,
                              icon: const Icon(AppIcons.dogs),
                              onPressed: () {
                                widget.sportChange(1);
                              },
                            ),
                            Text('Dogs',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: widget.currentSport == 1
                                        ? Theme.of(context).indicatorColor
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary))
                          ],
                        )
                      : SizedBox()
                ],
              )),
          Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: IconButton(
                        color: widget.liveStreamEnabled
                            ? Theme.of(context).indicatorColor
                            : Theme.of(context).colorScheme.onPrimary,
                        icon: const Icon(Icons.play_circle),
                        onPressed: () {
                          !widget.authorization
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                )
                              : widget.toggleLiveStream();
                        },
                      )),
                  Text('Live Stream',
                      style: TextStyle(
                          fontSize: 9,
                          color: widget.liveStreamEnabled
                              ? Theme.of(context).indicatorColor
                              : Theme.of(context).colorScheme.onPrimary))
                ],
              )),
          Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          child: IconButton(
                        color: widget.currentSportType == 0
                            ? Theme.of(context).indicatorColor
                            : Theme.of(context).colorScheme.onPrimary,
                        icon: const Icon(Icons.schedule),
                        onPressed: () {
                          widget.sportTypeChange(0);
                        },
                      )),
                      Text('By time',
                          style: TextStyle(
                              fontSize: 9,
                              color: widget.currentSportType == 0
                                  ? Theme.of(context).indicatorColor
                                  : Theme.of(context).colorScheme.onPrimary))
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        color: widget.currentSportType == 1
                            ? Theme.of(context).indicatorColor
                            : Theme.of(context).colorScheme.onPrimary,
                        icon: const Icon(Icons.flag),
                        onPressed: () {
                          widget.sportTypeChange(1);
                        },
                      ),
                      Text('By country',
                          style: TextStyle(
                              fontSize: 9,
                              color: widget.currentSportType == 1
                                  ? Theme.of(context).indicatorColor
                                  : Theme.of(context).colorScheme.onPrimary))
                    ],
                  )
                ],
              ))
        ]));
  }
}
