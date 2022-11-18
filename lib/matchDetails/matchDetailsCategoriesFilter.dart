import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/generated/locale_keys.g.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MatchDetailsGroupsFilter extends StatefulWidget {
  final groupsData;
  final activeGroup;
  final Function marketChange;

  const MatchDetailsGroupsFilter(
      {Key? key, this.groupsData, this.activeGroup, required this.marketChange})
      : super(key: key);

  @override
  State<MatchDetailsGroupsFilter> createState() =>
      MatchDetailsGroupsFilterState();
}

class MatchDetailsGroupsFilterState extends State<MatchDetailsGroupsFilter>
    with TickerProviderStateMixin {
  PanelController _pc = new PanelController();
  late ScrollController _scrollController;
  bool sliderOpened = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  void initState() {
    //WidgetsBinding.instance?.addPostFrameCallback((_) => generateSubscribe());
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: 0.0, end: .5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scrollController = ScrollController();
  }

  @override
  void deactivate() {
    super.deactivate();
    _controller.dispose();
    _scrollController.dispose();
  }

  void marketChange(String market) {
    /*final Map unSubcribe = {};
    unSubcribe["sport"] = widget.groupsData[0]['sport'];
    unSubcribe["country"] = widget.groupsData[0]['country'];
    unSubcribe["groups"] = [activeGroups];
    unSubcribe["tournament"] = widget.groupsData[0]['tournament'];
    unSubcribe["matchIds"] = widget.groupsData[0]['matchList'];
    unSubcribe["isFavorite"] = false;

    StoreProvider.of<AppState>(context).dispatch(
        SetPrematchUnSubscribeListAction(prematchUnSubscribeList: unSubcribe));

    final Map subscribe = {};
    subscribe["sport"] = widget.groupsData[0]['sport'];
    subscribe["country"] = widget.groupsData[0]['country'];
    subscribe["groups"] = [market];
    subscribe["tournament"] = widget.groupsData[0]['tournament'];
    subscribe["matchIds"] = widget.groupsData[0]['matchList'];
    subscribe["isFavorite"] = false;

    StoreProvider.of<AppState>(context).dispatch(
        SetPrematchSubscribeListAction(prematchSubscribeList: subscribe));*/
  }

  Widget getMarkets(List<dynamic> strings, int sportId) {
    strings.forEach((e) {
      e['isAct'] = widget.activeGroup == e['key'] ? 0 : 1;
    });
    strings.sort((a, b) {
      int date = a["isAct"].compareTo(b["isAct"]);
      if (date != 0) return date;
      return a['sort'].compareTo(b['sort']);
    });
    return SingleChildScrollView(
        controller: _scrollController,
        child: Container(
            padding: const EdgeInsets.all(5.0),
            child: Wrap(
                alignment: WrapAlignment.center,
                children: strings
                    .map((item) => new FractionallySizedBox(
                        widthFactor:
                            sportId == 100 || sportId == 101 ? 0.5 : 0.30,
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 10.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(5.0),
                                primary: item['key'] == widget.activeGroup
                                    ? Colors.black87
                                    : Colors.white,
                                elevation: 5, //Defines Elevation
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                ),
                                backgroundColor:
                                    item['key'] == widget.activeGroup
                                        ? Theme.of(context).indicatorColor
                                        : Color(0xFF575969)),
                            onPressed: () {
                              _pc.close();
                              _scrollController.animateTo(0.0,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease);
                              widget.marketChange(item['key']);
                            },
                            child: Text(
                                item['shortName'].toString().toUpperCase(),
                                overflow: TextOverflow.ellipsis),
                          ),
                        )))
                    .toList())));
  }

  Widget _buildDetailsButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        primary: Theme.of(context).indicatorColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
      ),
      child: RotationTransition(
          turns: _animation,
          child: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.surface,
          )),
      onPressed: () {
        setState(() {
          _pc.isPanelOpen ? _pc.close() : _pc.open();
        });
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          List data = [];
          int sportId = state.matchDetailsMatchData[0]['sport']['sportId'];
          Map all = {'key': 'ALL', 'shortName': LocaleKeys.all.tr(), 'sort': 0};
          data = sportId != 100 && sportId != 101
              ? [...state.matchDetailsMatchData[0]['betdomainGroups'], all]
              : [...state.matchDetailsMatchData[0]['betdomainGroups']];
          double filterHeight = (50 * (data.length / 3).ceil()).toDouble();
          return Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Theme.of(context).indicatorColor,
                width: 3.0,
              ))),
              child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SlidingUpPanel(
                        onPanelOpened: () => setState(() {
                              sliderOpened = true;
                            }),
                        onPanelClosed: () => setState(() {
                              sliderOpened = false;
                            }),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        isDraggable: false,
                        minHeight: 50,
                        maxHeight: filterHeight >
                                (MediaQuery.of(context).size.height * 0.5)
                                    .toDouble()
                            ? MediaQuery.of(context).size.height * 0.5
                            : filterHeight,
                        controller: _pc,
                        parallaxEnabled: true,
                        parallaxOffset: .5,
                        panel: sportId != 100 && sportId != 101
                            ? getMarkets(
                                data
                                    .where((element) =>
                                        element['key'] != 'BMG_OUTRIGHT')
                                    .toList(),
                                sportId)
                            : getMarkets(
                                data
                                    .where((element) =>
                                        element['key'] != 'BMG_OUTRIGHT' &&
                                        element['key'] != 'BMG_MAIN' &&
                                        element['key'] != 'BMG_MAIN_EXT' &&
                                        element['key'] != 'BMG_SIS_THREESOMES')
                                    .toList(),
                                sportId)),
                    data.length > 3
                        ? Positioned(bottom: -15, child: _buildDetailsButton())
                        : SizedBox()
                  ]));
        });
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
        value: widget.open ? 1.0 : 0.7,
        animationBehavior: widget.animationBehavior);
    _animation = Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(
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
