import './flavor_config.dart';
import '../main.dart';
import 'package:flutter/material.dart';

void main() {
  mainCommon(
    FlavorConfig()
      ..appTitle = "Grandbet"
      ..flavorName = "grandbet"
      ..apiEndpoint = {
        Endpoints.items: "random.api.dev/items",
        Endpoints.details: "random.api.dev/item"
      }
      ..showSlides = false
      ..supportedLocale = ['en']
      ..showCurrencyLogo = true
      ..hostname =
          "api21.grandbet.et" //demo7.pbt.com.mt demo7.bet24.live mieeq-app.koolbet237.com
      ..versionUrl = "appres.grandbet.et"
      ..protocol = "https"
      ..linkShareDomainUrl = "www.grandbet.et"
      ..tawkDirectChatLink =
          "https://tawk.to/chat/60e5f30b649e0a0a5ccb0cbb/1fa13qq9g"
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
      }
      ..phoneContryCode = "ET"
      ..promoCampaigns = ["cashout", "refund_on_lost"]
      ..whatsappLinkUrl = ""
      ..loginTemplates = ["Username", "Phone"]
      ..popularMatchesGroups = {
        1: [
          {'key': "BMG_1X2", 'name': '1X2'},
          {'key': "BMG_GGNG", 'name': 'GG / NG'}
        ],
        2: [
          {'key': "BMG_1X2", 'name': '1X2'},
        ]
      }
      ..enableLongGroups = true
      ..prematchTabs = [0, 1, 2]
      ..stakeButtons = ["20", "50", "100", "1000", "MAX"]
      ..imageLocation = "assets/images/grandbet/"
      ..secondSplash = true
      ..stakeTaxEnabled = true
      ..profitTaxEnabled = true
      ..profitTaxCalculateFromWin = false
      ..stakeTaxPercent = 15
      ..profitTaxPercent = 15
      ..profitTaxMinIncome = 1000
      ..stakeTaxName = "VAT"
      ..profitTaxName = "Income Tax"
      ..profitTaxMinIncome = 1000
      ..taxedTicketTypes = ["0", "1", "2"]
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
      ..sisDogsEnabled = false
      ..sisHorsesEnabled = false
      ..cashInternalNameDeposit = "Shop deposit"
      ..cashInternalNameWithdraw = "Shop withdraw"
      ..goldenRaceEnabled = true
      ..goldenRaceOnlyAuth = false
      ..goldenRaceMenuTitle = "Grand Virtual"
      ..goldenRaceUnAuthId = '3294f1c6-993a-4a64-b2e2-1550e3d3f376'
      ..tvbetIframeUrl = ""
      ..tvBetClientId = ""
      ..tvBetEnabled = false
      ..superJackpotEnabled = true
      ..theme = ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.grey[400],
        hintColor: Colors.grey,
        canvasColor: Colors.grey,
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: Color(0xFF1B7D01)),
        primarySwatch: Colors.grey,
        secondaryHeaderColor: Colors.white,
        primaryTextTheme: TextTheme(
            subtitle1: TextStyle(fontSize: 15.0, color: Colors.black87),
            subtitle2: TextStyle(fontSize: 12.0, color: Colors.black87),
            bodyText2: TextStyle(color: Colors.white, fontSize: 15),
            headline5: TextStyle(color: Colors.red, fontSize: 15),
            headline6: TextStyle(color: Colors.white),
            caption: TextStyle(fontSize: 12, color: Colors.white)),
        cardTheme: CardTheme(
            color: Colors.grey, shadowColor: Colors.grey.withOpacity(0.1)),
        cardColor: Colors.grey,
        tabBarTheme: TabBarTheme(labelColor: Colors.white),
        indicatorColor: Color(0xFF1B7D01),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1B7D01), foregroundColor: Colors.white),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          backgroundColor: Color(0xFF1B7D01),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.light(
            secondary: Color(0xFF000000),
            onSecondary: Color(0xFF1B7D01),
            secondaryVariant: Color(0xFF1B7D01),
            background: Color(0xFF1B7D01),
            onBackground: Color(0xFFB5B5B5),
            primary: const Color(0xFF1B7D01),
            onPrimary: const Color(0xFF000000),
            primaryVariant: Colors.white,
            brightness: Brightness.light,
            surface: Color(0xFFeeeeee),
            onSurface: Colors.grey),
        bottomAppBarColor: Color(0xFF1B7D01),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1B7D01),
          elevation: 10,
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
        ),
      ),
  );
}
