import './flavor_config.dart';
import '../main.dart';
import 'package:flutter/material.dart';

void main() {
  mainCommon(
    FlavorConfig()
      ..appTitle = "Demo7"
      ..flavorName = "demo7"
      ..apiEndpoint = {
        Endpoints.items: "random.api.dev/items",
        Endpoints.details: "random.api.dev/item"
      }
      ..showSlides = true
      ..whatsappLinkUrl = "https://tiny.cc/5r4qpz"
      ..supportedLocale = ['en', 'fr']
      ..showCurrencyLogo = false
      ..hostname =
          "demo7.pbt.com.mt" //demo7.pbt.com.mt demo7.bet24.live mieeq-app.koolbet237.com
      ..protocol = "https"
      ..versionUrl = "demo7-res.pbt.com.mt"
      ..linkShareDomainUrl = "demo7.pbt.com.mt"
      ..tawkDirectChatLink =
          "https://tawk.to/chat/611e23a2d6e7610a49b0eddc/1fdermd6j"
      ..popularMatchesGroups = {
        1: [
          //sportId
          {'key': "BMG_1X2", 'name': '1X2'},
          {'key': "BMG_GGNG", 'name': 'GG / NG'}
        ],
        2: [
          {'key': "BMG_1X2", 'name': '1X2'},
        ]
      }
      ..enableLongGroups = false
      ..loginTemplates = ["Email", "Phone", "Username"]
      ..signUpFields = {
        "login": ["username", "password", "email", "phone"],
        "personal": ["name", "lastname", "date", "affiliate"]
      }
      ..profileFields = [
        'firstname',
        'lastname',
        'date_of_birth',
        'phone',
        'email'
      ]
      ..phoneContryCode = "EE"
      ..prematchTabs = [1, 2, 0, 3] //[Sports,Popular,Tournaments,Races]
      ..stakeButtons = ["100", "500", "5000", "50000", "MAX"]
      ..imageLocation = "assets/images/koolbet/"
      ..secondSplash = false
      ..promoCampaigns = [
        "cash_prize",
        "cut1",
        "bet1_get1",
        "cashout",
        "refund_on_lost"
      ]
      ..timeFormat = {
        "en": 0, // AM/PM
        "fr": 1, // 24H
      }
      ..stakeTaxEnabled = true
      ..profitTaxEnabled = true
      ..profitTaxCalculateFromWin = false
      ..stakeTaxPercent = 15
      ..profitTaxPercent = 18
      ..profitTaxMinIncome = 1000
      ..stakeTaxName = "VAT"
      ..profitTaxName = "Income Tax"
      ..taxedTicketTypes = ["0", "1", "2", "10", "20", "21"]
      ..ageLimitInYear = 18
      ..regOnlyAgeInput = true
      ..passwordValidation = {
        'length': [4, 20],
        'must_digit': true,
        'must_letter': false,
        'must_uppercase': false,
        'must_lowercase': false,
        'must_have_char': false,
        'not_allow_spaces': true,
      }
      ..sisDogsEnabled = true
      ..sisHorsesEnabled = true
      ..cashInternalNameDeposit = ""
      ..cashInternalNameWithdraw = ""
      ..goldenRaceEnabled = true
      ..goldenRaceOnlyAuth = false
      ..goldenRaceMenuTitle = "Golden Race Games"
      ..goldenRaceUnAuthId = 'e8c414be-4ea9-4e8c-b58b-4cc293b3851e'
      ..tvbetIframeUrl = "https://tvbetframe1.com"
      ..tvBetClientId = "3149"
      ..tvBetEnabled = true
      ..superJackpotEnabled = true
      ..theme = ThemeData(
        scaffoldBackgroundColor: const Color(0xFF22232E),
        primaryColor: Colors.white,
        hintColor: Colors.grey,
        primarySwatch: Colors.grey,
        tabBarTheme: TabBarTheme(labelColor: Colors.white),
        canvasColor: Color(0xFF22232E),
        primaryTextTheme: TextTheme(
            subtitle1: TextStyle(fontSize: 15.0, color: Colors.grey),
            subtitle2: TextStyle(fontSize: 12.0, color: Colors.grey),
            bodyText2: TextStyle(color: Colors.yellowAccent, fontSize: 15),
            headline5: TextStyle(color: Colors.blue, fontSize: 15),
            headline6: TextStyle(color: Colors.white),
            caption: TextStyle(fontSize: 12, color: Colors.yellowAccent)),
        cardTheme: CardTheme(
            color: Color(0xFF333549),
            shadowColor: Colors.black.withOpacity(0.1)),
        cardColor: Color(0xFF333549),
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: Color(0xFFFFC500)),
        indicatorColor: Color(0xFFFFC500),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFC500), foregroundColor: Colors.black),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          backgroundColor: Color(0xFF0F1016),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        secondaryHeaderColor: Color(0xFFFFC500),
        colorScheme: ColorScheme.light(
          secondary: Color(0xFFFFC500),
          onSecondary: Color(0xFF575969),
          secondaryVariant: Color(0xFF333549),
          background: const Color(0xFF000000),
          onBackground: const Color(0xFF0F1016),
          primary: Colors.grey,
          onPrimary: const Color(0xFFeeeeee),
          primaryVariant: Colors.white,
          surface: Color(0xFF000000),
          onSurface: Color(0xFF333549),
          brightness: Brightness.dark,
        ),
        bottomAppBarColor: Color(0xFF0F1016),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F1016),
          elevation: 10,
          selectedItemColor: Color(0xFFFFC500),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
        ),
      ),
  );
}
