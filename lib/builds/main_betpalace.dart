import './flavor_config.dart';
import '../main.dart';
import 'package:flutter/material.dart';

void main() {
  mainCommon(
    FlavorConfig()
      ..appTitle = "BetPalace"
      ..flavorName = "betpalace"
      ..apiEndpoint = {
        Endpoints.items: "random.api.dev/items",
        Endpoints.details: "random.api.dev/item"
      }
      ..supportedLocale = ['en']
      ..showCurrencyLogo = false
      ..showSlides = true
      ..hostname = "api20.betpalace.co.ke"
      ..protocol = "https"
      ..versionUrl = "appres.betpalace.co.ke"
      ..linkShareDomainUrl = "www.betpalace.co.ke"
      ..tawkDirectChatLink =
          "https://tawk.to/chat/611e23a2d6e7610a49b0eddc/1fdermd6j"
      ..whatsappLinkUrl = ""
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
      ..loginTemplates = ["Phone"]
      ..phoneContryCode = "KE"
      ..promoCampaigns = ["betpalace_cashout", "betpalace_refund_on_lost"]
      ..stakeTaxEnabled = true
      ..profitTaxEnabled = true
      ..profitTaxCalculateFromWin = false
      ..stakeTaxPercent = 7.5
      ..profitTaxPercent = 20
      ..stakeTaxName = "Exc. Tax"
      ..profitTaxName = "WHT  Tax"
      ..profitTaxMinIncome = 1000
      ..popularMatchesGroups = {
        1: [
          //sportId
          {'key': "BMG_1X2", 'name': '1X2'},
          {'key': "BMG_GGNG", 'name': 'GG / NG'},
        ],
        2: [
          {'key': "BMG_1X2", 'name': '1X2'},
        ]
      }
      ..enableLongGroups = false
      ..goldenRaceEnabled = false
      ..goldenRaceOnlyAuth = false
      ..goldenRaceMenuTitle = "Golden Race Games"
      ..goldenRaceUnAuthId = '198f2608-e3c3-49ba-8019-a76cdde39de9'
      ..tvbetIframeUrl = "https://tvbetframe20.com"
      ..tvBetClientId = "4244"
      ..tvBetEnabled = true
      ..prematchTabs = [1, 2, 0, 3] //[Sports,Popular,Tournaments, SIS]
      ..stakeButtons = ["20", "50", "100", "500", "MAX"]
      ..imageLocation = "assets/images/betpalace/"
      ..secondSplash = false
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
      ..tvbetIframeUrl = "https://tvbetframe20.com"
      ..tvBetClientId = "4244"
      ..tvBetEnabled = true
      ..superJackpotEnabled = false
      ..theme = ThemeData(
        scaffoldBackgroundColor: const Color(0xFFD3D3D3),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white, // Text color
          ),
        ),
        primaryColor: Colors.white,
        hintColor: Colors.grey,
        primarySwatch: Colors.grey,
        tabBarTheme: TabBarTheme(labelColor: Colors.white),
        canvasColor: Color(0xFFD3D3D3),
        primaryTextTheme: TextTheme(
            subtitle1: TextStyle(fontSize: 15.0, color: Colors.grey),
            subtitle2: TextStyle(fontSize: 12.0, color: Colors.grey),
            bodyText2: TextStyle(color: Color(0xFFFEA52C), fontSize: 15),
            headline5: TextStyle(color: Colors.blue, fontSize: 15),
            headline6: TextStyle(color: Colors.white),
            caption: TextStyle(fontSize: 12, color: Color(0xFFFEA52C))),
        cardTheme: CardTheme(
            color: Color(0xFF858585),
            shadowColor: Colors.black.withOpacity(0.1)),
        cardColor: Color(0xFF858585),
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: Color(0xFFFEA52C)),
        indicatorColor: Color(0xFFFEA52C),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFEA52C), foregroundColor: Colors.black),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          backgroundColor: Color(0xFF858585),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        secondaryHeaderColor: Color(0xFFFEA52C),
        colorScheme: ColorScheme.light(
          secondary: Color(0xFFFEA52C),
          onSecondary: Color(0xFF575969),
          secondaryVariant: Color(0xFF858585),
          background: const Color(0xFF000000),
          onBackground: const Color(0xFF858585),
          primary: Color(0xFF343743),
          onPrimary: const Color(0xFF343743),
          primaryVariant: Colors.white,
          surface: Color(0xFF000000),
          onSurface: Color(0xFF575969),
          brightness: Brightness.dark,
        ),
        bottomAppBarColor: Color(0xFF343743),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF343743),
          elevation: 10,
          selectedItemColor: Color(0xFFFEA52C),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
        ),
      ),
  );
}
