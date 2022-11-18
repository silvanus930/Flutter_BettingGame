import 'dart:developer';
import '../config/defaultConfig.dart' as config;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Locale? lang = context.locale;
    return config.supportedLocale.length > 1
        ? Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.onSurface),
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: DropdownButton(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryVariant),
                    underline: SizedBox(),
                    iconSize: 0.0,
                    value: lang,
                    onChanged: (Locale? value) async {
                      log(value.toString(), name: toString());
                      await context.setLocale(value!);
                    },
                    items: context.supportedLocales
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.toString().toUpperCase()),
                            ))
                        .toList())))
        : SizedBox();
  }
}
