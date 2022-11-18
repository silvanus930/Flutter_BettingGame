import 'package:flutter/material.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jiffy/jiffy.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class TransactionFilter extends StatefulWidget {
  final Function dateChnaged;

  const TransactionFilter({Key? key, required this.dateChnaged})
      : super(key: key);
  @override
  TransactionFilterState createState() => TransactionFilterState();
}

class TransactionFilterState extends State<TransactionFilter> {
  String period = LocaleKeys.today.tr();
  var from = Jiffy().startOf(Units.DAY).dateTime;
  var to = Jiffy().endOf(Units.DAY).dateTime;
  String ticketType = "";
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
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => widget.dateChnaged(to, from, period, ticketType));
    WidgetsBinding.instance?.addPostFrameCallback((_) => _startDateController
            .text =
        "${startDate.toLocal().day}/${startDate.toLocal().month}/${startDate.toLocal().year}");
    WidgetsBinding.instance?.addPostFrameCallback((_) => _endDateController
            .text =
        "${endDate.toLocal().day}/${endDate.toLocal().month}/${endDate.toLocal().year}");
  }

  dateChange(type) {
    switch (type) {
      case 0:
        setState(() {
          to = Jiffy().endOf(Units.DAY).dateTime;
          from = Jiffy().startOf(Units.DAY).dateTime;
          period = LocaleKeys.today.tr();
        });
        widget.dateChnaged(to, from, period, ticketType);
        break;

      case 1:
        setState(() {
          to = Jiffy().endOf(Units.WEEK).dateTime;
          from = Jiffy().startOf(Units.WEEK).dateTime;
          period = LocaleKeys.week.tr();
        });
        widget.dateChnaged(to, from, period, ticketType);
        break;

      case 2:
        setState(() {
          to = Jiffy().endOf(Units.MONTH).dateTime;
          from = Jiffy().startOf(Units.MONTH).dateTime;
          period = LocaleKeys.month.tr();
        });
        widget.dateChnaged(to, from, period, ticketType);
        break;

      case 3:
        setState(() {
          to = Jiffy(endDate).endOf(Units.DAY).dateTime;
          from = Jiffy(startDate).startOf(Units.DAY).dateTime;
          period = LocaleKeys.period.tr();
        });
        widget.dateChnaged(to, from, period, ticketType);
        break;

      default:
        break;
    }
  }

  checkName(code) {
    switch (code) {
      case "":
        return LocaleKeys.all.tr();
      case "13":
        return LocaleKeys.deposit.tr();
      case "14":
        return LocaleKeys.withdraw.tr();
      case "34":
        return LocaleKeys.stakePrematch.tr();
      case "33":
        return LocaleKeys.stakeLive.tr();
      case "35":
        return LocaleKeys.stakeMixed.tr();
      case "24":
        return LocaleKeys.paymentNoteReg.tr();
      case "25":
        return LocaleKeys.paymentNotePaid.tr();
      case "48":
        return LocaleKeys.bonusSysWithdraw.tr();
      case "49":
        return LocaleKeys.bonusSysDeposit.tr();
      case "54":
        return LocaleKeys.codeSharingCommission.tr();
      case "63":
        return LocaleKeys.weeklyBonus.tr();
      case "62":
        return LocaleKeys.weeklyBonusBurned.tr();
      case "55":
        return LocaleKeys.affiliateCommissions.tr();
      default:
        return '';
    }
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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Column(children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: Text(LocaleKeys.date.tr(),
                  style: TextStyle(fontSize: 15.0, color: Colors.grey)),
            ),
            Container(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 10.0),
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 10.0),
                        child: Column(children: [
                          Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButtonFormField(
                                        decoration:
                                            InputDecoration(isDense: true),
                                        value: activeCategory,
                                        dropdownColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        icon: Icon(Icons.keyboard_arrow_down,
                                            color: Colors.white),
                                        items: activeCategoryList
                                            .map<DropdownMenuItem<int>>(
                                                (int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(
                                              getPeriodName(value),
                                              style: TextStyle(
                                                  color: Colors.white),
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
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 1,
                              child: Container(
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Color(0xFF575969),
                                  ),
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
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
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0),
                      child: Text(LocaleKeys.state.tr(),
                          style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 10.0),
                      child: DropdownButton<String>(
                        dropdownColor:
                            Theme.of(context).colorScheme.onSecondary,
                        focusColor: Theme.of(context).colorScheme.onPrimary,
                        value: ticketType,
                        //elevation: 5,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        iconEnabledColor:
                            Theme.of(context).colorScheme.onPrimary,
                        items: <String>[
                          "",
                          "13",
                          "14",
                          "34",
                          "33",
                          "35",
                          "24",
                          "25",
                          "48",
                          "49",
                          "54",
                          "63",
                          "62",
                          "55",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              checkName(value),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
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
                            widget.dateChnaged(to, from, period, ticketType);
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
                ))
          ]);
        });
  }
}
