import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';

// ignore: must_be_immutable

class RacesOddButton extends StatefulWidget {
  final odds;
  final sportId;
  final matchId;
  final status;
  final betDomainStatus;
  final enabled;
  final disabled;

  const RacesOddButton({
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
  State<RacesOddButton> createState() => RacesOddButtonState();
}

class RacesOddButtonState extends State<RacesOddButton>
    with TickerProviderStateMixin {
  String updateClass = '';
  late AnimationController _resizableController;

  @override
  void didUpdateWidget(RacesOddButton oldWidget) {
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

  void dispose() {
    _resizableController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _resizableController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _resizableController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void handleOddClick() {
      final store = StoreProvider.of<AppState>(context);
      if (widget.enabled) {
        if (widget.sportId == 100) {
          store.dispatch(RemoveHorsesOddsAction(horsesOdds: {
            'match': widget.matchId,
            'oddId': widget.odds['oddId']
          }));
          store.dispatch(
              RemoveMatchObjAction(matchObj: {'oddId': widget.odds['oddId']}));
        } else {
          store.dispatch(RemoveDogsOddsAction(dogsOdds: {
            'match': widget.matchId,
            'oddId': widget.odds['oddId']
          }));
          store.dispatch(
              RemoveMatchObjAction(matchObj: {'oddId': widget.odds['oddId']}));
        }
      } else {
        if (widget.sportId == 100) {
          store.dispatch(SetHorsesOddsAction(horsesOdds: {
            'match': widget.matchId,
            'betDomainId': widget.odds['betdomainId'],
            'sport': widget.sportId,
            'oddId': widget.odds['oddId']
          }));
        } else {
          store.dispatch(SetDogsOddsAction(dogsOdds: {
            'match': widget.matchId,
            'betDomainId': widget.odds['betdomainId'],
            'sport': widget.sportId,
            'oddId': widget.odds['oddId']
          }));
        }
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
                widget.odds['value'] == 0 ||
                widget.odds == null,
            child: InkWell(
                child: AnimatedBuilder(
                    animation: _resizableController,
                    builder: (context, child) {
                      return Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.12,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: widget.enabled
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.onSurface,
                            border: Border.all(
                                width: updateClass != ""
                                    ? (_resizableController.value + 0.2) * 1.5
                                    : 1,
                                color: updateClass == "odd-up"
                                    ? Colors.green
                                    : updateClass == "odd-down"
                                        ? Colors.red
                                        : widget.enabled
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary)),
                        child: widget.odds['value'] != 0 && widget.odds != null
                            ? Text(
                                widget.odds['value'].toString(),
                                style: TextStyle(
                                    color: widget.enabled
                                        ? Theme.of(context).colorScheme.surface
                                        : Colors.white),
                              )
                            : Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 15.0,
                                semanticLabel: 'value 0',
                              ),
                      );
                    }),
                onTap: () {
                  handleOddClick();
                })));
  }
}
