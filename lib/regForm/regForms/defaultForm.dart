import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/defaultConfig.dart' as config;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DefaultForm extends StatefulWidget {
  final buttonDisabled;
  final Function handleSubmit;
  const DefaultForm({Key? key, this.buttonDisabled, required this.handleSubmit})
      : super(key: key);

  @override
  State<DefaultForm> createState() => DefaultFormState();
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
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

extension UserNameValidator on String {
  bool isValidUserName() {
    return RegExp(r'^[A-za-z]{1}[A-za-z0-9]{2,19}$').hasMatch(this);
  }
}

extension PhoneValidator on String {
  bool isValidPhone() {
    return RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(this);
  }
}

extension NameValidator on String {
  bool isValidName() {
    return RegExp(r'^[A-za-z]{1}[A-za-z0-9_ ]{1,30}$').hasMatch(this);
  }
}

class DefaultFormState extends State<DefaultForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _affiliateController = TextEditingController();
  DateTime currentDate = DateTime.now();
  PhoneNumber contryCode = PhoneNumber(isoCode: config.phoneContryCode);
  Map formValues = {};
  bool termsAgree = false;
  bool showTermsError = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary:
                    Theme.of(context).indicatorColor, // header background color
                onPrimary: Theme.of(context)
                    .colorScheme
                    .onPrimary, // header text color
                onSurface:
                    Theme.of(context).colorScheme.onPrimary, // body text color
              ),
              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary:
                      Theme.of(context).indicatorColor, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
        var date =
            "${pickedDate.toLocal().day}/${pickedDate.toLocal().month}/${pickedDate.toLocal().year}";
        _dateController.text = date;
      });
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  calculateOnlyAge(int birthDate) {
    DateTime currentDate = DateTime.now();
    DateTime age = new DateTime(
        currentDate.year - birthDate, currentDate.month, currentDate.day);
    return age;
  }

  valuesObject() {
    formValues['connected_affiliate'] = _affiliateController.text;
    formValues['email'] = _emailController.text;
    formValues['date_of_birth'] = DateFormat('dd/MM/yyyy').format(
        config.regOnlyAgeInput
            ? calculateOnlyAge(int.parse(_dateController.text))
            : currentDate);
    formValues['username'] = _userNameController.text;
    formValues['firstname'] = _firstNameController.text;
    formValues['lastname'] = _lastNameController.text;
    formValues['phone'] = _phoneController.text;
    formValues['password'] = _passwordController.text;
    formValues['checkbox-confirm'] = termsAgree;

    widget.handleSubmit(formValues, 2);
  }

  Widget _getLoginDetails() {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          margin: const EdgeInsets.only(top: 20.0),
          alignment: Alignment.centerLeft,
          child: Text(LocaleKeys.loginDetails.tr(),
              style: textTheme.headline6, textAlign: TextAlign.left)),
      for (var item in config.signUpFields['login'])
        item == 'username'
            ? TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.name,
                controller: _userNameController,
                validator: (input) => (input!.isValidUserName()
                    ? null
                    : LocaleKeys.regUserNameError.tr(args: ["3-20"])),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  labelText: LocaleKeys.userName.tr(),
                  errorMaxLines: 4,
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
              )
            : item == 'password'
                ? TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordController,
                    validator: (input) =>
                        (input!.isValidPassword() ? null : passwordError),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    decoration: InputDecoration(
                      errorMaxLines: 4,
                      labelText: LocaleKeys.password.tr(),
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
                : item == 'email'
                    ? TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (input) => (input!.isValidEmail()
                            ? null
                            : LocaleKeys.regEmailError.tr()),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        decoration: InputDecoration(
                          labelText: LocaleKeys.email.tr(),
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
                    : item == 'phone'
                        ? InternationalPhoneNumberInput(
                            textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                            onInputChanged: (PhoneNumber number) {
                              _phoneController.text =
                                  number.phoneNumber.toString();
                            },
                            selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.DIALOG,
                                setSelectorButtonAsPrefixIcon: true),
                            ignoreBlank: false,
                            validator: (value) => value!.isEmpty
                                ? LocaleKeys.enterPhoneNumber.tr()
                                : null,
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              hintStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                          )
                        : SizedBox()
    ]);
  }

  Widget _getPersonalDetails() {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          margin: const EdgeInsets.only(top: 20.0),
          alignment: Alignment.centerLeft,
          child: Text(LocaleKeys.personalDetails.tr(),
              style: textTheme.headline6, textAlign: TextAlign.left)),
      for (var item in config.signUpFields['personal'])
        item == 'name' || item == 'lastname'
            ? TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: Key(item),
                keyboardType: TextInputType.name,
                controller:
                    item == 'name' ? _firstNameController : _lastNameController,
                validator: (input) => (input!.isValidName()
                    ? null
                    : item == 'name'
                        ? LocaleKeys.regFirstNameError.tr()
                        : LocaleKeys.regLastNameError.tr()),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  labelText: item == 'name'
                      ? LocaleKeys.firstName.tr()
                      : LocaleKeys.lastName.tr(),
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
              )
            : item == 'date'
                ? config.regOnlyAgeInput
                    ? TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: _dateController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        validator: (value) => value!.isEmpty
                            ? LocaleKeys.enterDateOfBirth.tr()
                            : int.parse(value) < config.ageLimitInYear
                                ? LocaleKeys.registrationAllowed.tr(
                                    args: [config.ageLimitInYear.toString()])
                                : null,
                        decoration: InputDecoration(
                          labelText: "Age",
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
                    : TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());

                          _selectDate(context);
                        },
                        controller: _dateController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        validator: (value) => value!.isEmpty
                            ? LocaleKeys.enterDateOfBirth.tr()
                            : calculateAge(currentDate) < config.ageLimitInYear
                                ? LocaleKeys.registrationAllowed.tr(
                                    args: [config.ageLimitInYear.toString()])
                                : null,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.dateOfBirth.tr(),
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
                : item == 'affiliate'
                    ? TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.phone,
                        controller: _affiliateController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        decoration: InputDecoration(
                          labelText: LocaleKeys.affiliateCode.tr(),
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
                    : SizedBox()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _getLoginDetails(),
          _getPersonalDetails(),
          SizedBox(height: 10),
          Row(children: [
            Checkbox(
              visualDensity: VisualDensity(horizontal: -4),
              onChanged: (bool? value) {
                setState(() {
                  termsAgree = value!;
                });
              },
              value: termsAgree,
            ),
            Flexible(
                child: RichText(
              text: new TextSpan(
                children: [
                  new TextSpan(
                    text: '${LocaleKeys.haveRead.tr()} ',
                    style: new TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  new TextSpan(
                    text: '${LocaleKeys.termsConiditons.tr()} ',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            "${config.protocol}://${config.linkShareDomainUrl}/pages/info/sport-betting-rules-general");
                      },
                  ),
                  new TextSpan(
                    text: LocaleKeys.agreeTerms.tr(),
                    style: new TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            )),
          ]),
          showTermsError && !termsAgree
              ? Container(
                  alignment: Alignment.centerLeft,
                  child: Text(LocaleKeys.mustAgreeTerms.tr(),
                      style: TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.left))
              : SizedBox(),
          SizedBox(height: 20),
          Container(
              height: 50,
              width: 250,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: widget.buttonDisabled
                        ? Color(0xFF808080)
                        : Theme.of(context).indicatorColor),
                child: Text(
                  LocaleKeys.createAccount.tr(),
                  style: TextStyle(color: Colors.black87, fontSize: 20),
                ),
                onPressed: widget.buttonDisabled
                    ? null
                    : () {
                        if (_formKey.currentState!.validate() && termsAgree) {
                          valuesObject();
                        }
                        if (!termsAgree) {
                          setState(() {
                            showTermsError = true;
                          });
                        } else {
                          setState(() {
                            showTermsError = false;
                          });
                        }
                      },
              )),
          SizedBox(height: 20),
        ]));
  }
}
