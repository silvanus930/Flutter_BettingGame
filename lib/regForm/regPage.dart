import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/defaultConfig.dart' as config;
import '../livechat.dart';
import 'regForms/emailForm.dart';
import 'regForms/phoneForm.dart';
import 'regForms/defaultForm.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '/redux/app_state.dart';
import '../home.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_betting_app/presentation/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/lang_view.dart';

class RegPage extends StatefulWidget {
  const RegPage({Key? key}) : super(key: key);

  @override
  State<RegPage> createState() => RegPageState();
}

class RegPageState extends State<RegPage> {
  List<bool> isSelected = config.loginTemplates.length > 2
      ? [true, false, false]
      : config.loginTemplates.length == 2
          ? [true, false]
          : [true];
  String errorMessage = "";
  String errorCodeMessage = "";
  bool showCodeErrorChecker = false;
  bool showErrorChecker = false;
  bool buttonDisabled = false;
  TextEditingController _codeController = TextEditingController();
  Map formValues = {};

  handleSubmit(e, type) async {
    setState(() {
      showErrorChecker = false;
      errorMessage = "";
      buttonDisabled = true;
      formValues = e;
    });

    e['currency'] = StoreProvider.of<AppState>(context).state.currency;
    if (type != 2) {
      e['language'] = "EN";
    }
    if (type == 2) {
      e['default_language'] = "EN";
    }
    if (type != 2) {
      e['affiliateCode'] = null;
    }
    var paymentUrl = (Uri.parse(type != 2
        ? '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/v2/security/registration/simple'
        : '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/security/signUp'));

    await http
        .post(paymentUrl,
            headers: {"content-type": "application/json"}, body: json.encode(e))
        .then((response) {
      if (response.statusCode == 200) {
        _showDialog(type);
      } else {
        var error = jsonDecode(response.body);
        showError(error);
      }

      setState(() {
        buttonDisabled = false;
      });
    });
  }

  handleCodeCheck(code, phone) async {
    setState(() {
      showCodeErrorChecker = false;
      errorCodeMessage = "";
    });

    Navigator.of(context).pop();

    showDialog(
      barrierDismissible: false,
      builder: (ctx) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
      context: context,
    );

    var paymentUrl = (Uri.parse(
        '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/v2/security/verify/phone'));

    await http
        .post(paymentUrl,
            headers: {"content-type": "application/json"},
            body: json.encode({'phone': phone, 'code': code}))
        .then((response) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['response'] != false) {
          _showDialogVerif();
        } else {
          setState(() {
            showCodeErrorChecker = true;
            errorCodeMessage = LocaleKeys.invalidVerifCode.tr();
          });
          _showDialog(-1);
        }
      } else {
        setState(() {
          showCodeErrorChecker = true;
          errorCodeMessage = LocaleKeys.invalidVerifCode.tr();
        });
        _showDialog(-1);
      }
    });
  }

  resendCode(phone) async {
    var paymentUrl = (Uri.parse(
        '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/v2/security/verify/phone/resend'));

    await http
        .post(paymentUrl,
            headers: {"content-type": "application/json"},
            body: json.encode({'phone': phone}))
        .then((response) {
      if (response.statusCode == 200) {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return RecoveryCode();
          }),
        );*/
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        var error = jsonDecode(response.body);
        showError(error);
      }
    });
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
        errorMessage = LocaleKeys.errorTryAgain.tr();
      });
    }
  }

  Future<void> _showDialog(type) async {
    _getCloseButton(context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            alignment: FractionalOffset.topRight,
            child: GestureDetector(
              child: Icon(
                Icons.clear,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        GlobalKey<FormState> _formKey = GlobalKey<FormState>();
        return Scaffold(
            body: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titlePadding: const EdgeInsets.all(0.0),
          title: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _getCloseButton(context),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 48, color: Colors.green),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          LocaleKeys.registrationCompleted.tr(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          contentPadding: EdgeInsets.all(8),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    showCodeErrorChecker
                        ? errorCodeMessage
                        : type > 0
                            ? LocaleKeys.thankyouForRegEmail.tr()
                            : LocaleKeys.thankyouForRegCode.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: showCodeErrorChecker
                            ? Colors.red
                            : Theme.of(context).colorScheme.onPrimary)),
                type < 1
                    ? Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _codeController,
                          onChanged: (value) {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: 'code', errorText: null),
                          keyboardType: TextInputType.number,
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
          actions: <Widget>[
            type < 1
                ? TextButton(
                    child: Text(LocaleKeys.resend.tr(),
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor)),
                    onPressed: () {
                      resendCode(formValues['credential']);
                    },
                  )
                : SizedBox(),
            TextButton(
              child: Text(
                  type < 1 ? LocaleKeys.confirm.tr() : LocaleKeys.ok.tr(),
                  style: TextStyle(color: Theme.of(context).indicatorColor)),
              onPressed: () {
                type < 1
                    ? handleCodeCheck(
                        _codeController.text, formValues['credential'])
                    : Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
      },
    );
  }

  Future<void> _showDialogVerif() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(LocaleKeys.verification.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(LocaleKeys.accountActivated.tr()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.ok.tr(),
                  style: TextStyle(color: Theme.of(context).indicatorColor)),
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

  getTabName(String name) {
    switch (name) {
      case "Username":
        return LocaleKeys.userName.tr();
      case "Phone":
        return LocaleKeys.phone.tr();
      case "Email":
        return LocaleKeys.email.tr();
      default:
        return '';
    }
  }

  final snackBar = SnackBar(
    backgroundColor: Colors.green,
    content:
        const Text('Сode has been sent', style: TextStyle(color: Colors.white)),
    action: SnackBarAction(
      label: '',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.registration.tr()),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        actions: <Widget>[
          config.whatsappLinkUrl != ""
              ? new IconButton(
                  icon: new Icon(AppIcons.whatsapp, color: Colors.green),
                  onPressed: () => {launch(config.whatsappLinkUrl)})
              : SizedBox(),
          new IconButton(
              icon: new Icon(Icons.chat),
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LiveChat()),
                    ),
                  }),
          Padding(
              padding: EdgeInsets.only(right: 20.0, top: 10.0, bottom: 10.0),
              child: LanguageView())
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                width: 200,
                height: 150,
                /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                child: Image.asset(config.imageLocation + "logo/logo.png")),

            /*Visibility(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(5.0),
                    color: Color(0xFFFFF1F0),
                  ),
                  width: 250,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text(faultInfo.length > 0 ? errorMessage() : "",
                        style: TextStyle(fontSize: 17.0, color: Colors.black),
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
              maintainAnimation: true,
              maintainState: true,
              visible: showError,
            ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Text(
                              errorMessage.length > 0 ? errorMessage : "",
                              style: TextStyle(
                                  fontSize: 17.0, color: Colors.black),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    maintainAnimation: true,
                    maintainState: true,
                    visible: showErrorChecker,
                  ),
                  Text(
                    LocaleKeys.registration.tr().toUpperCase(),
                    style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: ToggleButtons(
                        children: <Widget>[
                          for (var item in config.loginTemplates)
                            Container(
                                width: 120,
                                alignment: Alignment.center,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                            item == 'Username'
                                                ? Icons.account_circle
                                                : item == 'Phone'
                                                    ? Icons.phone
                                                    : Icons.email,
                                            size: 17),
                                      ),
                                      TextSpan(
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 10),
                                        text: ' ${getTabName(item)}',
                                      ),
                                    ],
                                  ),
                                )),
                        ],
                        isSelected: isSelected,
                        borderColor: Colors.blueGrey[600],
                        selectedBorderColor: Colors.blueGrey[600],
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        color: Colors.grey,
                        selectedColor: Theme.of(context).colorScheme.onPrimary,
                        fillColor: Colors.blueGrey[600],
                      )),
                  config.loginTemplates[isSelected[0]
                              ? 0
                              : isSelected[1]
                                  ? 1
                                  : 2] ==
                          "Email"
                      ? EmailForm(
                          buttonDisabled: buttonDisabled,
                          handleSubmit: (values, type) {
                            handleSubmit(values, type);
                          },
                        )
                      : config.loginTemplates[isSelected[0]
                                  ? 0
                                  : isSelected[1]
                                      ? 1
                                      : 2] ==
                              "Phone"
                          ? PhoneForm(
                              buttonDisabled: buttonDisabled,
                              handleSubmit: (values, type) {
                                handleSubmit(values, type);
                              },
                            )
                          : DefaultForm(
                              buttonDisabled: buttonDisabled,
                              handleSubmit: (values, type) {
                                handleSubmit(values, type);
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
