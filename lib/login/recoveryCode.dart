import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/storage_item.dart';
import 'changePass.dart';
import 'dart:convert';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';
import '../config/defaultConfig.dart' as config;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/storage_service.dart';

class RecoveryCode extends StatefulWidget {
  const RecoveryCode({Key? key}) : super(key: key);

  @override
  State<RecoveryCode> createState() => RecoveryCodeState();
}

class RecoveryCodeState extends State<RecoveryCode> {
  final StorageService _storageService = StorageService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _codeController = TextEditingController();
  String errorMessage = "";
  bool showErrorChecker = false;
  bool buttonDisabled = false;

  handleSubmit(e) async {
    setState(() {
      showErrorChecker = false;
      errorMessage = "";
      buttonDisabled = true;
    });
    var paymentUrl = (Uri.parse(
        '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/v2/security/reset-password-simple/check-code'));

    await http
        .post(paymentUrl,
            headers: {"content-type": "application/json"},
            body: json.encode({'code': e}))
        .then((response) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        handleUserData(result);
      } else {
        showError(result);
      }
    });

    setState(() {
      buttonDisabled = false;
    });
  }

  void updateUserData(data, token) {
    _storageService.writeSecureData(StorageItem('token', "Bearer " + token));

    StoreProvider.of<AppState>(context).dispatch(SetUserDataAction(
        userData: [data['response']['return']['fields']['field']]));

    // StoreProvider.of<AppState>(context).dispatch(SetUserIdAction(userId: result['response']['userId']));

    StoreProvider.of<AppState>(context)
        .dispatch(SetAuthorizationAction(authorization: true));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ChangePassword();
      }),
    );
  }

  void handleUserData(data) async {
    if (data['response'] != null && data['response']['token'] != null) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/profile/load'));

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": "Bearer " + data['response']['token']
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          updateUserData(result, data['response']['token']);
        } else {
          showError(response);
        }
      });
    }
  }

  showError(data) {
    if (data['errors'].isNotEmpty && data['errors'].length > 0) {
      setState(() {
        showErrorChecker = true;
        errorMessage = data['errors'][0]['message'];
      });
    } else {
      setState(() {
        showErrorChecker = true;
        errorMessage = 'Error. Please try again later';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.changePassword.tr()),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () => {Navigator.pop(context)}),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(5.0),
                      color: Color(0xFFFFF1F0),
                    ),
                    width: 250,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Text(errorMessage.length > 0 ? errorMessage : "",
                          style: TextStyle(fontSize: 17.0, color: Colors.black),
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
                maintainAnimation: true,
                maintainState: true,
                visible: showErrorChecker,
              ),
              Text(
                LocaleKeys.recoverCode.tr(),
                style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _codeController,
                validator: (input) => input!.length > 0 ? null : "invalid code",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  errorMaxLines: 4,
                  labelText: 'Recover code',
                  errorStyle: TextStyle(color: Colors.red),
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).indicatorColor),
                child: Text(LocaleKeys.validateCode.tr(),
                    style: TextStyle(color: Colors.black)),
                onPressed: buttonDisabled
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          handleSubmit(_codeController.text);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
