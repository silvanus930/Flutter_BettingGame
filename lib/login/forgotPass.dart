import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recoveryCode.dart';
import 'dart:convert';
import '../config/defaultConfig.dart' as config;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => ForgotPasswordState();
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension PhoneValidator on String {
  bool isValidPhone() {
    return RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(this);
  }
}

class ForgotPasswordState extends State<ForgotPassword> {
  List<bool> isSelected = [true, false];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  PhoneNumber contryCode = PhoneNumber(isoCode: config.phoneContryCode);
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
        '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/v2/security/reset-password-simple'));

    await http
        .post(paymentUrl,
            headers: {"content-type": "application/json"},
            body: json.encode({'credential': e}))
        .then((response) {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return RecoveryCode();
          }),
        );
      } else {
        var error = jsonDecode(response.body);
        showError(error);
      }

      setState(() {
        buttonDisabled = false;
      });
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
        errorMessage = 'Error. Please try again later';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.resetPassword.tr()),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () => {Navigator.pop(context)}),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                LocaleKeys.recoverPassword.tr(),
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: ToggleButtons(
                    children: <Widget>[
                      Container(
                          width: 120,
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.email, size: 17),
                                ),
                                TextSpan(
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 10),
                                  text: ' ${LocaleKeys.email.tr()}',
                                ),
                              ],
                            ),
                          )),
                      Container(
                          width: 120,
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.phone, size: 17),
                                ),
                                TextSpan(
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 10),
                                  text: ' ${LocaleKeys.phone.tr()}',
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
                    selectedColor: Colors.white,
                    fillColor: Colors.blueGrey[600],
                  )),
              isSelected[0]
                  ? TextFormField(
                      keyboardType: isSelected[0]
                          ? TextInputType.emailAddress
                          : TextInputType.phone,
                      controller:
                          isSelected[0] ? _emailController : _phoneController,
                      validator: (input) => isSelected[0]
                          ? (input!.isValidEmail() ? null : "Check your email")
                          : (input!.isValidPhone()
                              ? null
                              : "Please enter mobile number"),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      decoration: InputDecoration(
                        labelText: isSelected[0]
                            ? LocaleKeys.email.tr()
                            : LocaleKeys.phone.tr(),
                        icon: Icon(
                          isSelected[0] ? Icons.mail : Icons.phone,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
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
                    )
                  : InternationalPhoneNumberInput(
                      textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      onInputChanged: (PhoneNumber number) {
                        _phoneController.text = number.phoneNumber.toString();
                      },
                      selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                          setSelectorButtonAsPrefixIcon: true),
                      ignoreBlank: false,
                      validator: (value) => value!.isEmpty
                          ? LocaleKeys.enterPhoneNumber.tr()
                          : null,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      selectorTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      initialValue: contryCode,
                      formatInput: false,
                      locale: context.locale.toString(),
                      spaceBetweenSelectorAndTextField: 0,
                      inputDecoration: InputDecoration(
                        labelText: LocaleKeys.phone.tr(),
                        errorStyle: TextStyle(color: Colors.red),
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
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
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                    ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).indicatorColor),
                child: Text(LocaleKeys.sendCode.tr(),
                    style: TextStyle(color: Colors.black)),
                onPressed: buttonDisabled
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          handleSubmit(isSelected[0]
                              ? _emailController.text
                              : _phoneController.text);
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
