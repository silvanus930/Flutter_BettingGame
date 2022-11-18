import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_betting_app/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'model/utils.dart';
import 'model/const.dart';
import '../../config/defaultConfig.dart' as config;
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import '../../services/storage_service.dart';

import 'redirectPaymentView.dart';

const CHECK_STATUS_INTERVAL = 3 * 1000;

class DepositDialog extends StatefulWidget {
  final paymentMethodsDetails;
  final userData;
  const DepositDialog({Key? key, this.paymentMethodsDetails, this.userData})
      : super(key: key);

  @override
  DepositDialogState createState() => DepositDialogState();
}

class DepositDialogState extends State<DepositDialog> {
  Map inputsFields = {};
  var paymentStatus;
  Timer timer = Timer(Duration(milliseconds: 1), () {});

  void inputChanged(type, value) {
    setState(() {
      inputsFields[type.toLowerCase()] = value;
    });
  }

  checkAvailableDepositMethod(paymentMethodCode) {
    final paymentMethodDetails = extractPaymentMethodDetails(
        widget.paymentMethodsDetails, paymentMethodCode);
    return paymentMethodDetails != null && paymentMethodDetails['forDeposit'];
  }

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  _openTeleBirr(data) async {
    bool isInstalled =
        await DeviceApps.isAppInstalled(data['launchIntentForPackage']);
    if (isInstalled != false) {
      final AndroidIntent intent = AndroidIntent(
        componentName: 'io.dcloud.PandoraEntry',
        package: data['launchIntentForPackage'],
        arguments: data['extras'],
      );
      await intent.launch();
    } else {
      launch("market://details?id=" + data['launchIntentForPackage']);
    }
  }

  void paymentRequest(type, system) async {
    var paymentUrl;

    showDialog(
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocaleKeys.Pending.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(LocaleKeys.confirmOnMobile.tr()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.cancel.tr()),
              onPressed: () {
                if (timer.isActive) {
                  timer.cancel();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      context: context,
    );

    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');

    switch (type.toLowerCase()) {
      case "deposit":
        paymentUrl = (Uri.parse(
            '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/payment/deposit'));
        break;
      case "withdraw":
        paymentUrl = (Uri.parse(
            '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/payment/withdraw'));
        break;
      default:
        paymentUrl = ("Unexpected payment transaction type: " + type);
    }

    Map body = {};

    body['system'] = system;
    body['phoneNumber'] = inputsFields['phone'];
    body['amount'] = inputsFields['amount'];
    body['parameters'] = inputsFields;

    if (system == 'TeleBirr') {
      body['parameters']['clientType'] = "androidApp";
    }

    if (accessToken!.length > 0) {
      await http
          .post(paymentUrl,
              headers: {
                "content-type": "application/json",
                "authorization": accessToken,
              },
              body: json.encode(body))
          .then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          if (result['response']['pinCode'] != null) {
            Navigator.of(context).pop();
            _showPinCode(result['response']['pinCode'],
                result['response']['amount'].toString());
          } else {
            callPaymentStatusChecker(result['response']['localCode']);
          }
        } else {
          Navigator.of(context).pop();
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void callPaymentStatusChecker(localCode) async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/payment/status/$localCode'));

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          if (result['response'] != null) {
            switch (result['response']['status']) {
              case "Pending":
                timer = Timer(Duration(milliseconds: CHECK_STATUS_INTERVAL),
                    () => callPaymentStatusChecker(localCode));
                break;
              case "Applied":
                Navigator.of(context).pop();
                _showPaymentStatusDialog("Applied");
                break;
              case "Complete":
                Navigator.of(context).pop();
                //window.location.href = "/profile/mywallet/" + this.state.localCode;
                _showPaymentStatusDialog("Success");
                break;
              case "Failed":
                Navigator.of(context).pop();
                _showPaymentStatusDialog("Failed");
                break;
              case "Abandoned":
                Navigator.of(context).pop();
                _showPaymentStatusDialog("Abandoned");
                break;
              case "Canceled":
                Navigator.of(context).pop();
                _showPaymentStatusDialog("Canceled");
                break;
              case "Redirect":
                Navigator.of(context).pop();
                if (result['response']['system'] == 'TeleBirr' &&
                    result['response']['redirectUrl'] != "") {
                  _openTeleBirr(json.decode(result['response']['redirectUrl']));
                } else if (result['response']['redirectUrl'] != "")
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PaymentWebView(
                          redirectUrl: result['response']['redirectUrl']);
                    }),
                  );
                break;
              default:
                timer = Timer(Duration(milliseconds: CHECK_STATUS_INTERVAL),
                    () => callPaymentStatusChecker(localCode));
                break;
            }
          }
        }
      });
    }
  }

  Future<void> _showMyDialog(String title, inputs, system) async {
    return showDialog<void>(
        context: context,
        builder: (context) {
          String error = "";
          final _formKey = GlobalKey<FormState>();
          return StatefulBuilder(
            builder: (context, setState) {
              void inputValidate(payment, amount) {
                var paymentMethodDetails = extractPaymentMethodDetails(
                    widget.paymentMethodsDetails, paymentMethods[payment]);

                double min = 0;
                double max = 0;
                if (paymentMethodDetails != null) {
                  if (paymentMethodDetails['depositLimit'] != null) {
                    min = paymentMethodDetails['depositLimit']['min'];
                    max = paymentMethodDetails['depositLimit']['max'];
                  }
                }

                if (amount.length == 0) {
                  setState(() {
                    error = "Required";
                  });
                } else if (min > 0 && double.parse(amount) < min) {
                  setState(() {
                    error = "Minimum allowed is $min";
                  });
                } else if (max > 0 && double.parse(amount) > max) {
                  setState(() {
                    error = "Maximum allowed is $max";
                  });
                } else {
                  setState(() {
                    error = "";
                  });
                }
              }

              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: ListBody(
                        children: <Widget>[
                          TextFormField(
                            onChanged: (value) {
                              inputValidate(system, value);
                              inputChanged("amount", value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: LocaleKeys.amount.tr(),
                                errorText: error != "" ? error : null),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          for (var item in inputs)
                            TextFormField(
                              style: TextStyle(),
                              enabled: system == 'MTNMOMO' ||
                                      system == 'OrangeMoney2'
                                  ? false
                                  : true,
                              initialValue: item == "Phone"
                                  ? widget.userData[0][item.toLowerCase()]
                                  : "",
                              onChanged: (value) {
                                inputChanged(item, value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                inputChanged(item, value);
                                return null;
                              },
                              decoration: InputDecoration(hintText: item),
                            )
                        ],
                      )),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(LocaleKeys.cancel.tr()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(LocaleKeys.deposit.tr()),
                    onPressed: error == ""
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pop();
                              paymentRequest("deposit", system);
                            }
                          }
                        : null,
                  ),
                ],
              );
            },
          );
        });
  }

  Future<void> _showPaymentStatusDialog(String status) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your payment $status'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.ok.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPinCode(String pinCode, String amount) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pin Code"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Use this PIN $pinCode at a cashier to deposit $amount ${StoreProvider.of<AppState>(context).state.currency} to your account'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.ok.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var depositValues = depositVariants
        .where((e) => checkAvailableDepositMethod(e['id']))
        .toList();
    return Container(
        decoration: new BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        child: ExpansionTile(
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            textColor: Theme.of(context).secondaryHeaderColor,
            iconColor: Theme.of(context).secondaryHeaderColor,
            leading: const Icon(Icons.payments),
            title: Text(LocaleKeys.deposit.tr()),
            children: [
              Container(
                  decoration: new BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => Divider(
                            color: Colors.black,
                          ),
                      itemCount: depositValues.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return ListTile(
                            title:
                                Text(depositValues[index]['title'].toString()),
                            leading: Image.asset(
                                depositValues[index]['src'].toString(),
                                height: 40,
                                width: 50),
                            trailing: Icon(Icons.arrow_right),
                            onTap: () => {
                                  _showMyDialog(
                                      depositValues[index]['title'].toString(),
                                      depositValues[index]['fields'],
                                      depositValues[index]['system'])
                                });
                      }))
            ]));
  }
}
