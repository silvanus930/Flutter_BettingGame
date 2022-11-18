import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/defaultConfig.dart' as config;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class BookingCheck extends StatefulWidget {
  final Function addMatchesData;
  const BookingCheck({Key? key, required this.addMatchesData})
      : super(key: key);
  @override
  State<BookingCheck> createState() => BookingCheckState();
}

class BookingCheckState extends State<BookingCheck> {
  String code = "";
  String errorText = "";

  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleBookingCode(code) async {
    setState(() {
      errorText = "";
    });

    final getParams = {'lang': context.locale.toString()};

    var url = Uri(
      scheme: config.protocol,
      host: config.hostname,
      path: 'betting-api-gateway/user/rest/ticket/loadStored/$code',
      queryParameters: getParams,
    );

    await http.get(url, headers: {
      "content-type": "application/json",
    }).then((response) async {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        await widget.addMatchesData(
            result['response']['values'], result['response']['betType']);
        return;
      } else {
        setState(() {
          errorText = LocaleKeys.bookinCodeNotFound.tr(args: [code]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        decoration: new BoxDecoration(),
        child: ListView(children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(LocaleKeys.bookingCode.tr(),
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
          TextField(
            style: TextStyle(color: Colors.black),
            onChanged: (value) {
              setState(() {
                code = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(10.0),
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              hintText: LocaleKeys.bookingCode.tr(),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).indicatorColor),
            child: Text(LocaleKeys.check.tr(),
                style: TextStyle(color: Theme.of(context).colorScheme.surface)),
            onPressed: () {
              handleBookingCode(code);
            },
          ),
          Container(
              padding: const EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: Text(errorText, style: TextStyle(color: Colors.red[900])))
        ]));
  }
}
