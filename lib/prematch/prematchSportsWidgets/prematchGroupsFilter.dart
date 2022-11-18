import 'package:flutter/material.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/actions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PrematchGroupsFilter extends StatefulWidget {
  final groupsData;
  final Function marketChange;

  const PrematchGroupsFilter(
      {Key? key, this.groupsData, required this.marketChange})
      : super(key: key);

  @override
  State<PrematchGroupsFilter> createState() => PrematchGroupsFilterState();
}

class PrematchGroupsFilterState extends State<PrematchGroupsFilter>
    with TickerProviderStateMixin {
  PanelController _pc = new PanelController();
  bool sliderOpened = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late ScrollController _scrollController;

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

  void marketChange(String market, String activeGroups) {
    final Map unSubcribe = {};
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
        SetPrematchSubscribeListAction(prematchSubscribeList: subscribe));

    widget.marketChange(market);
  }

  Widget getMarkets(List<dynamic> strings, String activeGroups) {
    strings.forEach((e) {
      e['isAct'] = activeGroups == e['key'] ? 0 : 1;
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
                        widthFactor: 0.30,
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 10.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(5.0),
                                primary: item['key'] == activeGroups
                                    ? Colors.black87
                                    : Colors.white,
                                elevation: 5, //Defines Elevation
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                ),
                                backgroundColor: item['key'] == activeGroups
                                    ? Theme.of(context).indicatorColor
                                    : Color(0xFF575969)),
                            onPressed: () {
                              _pc.close();
                              _scrollController.animateTo(0.0,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease);
                              marketChange(item['key'], activeGroups);
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
          double filterHeight = (50 *
                  (state.prematchBetdomainsGroup[0]['groups'].length / 3)
                      .ceil())
              .toDouble();

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
                        panel: getMarkets(
                            state.prematchBetdomainsGroup[0]['groups']
                                .where((element) =>
                                    element['key'] != 'BMG_OUTRIGHT')
                                .toList(),
                            state.prematchBetdomainsGroup[0]['activeGroup']
                                [0])),
                    state.prematchBetdomainsGroup[0]['groups'].length > 3
                        ? Positioned(bottom: -15, child: _buildDetailsButton())
                        : SizedBox()
                  ]));
        });
  }
}
