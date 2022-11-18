import 'package:flutter/material.dart';
import '../../redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/defaultConfig.dart' as config;
import './myBetsModal.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/storage_service.dart';

class CouponCheck extends StatefulWidget {
  const CouponCheck({Key? key}) : super(key: key);
  @override
  State<CouponCheck> createState() => CouponCheckState();
}

class CouponCheckState extends State<CouponCheck> {
  String code = "";
  String errorText = "";

  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleCouponCode(code) async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');
    setState(() {
      errorText = "";
    });
    if (accessToken!.length > 0) {
      final getParams = {'lang': context.locale.toString()};

      var url = Uri(
        scheme: config.protocol,
        host: config.hostname,
        path: 'betting-api-gateway/user/rest/ticket/getByCode/$code',
        queryParameters: getParams,
      );

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyBetsModal(
                      ticket: result['response'],
                      code: code,
                    )),
          );
        } else {
          setState(() {
            errorText = LocaleKeys.couponCodeNotFound.tr(args: [code]);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.3,
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
                color: Colors.white70,
              ),
              child: ListView(children: [
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(LocaleKeys.couponCheck.tr(),
                        style: TextStyle(
                            fontSize: 17.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
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
                    hintText: LocaleKeys.couponCode.tr(),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).indicatorColor),
                  child: Text(LocaleKeys.check.tr(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.surface)),
                  onPressed: () {
                    handleCouponCode(code);
                  },
                ),
                Container(
                    padding: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    child: Text(errorText,
                        style: TextStyle(color: Colors.red[900])))
              ]));
        });
  }
}
