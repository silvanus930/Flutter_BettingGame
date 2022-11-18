import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';

class LiveOddsButton extends StatefulWidget {
  final odds;
  final sportId;
  final matchId;
  final status;
  final betDomainStatus;
  final enabled;
  final disabled;

  const LiveOddsButton({
    Key? key,
    this.odds,
    this.sportId,
    this.matchId,
    this.status,
    this.betDomainStatus,
    this.enabled,
    this.disabled,
  }) : super(key: key);

  @override
  State<LiveOddsButton> createState() => LiveOddsButtonState();
}

class LiveOddsButtonState extends State<LiveOddsButton> {
  String updateClass = '';

  @override
  void didUpdateWidget(LiveOddsButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.odds['value'] > oldWidget.odds['value']) {
      updateClass = 'odd-up';
    }

    if (widget.odds['value'] < oldWidget.odds['value']) {
      updateClass = 'odd-down';
    }

    Future.delayed(const Duration(milliseconds: 10000), () {
      updateClass = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    void handleOddClick() {
      final store = StoreProvider.of<AppState>(context);
      if (widget.enabled) {
        store.dispatch(RemoveOddsAction(
            odds: {'match': widget.matchId, 'oddId': widget.odds['oddId']}));
        store.dispatch(
            RemoveMatchObjAction(matchObj: {'oddId': widget.odds['oddId']}));
      } else {
        store.dispatch(SetOddsAction(odds: {
          'match': widget.matchId,
          'betDomainId': widget.odds['betdomainId'],
          'sport': widget.sportId,
          'oddId': widget.odds['oddId']
        }));
      }
    }

    double opacityValue =
        widget.disabled || widget.betDomainStatus != 0 || widget.status == 16
            ? 0.40
            : 1.00;

    return Opacity(
        opacity: opacityValue,
        child: IgnorePointer(
            ignoring: widget.disabled ||
                widget.betDomainStatus != 0 ||
                widget.status == 16 ||
                widget.odds['value'] == 0,
            child: InkWell(
                onTap: () {
                  handleOddClick();
                },
                child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(5.0),
                        border: Border.all(
                            color: widget.enabled
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary)),
                    child: Column(children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 20,
                          color: widget.enabled
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                          child: Text(
                            widget.odds['information'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.0,
                                color: widget.enabled
                                    ? Theme.of(context).colorScheme.surface
                                    : Colors.white),
                          )),
                      Container(
                        height: 35,
                        child: widget.odds['value'] != 0
                            ? Stack(
                                alignment: Alignment.center,
                                textDirection: TextDirection.rtl,
                                fit: StackFit.loose,
                                clipBehavior: Clip.none,
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
                                  ),
                                  Text(widget.odds['value'].toString(), style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                                ],
                              )
                            : Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 24.0,
                                semanticLabel: 'value 0',
                              ),
                      ),
                    ])))));
  }
}
