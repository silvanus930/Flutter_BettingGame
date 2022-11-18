import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/utils.dart';
import 'depositDialog.dart';
import 'withdrawDialog.dart';
import '../../config/defaultConfig.dart' as config;
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';

const CHECK_STATUS_INTERVAL = 3 * 1000;

class MyWallet extends StatefulWidget {
  const MyWallet({Key? key}) : super(key: key);

  @override
  MyWalletState createState() => MyWalletState();
}

class MyWalletState extends State<MyWallet> {
  List paymentMethodsDetails = [];

  void getPaymentMethods() async {
    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/system/getFranchiserPaymentMethods'));

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          if (result['response'] != null) {
            setState(() {
              paymentMethodsDetails = result['response'];
            });
          }
        }
      });
    }
  }

  checkAvailableDepositMethod(paymentMethodCode) {
    final paymentMethodDetails =
        extractPaymentMethodDetails(paymentMethodsDetails, paymentMethodCode);
    return paymentMethodDetails != null && paymentMethodDetails['forDeposit'];
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) => getPaymentMethods());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.myWallet.tr()),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: <Widget>[LoginAction()],
              ),
              body: paymentMethodsDetails.length > 0
                  ? ListView(
                      padding: const EdgeInsets.all(8),
                      children: <Widget>[
                          DepositDialog(
                              paymentMethodsDetails: paymentMethodsDetails,
                              userData: state.userData),
                          WithdrawDialog(
                              paymentMethodsDetails: paymentMethodsDetails,
                              userData: state.userData)
                        ])
                  : Center(child: CircularProgressIndicator()));
        });
  }
}
