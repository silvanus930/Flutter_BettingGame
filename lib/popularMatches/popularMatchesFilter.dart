import 'package:flutter/material.dart';
import '../config/defaultConfig.dart' as config;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class PopularMatchesFilter extends StatefulWidget {
  final metaData;
  final currentSportId;
  final currentMarket;
  final Function marketChange;
  final Function preiodChange;
  final Function sportChange;
  final Function sportGroupChange;
  const PopularMatchesFilter(
      {Key? key,
      this.metaData,
      this.currentSportId,
      this.currentMarket,
      required this.sportGroupChange,
      required this.marketChange,
      required this.preiodChange,
      required this.sportChange})
      : super(key: key);

  @override
  State<PopularMatchesFilter> createState() => PopularMatchesFilterState();
}

class PopularMatchesFilterState extends State<PopularMatchesFilter> {
  int currentDate = 1;
  List availableSports = [];

  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) => getSport());
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  getPeriodName(id) {
    switch (id) {
      case 1:
        return LocaleKeys.today.tr();
      case 2:
        return LocaleKeys.tomorrow.tr();
      default:
        return "";
    }
  }

  getMarketName(key) {
    if (widget.metaData.length > 1) {
      return widget.metaData[0].firstWhere((e) => e['key'] == key)['shortName'];
    }
    return key;
  }

  void didUpdateWidget(PopularMatchesFilter oldWidget) {
    if (oldWidget.metaData[2][0]['defaultName'] !=
        widget.metaData[2][0]['defaultName']) {
      getSport();
    }
    super.didUpdateWidget(oldWidget);
  }

  void getSport() {
    if (widget.metaData.length > 2) {
      List sportIds = widget.metaData[1]
          .where((id) => config.popularMatchesGroups[id] != null)
          .toList();
      List getSports = widget.metaData[2]
          .where((sport) => sportIds.contains(sport['sportId']))
          .toList();
      setState(() {
        availableSports = getSports;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Container(
          padding: const EdgeInsets.all(8.0),
          decoration: new BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(isDense: true),
                                value: currentDate,
                                dropdownColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white),
                                items: <int>[1, 2]
                                    .map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      getPeriodName(value),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: Text(
                                  "All",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                onChanged: (int? value) {
                                  widget.preiodChange(value);
                                },
                              ))))),
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(isDense: true),
                                value: widget.currentMarket.toString(),
                                dropdownColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white),
                                items: config.popularMatchesGroups[
                                        widget.currentSportId]!
                                    .map<DropdownMenuItem<String>>((Map value) {
                                  return DropdownMenuItem<String>(
                                    value: value['key'],
                                    child: Text(
                                      getMarketName(value['key']),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                                hint: Text(
                                  "All",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                onChanged: (String? value) {
                                  widget.marketChange(value);
                                },
                              )))))
            ],
          )),
      DefaultTabController(
          initialIndex: 0,
          length: availableSports.length, // length of tabs
          child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5)),
                color: Theme.of(context).colorScheme.onBackground),
            height: 65,
            child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  onTap: (index) {
                    if (config.popularMatchesGroups[availableSports[index]
                            ['sportId']]!
                        .firstWhere((el) => el['key'] == widget.currentMarket)
                        .isNotEmpty) {
                      widget.sportChange(availableSports[index]['sportId']);
                    } else {
                      widget.sportGroupChange(
                          availableSports[index]['sportId'],
                          config.popularMatchesGroups[availableSports[index]
                              ['sportId']]![0]['key']);
                    }
                  },
                  indicatorColor: Colors.transparent,
                  isScrollable: true,
                  labelColor: Theme.of(context).indicatorColor,
                  unselectedLabelColor: Colors.white,
                  tabs: [
                    for (final tab in availableSports)
                      Tab(
                          icon: Icon(tab['sportId'] != 1
                              ? Icons.sports_basketball
                              : Icons.sports_soccer),
                          child: Column(children: [
                            Text(tab['defaultName'],
                                style: TextStyle(fontSize: 10)),
                          ]))
                  ],
                )),
          ))
    ]));
  }
}
