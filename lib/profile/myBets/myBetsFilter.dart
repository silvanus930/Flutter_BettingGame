import 'package:flutter/material.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jiffy/jiffy.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class MyBetsFilter extends StatefulWidget {
  final Function dateChnaged;

  const MyBetsFilter({Key? key, required this.dateChnaged}) : super(key: key);
  @override
  MyBetsFilterState createState() => MyBetsFilterState();
}

class MyBetsFilterState extends State<MyBetsFilter> {
  String period = LocaleKeys.today.tr();
  var from = Jiffy().startOf(Units.DAY).dateTime;
  var to = Jiffy().endOf(Units.DAY).dateTime;
  String ticketType = 'All';
  TextEditingController _startDateController = TextEditingController();
  DateTime startDate = Jiffy().subtract(days: 1).dateTime;
  TextEditingController _endDateController = TextEditingController();
  DateTime endDate = DateTime.now();
  List<int> activeCategoryList = [0, 1, 2, 3];
  int activeCategory = 0;

  getPeriodName(id) {
    switch (id) {
      case 0:
        return LocaleKeys.today.tr();
      case 1:
        return LocaleKeys.week.tr();
      case 2:
        return LocaleKeys.month.tr();
      case 3:
        return LocaleKeys.period.tr();
      default:
        return "";
    }
  }

  void changePeriod(category) {
    setState(() {
      activeCategory = category;
    });

    dateChange(category);
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => widget.dateChnaged(
        to, from, period, ticketType.replaceAll(new RegExp(r'[\s-]+'), '')));
    WidgetsBinding.instance?.addPostFrameCallback((_) => _startDateController
            .text =
        "${startDate.toLocal().day}/${startDate.toLocal().month}/${startDate.toLocal().year}");
    WidgetsBinding.instance?.addPostFrameCallback((_) => _endDateController
            .text =
        "${endDate.toLocal().day}/${endDate.toLocal().month}/${endDate.toLocal().year}");
  }

  getTicketType(type) {
    switch (type) {
      case 'All':
        return LocaleKeys.all.tr();
      case 'Open':
        return LocaleKeys.open.tr();
      case 'Settled':
        return LocaleKeys.settled.tr();
      case 'Won':
        return LocaleKeys.won.tr();
      case 'Lost':
        return LocaleKeys.lost.tr();
      case 'Cashed-out':
        return LocaleKeys.cashed_out.tr();
      case 'Settled And Cashed-out':
        return LocaleKeys.settledAndCashedout.tr();
      case 'Cancelled':
        return LocaleKeys.cancelled.tr();

      default:
        break;
    }
  }

  dateChange(type) {
    switch (type) {
      case 0:
        setState(() {
          to = Jiffy().endOf(Units.DAY).dateTime;
          from = Jiffy().startOf(Units.DAY).dateTime;
          period = LocaleKeys.today.tr();
        });
        widget.dateChnaged(
            to, from, period, ticketType.replaceAll(new RegExp(r'[\s-]+'), ''));
        break;

      case 1:
        setState(() {
          to = Jiffy().endOf(Units.WEEK).dateTime;
          from = Jiffy().startOf(Units.WEEK).dateTime;
          period = LocaleKeys.week.tr();
        });
        widget.dateChnaged(
            to, from, period, ticketType.replaceAll(new RegExp(r'[\s-]+'), ''));
        break;

      case 2:
        setState(() {
          to = Jiffy().endOf(Units.MONTH).dateTime;
          from = Jiffy().startOf(Units.MONTH).dateTime;
          period = LocaleKeys.month.tr();
        });
        widget.dateChnaged(
            to, from, period, ticketType.replaceAll(new RegExp(r'[\s-]+'), ''));
        break;

      case 3:
        setState(() {
          to = Jiffy(endDate).endOf(Units.DAY).dateTime;
          from = Jiffy(startDate).startOf(Units.DAY).dateTime;
          period = LocaleKeys.period.tr();
        });
        widget.dateChnaged(
            to, from, period, ticketType.replaceAll(new RegExp(r'[\s-]+'), ''));
        break;

      default:
        break;
    }
  }

  Widget customRadio(String txt, int index) {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.all(2.0),
            child: TextButton(
              onPressed: () => dateChange(index),
              style: TextButton.styleFrom(
                backgroundColor: period == txt
                    ? Theme.of(context).indicatorColor
                    : Color(0xFF434553),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              child: Text(
                txt,
                style: TextStyle(
                    color: period == txt
                        ? Theme.of(context).colorScheme.surface
                        : Colors.grey),
              ),
            )));
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime(1900),
        lastDate: endDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary:
                    Theme.of(context).indicatorColor, // header background color
                onPrimary: Theme.of(context)
                    .colorScheme
                    .onPrimary, // header text color
                onSurface:
                    Theme.of(context).colorScheme.onPrimary, // body text color
              ),
              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary:
                      Theme.of(context).indicatorColor, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (pickedDate != null && pickedDate != startDate)
      setState(() {
        startDate = pickedDate;
        var date =
            "${pickedDate.toLocal().day}/${pickedDate.toLocal().month}/${pickedDate.toLocal().year}";
        _startDateController.text = date;
      });
    dateChange(3);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: endDate,
        firstDate: startDate,
        lastDate: Jiffy().add(years: 2).dateTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary:
                    Theme.of(context).indicatorColor, // header background color
                onPrimary: Theme.of(context)
                    .colorScheme
                    .onPrimary, // header text color
                onSurface:
                    Theme.of(context).colorScheme.onPrimary, // body text color
              ),
              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary:
                      Theme.of(context).indicatorColor, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (pickedDate != null && pickedDate != endDate)
      setState(() {
        endDate = pickedDate;
        var date =
            "${pickedDate.toLocal().day}/${pickedDate.toLocal().month}/${pickedDate.toLocal().year}";
        _endDateController.text = date;
      });
    dateChange(3);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                child: Text(LocaleKeys.date.tr(),
                    style: TextStyle(fontSize: 15.0, color: Colors.grey)),
              ),
              Container(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, bottom: 10.0),
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(isDense: true),
                                  value: activeCategory,
                                  dropdownColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  icon: Icon(Icons.keyboard_arrow_down,
                                      color: Colors.white),
                                  items: activeCategoryList
                                      .map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        getPeriodName(value),
                                        style: TextStyle(color: Colors.white),
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
                                    dateChange(value);
                                  },
                                ))))
                  ])),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                    flex: 1,
                    child: Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Color(0xFF575969),
                        ),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());

                                _selectStartDate(context);
                              },
                              controller: _startDateController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                fillColor: Color(0xFF575969),
                                filled: true,
                              ),
                            )))),
                Flexible(
                    flex: 1,
                    child: Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Color(0xFF575969),
                        ),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              key: UniqueKey(),
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());

                                _selectEndDate(context);
                              },
                              controller: _endDateController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  fillColor: Color(0xFF575969),
                                  filled: true),
                            ))))
              ]),
              Container(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                child: Text(LocaleKeys.state.tr(),
                    style: TextStyle(fontSize: 15.0, color: Colors.grey)),
              ),
              Container(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 10.0),
                child: DropdownButton<String>(
                  dropdownColor: Theme.of(context).colorScheme.onSecondary,
                  focusColor: Colors.white,
                  value: ticketType,
                  //elevation: 5,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  iconEnabledColor: Theme.of(context).colorScheme.onPrimary,
                  items: <String>[
                    'All',
                    'Open',
                    'Settled',
                    'Won',
                    'Lost',
                    'Cashed-out',
                    'Settled And Cashed-out',
                    'Cancelled',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        getTicketType(value),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    );
                  }).toList(),
                  hint: Text(
                    "All",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      ticketType = value!;
                      widget.dateChnaged(to, from, period,
                          ticketType.replaceAll(new RegExp(r'[\s-]+'), ''));
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(LocaleKeys.period.tr(),
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ],
          );
        });
  }
}
