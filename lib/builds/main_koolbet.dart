import './flavor_config.dart';
import '../main.dart';
import 'package:flutter/material.dart';

void main() {
  mainCommon(
    FlavorConfig()
      ..appTitle = "Koolbet237"
      ..flavorName = "koolbet"
      ..apiEndpoint = {
        Endpoints.items: "random.api.dev/items",
        Endpoints.details: "random.api.dev/item"
      }
      ..supportedLocale = ['en', 'fr']
      ..showCurrencyLogo = false
      ..showSlides = true
      ..hostname =
          "mieeq-app.koolbet237.com" //demo7.pbt.com.mt demo7.bet24.live mieeq-app.koolbet237.com
      ..protocol = "https"
      ..versionUrl = "appres.koolbet237.com"
      ..linkShareDomainUrl = "www.koolbet237.com"
      ..tawkDirectChatLink =
          "https://tawk.to/chat/5d11f46f53d10a56bd7bba65/default"
      ..whatsappLinkUrl = "https://api.whatsapp.com/send?phone=237659033915"
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
      ..timeFormat = {
        "en": 0, // AM/PM
        "fr": 1, // 24H
      }
      ..loginTemplates = ["Username", "Phone"]
      ..phoneContryCode = "CM"
      ..promoCampaigns = ["cash_prize", "cut1", "bet1_get1", "welcome_back"]
      ..stakeTaxEnabled = false
      ..profitTaxEnabled = false
      ..profitTaxCalculateFromWin = false
      ..popularMatchesGroups = {
        1: [
          //sportId
          {'key': "BMG_1X2", 'name': '1X2'},
          {'key': "BMG_GGNG", 'name': 'GG / NG'},
          {'key': "BMG_TOTAL_25", 'name': 'TOTAL (2.5)'},
          {'key': "BMG_DC_INV", 'name': 'DC'},
          {'key': "BMG_HSH_INV", 'name': 'MOST GOALS'}
        ],
        2: [
          {'key': "BMG_1X2", 'name': '1X2'},
        ]
      }
      ..enableLongGroups = false
      ..prematchTabs = [1, 2, 0, 3] //[Sports,Popular,Tournaments]
      ..stakeButtons = ["100", "500", "5000", "50000", "MAX"]
      ..imageLocation = "assets/images/koolbet/"
      ..secondSplash = false
      ..ageLimitInYear = 21
      ..regOnlyAgeInput = false
      ..passwordValidation = {
        'length': [4, 20],
        'must_digit': true,
        'must_letter': true,
        'must_uppercase': false,
        'must_lowercase': false,
        'must_have_char': false,
        'not_allow_spaces': true,
      }
      ..sisDogsEnabled = true
      ..sisHorsesEnabled = true
      ..cashInternalNameDeposit = ""
      ..cashInternalNameWithdraw = ""
      ..goldenRaceEnabled = false
      ..goldenRaceOnlyAuth = false
      ..goldenRaceMenuTitle = "Golden Race Games"
      ..goldenRaceUnAuthId = '1801529e-eab1-4a2e-9313-88571fd42021'
      ..tvbetIframeUrl = "https://tvbetframe22.com"
      ..tvBetClientId = "3943"
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
