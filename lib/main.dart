import 'package:flutter/material.dart';
//import 'package:flutter_betting_app/redux/reducer.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/app_state.dart';
import 'redux/reducer.dart';
import 'home.dart';
import 'package:flutter/services.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import '../config/defaultConfig.dart' as config;
import 'package:easy_localization/easy_localization.dart';
import 'generated/codegen_loader.g.dart';
import 'builds/flavor_config.dart';
import 'config/global_config.dart' as global;
import '/redux/actions.dart';
import 'dart:developer';
import 'dart:async';
import 'Utils/stomp.dart' as stomp;

var flavorConfigProvider;
var timer;
var lang;

void mainCommon(FlavorConfig config) async {
  flavorConfigProvider = config;
  global.config = config;
  const bool isProduction = bool.fromEnvironment('dart.vm.product');

  if (isProduction) {
    debugPrint = (String? message, {int? wrapWidth}) => null;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(EasyLocalization(
      path: 'assets/translations',
      supportedLocales: [
        for (final tab in config.supportedLocale) Locale(tab),
      ],
      assetLoader: CodegenLoader(),
      startLocale: Locale('en'),
      fallbackLocale: Locale('en'),
      child: MyApp()));
}

void onConnect(StompFrame frame) {
  store.dispatch(SetWebSocketReConnectAction(
      webSocketReConnect: store.state.webSocketReConnect + 1));
}

void onDisconnect(error) {
  stomp.stompClient.deactivate();
  timer = Timer.periodic(new Duration(seconds: 2), (timer) {
    if (!store.state.showErrorDialog &&
        !stomp.stompClient.connected &&
        !stomp.stompClientMyBets.connected) {
      stomp.stompClient = StompClient(
        config: StompConfig.SockJS(
            url:
                '${config.protocol}://${config.hostname}/dps/webSocketChanges?lang=$lang&zone=180',
            onConnect: onConnect,
            beforeConnect: () async {
              await Future.delayed(Duration(milliseconds: 200));
            },
            onWebSocketError: (dynamic error) => onDisconnect(error)),
      );

      stomp.stompClientMyBets = StompClient(
        config: StompConfig.SockJS(
          url:
              '${config.protocol}://${config.hostname}//tss/ticketStatusChanges?lang=$lang&zone=180',
          beforeConnect: () async {
            await Future.delayed(Duration(milliseconds: 200));
          },
          onWebSocketError: (dynamic error) =>
              stomp.stompClientMyBets.deactivate(),
        ),
      );
      stomp.stompClient.activate();
      stomp.stompClientMyBets.activate();
      timer.cancel();
    }
  });
}

final Store<AppState> store = Store(reducer,
    initialState: AppState(
        liveInfo: [],
        liveInfoCommon: [],
        liveMatches: [],
        liveMatchesMeta: [],
        odds: [],
        horsesOdds: [],
        dogsOdds: [],
        userId: 0,
        authorization: false,
        bonusBalance: [],
        oddsBetDomainInfo: [],
        matchObj: [],
        limits: {},
        currency: "",
        prematchInfo: [],
        prematchSubscribeList: [],
        prematchUnSubscribeList: [],
        prematchMatch: [],
        prematchBetDomains: [],
        prematchBetdomainsGroup: [],
        matchDetailsMatchData: [],
        matchDetailsBetDomains: [],
        matchDetailsSubscribeList: [],
        matchDetailsUnSubscribeList: [],
        userData: [],
        userDataObj: [],
        myBetsTickets: [],
        activeBonus: {},
        topTournamentList: [],
        selectedTopTournament: {},
        selectedTopTournamentData: {},
        popularMatchesData: [],
        popularMatchesMetaData: [],
        showErrorDialog: false,
        webSocketReConnect: 0,
        racesSportName: "",
        racesTournamentList: [],
        racesTournamentListCommon: []));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (stomp.stompClient != null && stomp.stompClient.connected) {
      stomp.stompClient.deactivate();
    }
    if (stomp.stompClientMyBets != null && stomp.stompClientMyBets.connected) {
      stomp.stompClientMyBets.deactivate();
    }
    lang = context.locale;
    return StoreProvider(
      store: store,
      child: FutureBuilder(
          future: Init.instance.initialize(),
          builder: (context, AsyncSnapshot snapshot) {
            // Show splash screen while waiting for app resources to load:
            if (snapshot.connectionState == ConnectionState.waiting &&
                store.state.webSocketReConnect == 0) {
              return MaterialApp(
                  theme: flavorConfigProvider.theme,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: Splash());
            } else if (config.secondSplash &&
                store.state.webSocketReConnect == 1) {
              // Loading is done, return the app:
              return FutureBuilder(
                  future: Future.delayed(Duration(seconds: 3)),
                  builder: (c, s) => s.connectionState == ConnectionState.done
                      ? MaterialApp(
                          title: flavorConfigProvider.appTitle,
                          theme: flavorConfigProvider.theme,
                          localizationsDelegates: context.localizationDelegates,
                          supportedLocales: context.supportedLocales,
                          locale: context.locale,
                          home: Home(store: store),
                        )
                      : MaterialApp(
                          theme: flavorConfigProvider.theme,
                          localizationsDelegates: context.localizationDelegates,
                          supportedLocales: context.supportedLocales,
                          locale: context.locale,
                          home: SecondSplash()));
            } else {
              return MaterialApp(
                title: flavorConfigProvider.appTitle,
                theme: flavorConfigProvider.theme,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: Home(store: store),
              );
            }
          }),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Image.asset(flavorConfigProvider.imageLocation + "logo/logo.png",
                fit: BoxFit.contain, height: 60),
            SizedBox(height: 20),
            CircularProgressIndicator()
          ])),
    );
  }
}

class SecondSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Image.asset(
              flavorConfigProvider.imageLocation + "logo/logo2.gif",
              height: MediaQuery.of(context).size.height * 0.50,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            Text(
              "Welcome to GrandBet",
              style: TextStyle(fontSize: 20),
            )
          ])),
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    stomp.stompClient = StompClient(
      config: StompConfig.SockJS(
          url:
              '${config.protocol}://${config.hostname}/dps/webSocketChanges?lang=$lang&zone=180',
          onConnect: onConnect,
          beforeConnect: () async {
            await Future.delayed(Duration(milliseconds: 200));
          },
          onWebSocketError: (dynamic error) => onDisconnect(error)),
    );

    stomp.stompClientMyBets = StompClient(
      config: StompConfig.SockJS(
        url:
            '${config.protocol}://${config.hostname}//tss/ticketStatusChanges?lang=$lang&zone=180',
        beforeConnect: () async {
          await Future.delayed(Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) =>
            stomp.stompClientMyBets.deactivate(),
      ),
    );
    stomp.stompClient.activate();
    stomp.stompClientMyBets.activate();
    await Future.delayed(Duration(seconds: 3));
  }
}
