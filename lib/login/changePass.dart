import 'package:flutter/material.dart';
import 'package:flutter_betting_app/home.dart';
import 'package:flutter_betting_app/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/defaultConfig.dart' as config;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/storage_service.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => ChangePasswordState();
}

extension PasswordValidator on String {
  bool isValidPassword() {
    bool result = false;
    for (final k in config.passwordValidation.keys) {
      bool cherRegExp = true;
      if (k == 'length') {
        cherRegExp = config.passwordValidation[k][0] <= this.length &&
            config.passwordValidation[k][1] >= this.length;
        if (!cherRegExp) {
          passwordError = getPasswordError(k);
        }
      } else if (config.passwordValidation[k]) {
        cherRegExp = RegExp(getRegExp(k)).hasMatch(this);
        if (!cherRegExp) {
          passwordError = getPasswordError(k);
        }
      }
      result = cherRegExp;
      if (!cherRegExp) break;
    }
    return result;
  }
}

String passwordError = "";

getRegExp(type) {
  switch (type) {
    case "must_digit":
      return r'(^(?=.*?[0-9]))';
    case "must_letter":
      return r'(^(?=.*?[A-Za-z]))';
    case "must_uppercase":
      return r'(^(?=.*?[A-Z]))';
    case "must_lowercase":
      return r'(^(?=.*?[a-z]))';
    case "must_have_char":
      return r'(^(?=.*?[#?!@$%^&*-]))';
    case "not_allow_spaces":
      return r'(^([^\s]+$))';
    default:
      return r'^(?=.*?[A-Za-z])(?=.*?[0-9]).{4,20}$';
  }
}

getPasswordError(type) {
  switch (type) {
    case "length":
      return LocaleKeys.regPassError_length.tr(args: [
        config.passwordValidation['length'][0].toString(),
        config.passwordValidation['length'][1].toString()
      ]);
    case "must_digit":
      return LocaleKeys.regPassError_must_digit.tr();
    case "must_letter":
      return LocaleKeys.regPassError_must_letter.tr();
    case "must_uppercase":
      return LocaleKeys.regPassError_must_uppercase.tr();
    case "must_lowercase":
      return LocaleKeys.regPassError_must_lowercase.tr();
    case "must_have_char":
      return LocaleKeys.regPassError_must_have_char.tr(args: ["(#?!@\$%^&*-)"]);
    case "not_allow_spaces":
      return LocaleKeys.regPassError_not_allow_spaces.tr();
    default:
      return "";
  }
}

class ChangePasswordState extends State<ChangePassword> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();
  String errorMessage = "";
  bool showErrorChecker = false;
  bool buttonDisabled = false;

  handleSubmit(e) async {
    setState(() {
      showErrorChecker = false;
      errorMessage = "";
      buttonDisabled = true;
    });

    final StorageService _storageService = StorageService();
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var paymentUrl = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/profile/reset-password-simple/new-password'));

      await http
          .post(paymentUrl,
              headers: {
                "content-type": "application/json",
                "Authorization": accessToken
              },
              body: json.encode({'password': e}))
          .then((response) {
        var result = jsonDecode(response.body);
        if (response.statusCode == 200) {
          _showDialog();
        } else {
          showError(result);
        }
      });
    }
    setState(() {
      buttonDisabled = false;
    });
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.passwordChanged.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(LocaleKeys.yourPasswordChanged.tr()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.ok.tr()),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Home(store: StoreProvider.of<AppState>(context))),
                );
              },
            ),
          ],
        );
      },
    );
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
            icon: new Icon(Icons.close),
            onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Home(store: StoreProvider.of<AppState>(context))),
                  )
                }),
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
                'CHANGE PASSWORD',
                style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
              TextFormField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                validator: (input) =>
                    (input!.isValidPassword() ? null : passwordError),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  errorMaxLines: 4,
                  labelText: 'Password',
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
                child: Text(LocaleKeys.changePassword.tr(),
                    style: TextStyle(color: Colors.black)),
                onPressed: buttonDisabled
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          handleSubmit(_passwordController.text);
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
