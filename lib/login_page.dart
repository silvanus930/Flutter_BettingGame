import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'dart:developer';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';
import 'livechat.dart';
import 'login/forgotPass.dart';
import '../config/defaultConfig.dart' as config;
import 'regForm/regPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter_betting_app/presentation/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '/lang_view.dart';
import '../models/storage_item.dart';
import 'services/storage_service.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  List<bool> isSelected = config.loginTemplates.length > 2
      ? [true, false, false]
      : config.loginTemplates.length == 2
          ? [true, false]
          : [true];
  //final StorageService _storageService = StorageService();
  final TextEditingController controller = TextEditingController();
  //Getting the password from the textField
  final TextEditingController controller1 = TextEditingController();
  PhoneNumber contryCode = PhoneNumber(isoCode: config.phoneContryCode);
  bool remember = false;

  bool showError = false;
  var faultInfo = [];
  bool isButtonDisabled = false;

  errorMessage() {
    String error = LocaleKeys.loginOrPassIncorrect.tr();

    switch (faultInfo[0]['code']) {
      case 111:
        {
          error = LocaleKeys.noUserName.tr(args: [faultInfo[1]['name']]);
        }
        break;

      case 112:
        {
          error = LocaleKeys.incorrectPass.tr();
        }
        break;

      case 114:
        {
          error = LocaleKeys.userNotActivated.tr();
        }
        break;

      case 172:
        {
          error = LocaleKeys.userBlocked.tr(args: [faultInfo[1]['name']]);
        }
        break;

      default:
        {
          error = LocaleKeys.loginOrPassIncorrect.tr();
        }
        break;
    }

    return error;
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

  void handleAuthenticate(String email, String pass, var store) async {
    setState(() {
      showError = false;
    });

    var url = (Uri.parse(
        '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/v2/security/login/simple'));

    Map data = {'credential': email, "password": pass};
    var body = json.encode(data);

    await http
        .post(url,
            headers: {
              "content-type": "application/json",
              'credentials': 'include'
            },
            body: body)
        .then((response) {
      if (response.statusCode == 200) {
        final StorageService _storageService = StorageService();
        var result = jsonDecode(response.body);
        _storageService.writeSecureData(
            StorageItem('token', "Bearer " + result['response']['token']));
        if (remember) {
          _storageService.writeSecureData(
              StorageItem('userId', result['response']['userId'].toString()));
        }
        if (result['response']['gbCode'] != null) {
          _storageService.writeSecureData(
              StorageItem('gbCode', result['response']['gbCode']));
        }
        store.dispatch(SetUserIdAction(userId: result['response']['userId']));
        store.dispatch(SetAuthorizationAction(authorization: true));

        if (result['response']['faultInfo'] == null) {
          Navigator.of(context).pop();
        }
      } else {
        var result = jsonDecode(response.body);
        if (result != null &&
            result['response'] != null &&
            result['response']['faultInfo'] != null) {
          setState(() {
            showError = true;
          });
          setState(() {
            faultInfo = [
              result['response']['faultInfo'],
              {'name': email}
            ];
          });
        }
      }
      setState(() {
        isButtonDisabled = false;
      });
    });
  }

  Widget _getInput() {
    return Padding(
      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: config.loginTemplates[isSelected[0]
                  ? 0
                  : isSelected[1]
                      ? 1
                      : 2] ==
              "Email"
          ? TextField(
              autofillHints: [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              key: UniqueKey(),
              controller: controller,
              decoration: InputDecoration(
                  fillColor: Theme.of(context).primaryColor,
                  filled: true,
                  border: OutlineInputBorder(),
                  labelText: LocaleKeys.email.tr(),
                  hintText: LocaleKeys.enterValidEmail.tr()),
            )
          : config.loginTemplates[isSelected[0]
                      ? 0
                      : isSelected[1]
                          ? 1
                          : 2] ==
                  "Phone"
              ? InternationalPhoneNumberInput(
                  autofillHints: [AutofillHints.email],
                  textStyle: TextStyle(color: Colors.black),
                  onInputChanged: (PhoneNumber number) {
                    controller.text = number.phoneNumber.toString();
                  },
                  onInputValidated: (bool value) {
                    debugPrint('validate');
                  },
                  selectorConfig: SelectorConfig(
                      leadingPadding: 10,
                      selectorType: PhoneInputSelectorType.DIALOG,
                      setSelectorButtonAsPrefixIcon: true),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.black),
                  initialValue: contryCode,
                  formatInput: false,
                  locale: context.locale.toString(),
                  spaceBetweenSelectorAndTextField: 10,
                  textAlignVertical: TextAlignVertical.center,
                  inputDecoration: InputDecoration(
                      fillColor: Theme.of(context).primaryColor,
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: LocaleKeys.phone.tr(),
                      hintText: LocaleKeys.enterPhoneNumber.tr()),
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  onSaved: (PhoneNumber number) {
                    debugPrint('On Saved: $number');
                  },
                )
              : TextField(
                  autofillHints: [AutofillHints.username],
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: Colors.black),
                  key: UniqueKey(),
                  controller: controller,
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).primaryColor,
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: LocaleKeys.userName.tr(),
                      hintText: LocaleKeys.enterValidUsername.tr()),
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.loginPage.tr()),
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
                width: 150,
                height: 100,
                /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                child: Image.asset(config.imageLocation + "logo/logo.png")),
            Padding(
                padding: EdgeInsets.only(bottom: 20),
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
                      controller.text = "";
                      controller1.text = "";
                    });
                  },
                  color: Colors.grey,
                  selectedColor: Colors.white,
                  fillColor: Colors.blueGrey[600],
                )),
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
            ),
            AutofillGroup(
                child: Column(children: [
              _getInput(),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  autofillHints: [AutofillHints.password],
                  style: TextStyle(color: Colors.black),
                  controller: controller1,
                  obscureText: true,
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).primaryColor,
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: LocaleKeys.password.tr(),
                      hintText: LocaleKeys.enterPassword.tr()),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(children: [
                    Checkbox(
                      onChanged: (bool? value) {
                        setState(() {
                          remember = value!;
                        });
                      },
                      value: remember,
                    ),
                    Text(LocaleKeys.rememberMe.tr())
                  ]))
            ])),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ForgotPassword();
                  }),
                );
              },
              child: Text(
                LocaleKeys.forgotPassword.tr(),
                style: Theme.of(context).primaryTextTheme.headline5,
              ),
            ),
            Container(
              height: 50,
              width: 250,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: !isButtonDisabled
                        ? Theme.of(context).indicatorColor
                        : Color(0xFF808080)),
                onPressed: !isButtonDisabled
                    ? () {
                        setState(() {
                          isButtonDisabled = true;
                        });
                        handleAuthenticate(
                            controller.text, controller1.text, store);
                      }
                    : null,
                child: Text(
                  LocaleKeys.login.tr(),
                  style: TextStyle(color: Colors.black87, fontSize: 25),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return RegPage();
                  }),
                );
              },
              child: Text(
                LocaleKeys.newUserAccount.tr(),
                style: TextStyle(
                    color: Theme.of(context).indicatorColor, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
