import 'package:flutter/material.dart';
import 'package:flutter_betting_app/betslip/BSLogic.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable

class SystemList extends StatefulWidget {
  final bankersArrayLength;
  final Function toggleTrigger;
  final Function radioValueChanged;
  final coefsCalcArr;
  final systemCombos;
  final lettersArr;
  final matchObj;
  final systemRadioValue;

  const SystemList(
      {Key? key,
      this.lettersArr,
      this.bankersArrayLength,
      required this.toggleTrigger,
      required this.radioValueChanged,
      this.coefsCalcArr,
      this.systemCombos,
      this.matchObj,
      this.systemRadioValue})
      : super(key: key);

  @override
  State<SystemList> createState() => SystemListState();
}

class SystemListState extends State<SystemList> {
  @override
  void initState() {
    super.initState();
    final onlyLetters = RegExp(r"\d+");
    var onlyLettersArr = widget.lettersArr
        .where((element) => !onlyLetters.hasMatch(element))
        .toList();
    WidgetsBinding.instance?.addPostFrameCallback((_) =>
        widget.radioValueChanged(
            onlyLettersArr.length - widget.bankersArrayLength - 1));
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => widget.toggleTrigger(true));
  }

  @override
  void didUpdateWidget(SystemList oldWidget) {
    super.didUpdateWidget(oldWidget);

    final onlyLetters = RegExp(r"\d+");

    var newOnlyLettersArr = widget.lettersArr
            .where((element) => !onlyLetters.hasMatch(element))
            .toList()
            .length -
        widget.bankersArrayLength -
        1;

    var oldOnlyLettersArr = oldWidget.lettersArr
            .where((element) => !onlyLetters.hasMatch(element))
            .toList()
            .length -
        oldWidget.bankersArrayLength -
        1;

    if (newOnlyLettersArr != oldOnlyLettersArr ||
        widget.matchObj.length != oldWidget.matchObj.length ||
        widget.bankersArrayLength != oldWidget.bankersArrayLength) {
      WidgetsBinding.instance?.addPostFrameCallback(
          (_) => widget.radioValueChanged(newOnlyLettersArr));
      WidgetsBinding.instance
          ?.addPostFrameCallback((_) => widget.toggleTrigger(true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlyLetters = RegExp(r"\d+");

    var onlyLettersArr = widget.lettersArr
        .where((element) => !onlyLetters.hasMatch(element))
        .toList();

    int tournamentsCountLength = (systemTipSize(onlyLettersArr) > 1)
        ? systemTipSize(onlyLettersArr) - widget.bankersArrayLength
        : systemTipSize(onlyLettersArr);

    return Container(
        decoration: new BoxDecoration(
          color: Colors.orange,
        ),
        child: DropdownButtonHideUnderline(
            child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(5.0), isDense: true),
                  value: onlyLettersArr.length - widget.bankersArrayLength - 1,
                  dropdownColor: Colors.orange,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  items: List.generate(tournamentsCountLength, (int index) {
                    return DropdownMenuItem(
                        value: index + 2,
                        child: Text(
                          '${LocaleKeys.system.tr()} ${(index + 2)}/${onlyLettersArr.length - widget.bankersArrayLength}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ));
                  }),
                  onChanged: (newValue) {
                    widget.radioValueChanged(newValue);
                    widget.toggleTrigger(true);
                  },
                ))));
  }
}
