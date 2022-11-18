import 'package:flutter/material.dart';

enum Endpoints { items, details }

class FlavorConfig {
  late String appTitle;
  late Map<Endpoints, String> apiEndpoint;
  late String imageLocation;
  late ThemeData theme;
  late String hostname;
  late String protocol;
  late Map popularMatchesGroups;
  late List prematchTabs;
  late String versionUrl;
  late List stakeButtons;
  late String linkShareDomainUrl;
  late Map signUpFields;
  late List loginTemplates;
  late String tawkDirectChatLink;
  late List supportedLocale;
  late bool secondSplash;
  late String phoneContryCode;
  late String whatsappLinkUrl;
  late String flavorName;
  late List promoCampaigns;
  late bool showSlides;
  late bool stakeTaxEnabled;
  late bool profitTaxEnabled;
  late bool profitTaxCalculateFromWin;
  late double stakeTaxPercent;
  late double profitTaxPercent;
  late double profitTaxMinIncome;
  late String stakeTaxName;
  late String profitTaxName;
  late List taxedTicketTypes;
  late List profileFields;
  late Map timeFormat;
  late bool showCurrencyLogo;
  late bool regOnlyAgeInput;
  late Map passwordValidation;
  late int ageLimitInYear;
  late bool enableLongGroups;
  late bool sisDogsEnabled;
  late bool sisHorsesEnabled;
  late String cashInternalNameDeposit;
  late String cashInternalNameWithdraw;
  late bool goldenRaceEnabled;
  late bool goldenRaceOnlyAuth;
  late String goldenRaceMenuTitle;
  late String goldenRaceUnAuthId;
  late String tvbetIframeUrl;
  late String tvBetClientId;
  late bool tvBetEnabled;
  late bool superJackpotEnabled;
  FlavorConfig();
}
