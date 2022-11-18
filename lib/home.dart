import 'package:flutter/material.dart';
import 'package:flutter_betting_app/promo/promo.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'live.dart';
import 'prematch.dart';
import 'livechat.dart';
import 'bsForm.dart';
import 'profile/myBonus/myBonusProfile.dart';
import 'redux/app_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'redux/actions.dart';
import '../config/defaultConfig.dart' as config;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Utils/errorDialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Utils/stomp.dart' as stomp;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_betting_app/presentation/app_icons.dart';
import '../models/storage_item.dart';
import 'services/storage_service.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}

late String? firebaseToken;

class Home extends StatefulWidget {
  final store;
  const Home({Key? key, this.store}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic unsubscribeBetDomainData;
  String lastCheckedVer = "";
  late final FirebaseMessaging _messaging;
  late var _notificationInfo;
  int _totalNotifications = 0;

  checkForInitialMessage() async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == "bonus") {
        _showAppBonusNotification(
          message.data,
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == "bonus") {
        _showAppBonusNotification(message.data);
      }
    });

    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    firebaseToken = await FirebaseMessaging.instance.getToken();
    debugPrint(firebaseToken);
    debugPrint('token');

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );
      debugPrint(initialMessage.notification?.title);
      debugPrint(initialMessage.notification?.body);
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  Future<void> _showAppBonusNotification(Map msg) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AcceptedCustomAlert(msg));
  }

  final StorageService _storageService = StorageService();

  void handleBonusBalance(int type) async {
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      /*var uri = Uri(
  scheme: 'https',
  host: 'example.com',
  path: '/foo/bar',
  fragment: 'baz',
  queryParameters: _yourQueryParameters,
);*/
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/profile/balance-new'));

      try {
        await http.get(url, headers: {
          "content-type": "application/json",
          "Authorization": accessToken
        }).then((response) async {
          if (response.statusCode == 200) {
            if (widget.store.state.showErrorDialog) {
              widget.store
                  .dispatch(SetShowErrorDialogAction(showErrorDialog: false));
            }

            if (type == 1 && !widget.store.state.authorization) {
              var userId = await _storageService.readSecureData('userId');
              widget.store
                  .dispatch(SetUserIdAction(userId: int.parse(userId!)));
              widget.store
                  .dispatch(SetAuthorizationAction(authorization: true));
            }
            var result = jsonDecode(response.body);

            widget.store.dispatch(
                SetBonusBalanceAction(bonusBalance: [result['response']]));
            if (result['response']['bonusBalances'].firstWhere(
                    (e) => e['type'] == 'Xmas',
                    orElse: () => null) !=
                null) {
              var xmasBonus = await _storageService.readSecureData('xmasBonus');
              if (xmasBonus == 'true') {
                _storageService
                    .writeSecureData(StorageItem('xmasBonus', 'true'));
                _showXmasBonusDialog(result['response']['bonusBalances']
                    .firstWhere((e) => e['type'] == 'Xmas')['availableAmount']);
              }
            }
          } else {
            if (!widget.store.state.showErrorDialog) {
              widget.store
                  .dispatch(SetShowErrorDialogAction(showErrorDialog: true));
            }
            reassignTokenRequest();
            debugPrint('failed to load balance1');
          }
        });
      } on Exception catch (_) {
        if (!widget.store.state.showErrorDialog) {
          widget.store
              .dispatch(SetShowErrorDialogAction(showErrorDialog: true));
        }
        debugPrint('failed to load balance');
      }
    }
  }

  handleLogout() async {
    final StorageService _storageService = StorageService();
    await _storageService.writeSecureData(StorageItem('token', ''));
    await _storageService.writeSecureData(StorageItem('userId', ''));
    widget.store.dispatch(SetAuthorizationAction(authorization: false));
    timer.cancel();
  }

  getArrayOdds() {
    switch (widget.store.state.racesSportName) {
      case "":
        return widget.store.state.odds.length.toString();
      case "horses":
        return widget.store.state.horsesOdds.length.toString();
      case "dogs":
        return widget.store.state.dogsOdds.length.toString();
      default:
        return widget.store.state.odds.length.toString();
    }
  }

  void reassignTokenRequest() async {
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/security/reassign-token'));
      try {
        Map data = {'token': accessToken.replaceAll("Bearer ", '')};
        var body = json.encode(data);
        await http
            .post(url,
                headers: {
                  "content-type": "application/json",
                },
                body: body)
            .then((response) async {
          var result = jsonDecode(response.body);
          if (response.statusCode == 200) {
            _storageService.writeSecureData(
                StorageItem('token', "Bearer " + result['response']['token']));
            var userId = await _storageService.readSecureData('userId');
            widget.store.dispatch(SetUserIdAction(userId: int.parse(userId!)));
            widget.store.dispatch(SetAuthorizationAction(authorization: true));

            debugPrint('token updated');
          } else if (result['response']['faultCode'] == 126) {
            handleLogout();
            if (widget.store.state.showErrorDialog) {
              widget.store
                  .dispatch(SetShowErrorDialogAction(showErrorDialog: false));
            }
          }
        });
      } on Exception catch (_) {
        debugPrint('Could not reaasign token');
      }
    }
  }

  void handleUserData() async {
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/profile/load'));

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) async {
        var result = jsonDecode(response.body);
        widget.store.dispatch(SetUserDataAction(
            userData: [result['response']['return']['fields']['field']]));

        var frBaseToken = result['response']['return']['fields']['field']
            .firstWhere((e) => e['name'] == 'firebase_token')['value'];

        firebaseToken = await FirebaseMessaging.instance.getToken();

        debugPrint(firebaseToken);

        if (firebaseToken != null && frBaseToken != firebaseToken.toString()) {
          updateFireBaseToken(firebaseToken);
        }
      });
    }
  }

  void updateFireBaseToken(token) async {
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/profile/update'));

      Map userDataObject = widget.store.state.userData[0];

      userDataObject['firebase_token'] = token;

      await http
          .post(url,
              headers: {
                "content-type": "application/json",
                "Authorization": accessToken,
              },
              body: json.encode(userDataObject))
          .then((response) {
        if (response.statusCode == 200) {
          debugPrint('token changed');
        } else {
          debugPrint('failed to changed');
        }
      });
    }
  }

  void handleLimits() async {
    var url = (Uri.parse(
        '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/system/limits'));

    try {
      await http.get(url, headers: {
        "content-type": "application/json",
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);

          widget.store.dispatch(SetLimitsAction(limits: result['response']));

          widget.store.dispatch(
              SetCurrencyAction(currency: result['response']['currency']));
        } else {
          new Future.delayed(const Duration(seconds: 10), handleLimits);
        }
      });
    } on Exception catch (_) {
      debugPrint('Error');
    }
  }

  void handleLimitsAuth() async {
    String? accessToken = await _storageService.readSecureData('token');

    if (accessToken!.length > 0) {
      var url = (Uri.parse(
          '${config.protocol}://${config.hostname}/betting-api-gateway/user/rest/system/limits'));

      await http.get(url, headers: {
        "content-type": "application/json",
        "Authorization": accessToken
      }).then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);

          widget.store.dispatch(SetLimitsAction(limits: result['response']));

          widget.store.dispatch(
              SetCurrencyAction(currency: result['response']['currency']));
        } else {
          new Future.delayed(const Duration(seconds: 10), handleLimitsAuth);
        }
      });
    }
  }

  late Timer timer;
  late Timer timerUpdate;

  checkToken() async {
    var token = await _storageService.readSecureData('token');
    var userId = await _storageService.readSecureData('userId');
    if (userId!.length > 0 && token!.length > 0) {
      handleBonusBalance(1);
      timer = Timer.periodic(new Duration(seconds: 30), (timer) {
        handleBonusBalance(1);
      });
    }
  }

  initState() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });

    checkForInitialMessage();
    //registerNotification();
    super.initState();
    handleLimits();
    checkVersion();
    timerUpdate = Timer.periodic(new Duration(seconds: 10), (timerUpdate) {
      checkVersion();
    });

    checkToken();

    if (widget.store.state.authorization) {
      handleUserData();
    }
  }

  checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var version;
    var currentVerison = packageInfo.version;

    try {
      final response = await http.get(Uri.parse(
          '${config.protocol}://${config.versionUrl}/download/VERSION.txt'));
      if (response.statusCode == 200) {
        if (widget.store.state.showErrorDialog) {
          widget.store
              .dispatch(SetShowErrorDialogAction(showErrorDialog: false));
        }
        version = response.body;
        if (version != currentVerison && lastCheckedVer != version) {
          if (int.parse(version.split('.')[0]) >
              int.parse(currentVerison.split('.')[0])) {
            _showAppUpdateDialog(0);
            timerUpdate.cancel();
            return debugPrint("major");
          }

          if (int.parse(version.split('.')[1]) >
              int.parse(currentVerison.split('.')[1])) {
            _showAppUpdateDialog(1);
            setState(() {
              lastCheckedVer = version;
            });
            return debugPrint("minor");
          }
        }
      } else {
        if (!widget.store.state.showErrorDialog) {
          widget.store
              .dispatch(SetShowErrorDialogAction(showErrorDialog: true));
        }
        debugPrint('Failed to load version file');
      }
    } on Exception catch (_) {
      if (!widget.store.state.showErrorDialog) {
        widget.store.dispatch(SetShowErrorDialogAction(showErrorDialog: true));
      }
      debugPrint('internet connection');
    }
  }

  Future<void> _showErrorDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => ErrorDialog());
  }

  majorUpdate() {
    launch(
        "${config.protocol}://${config.versionUrl}/download/app-${config.flavorName}-release.apk");
    SystemNavigator.pop();
  }

  minorUpdate() {
    launch(
        "${config.protocol}://${config.versionUrl}/download/app-${config.flavorName}-release.apk");
  }

  Future<void> _showAppUpdateDialog(int type) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(LocaleKeys.newUpdate.tr()),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(LocaleKeys.newVersionFile.tr()),
                  ],
                ),
              ),
              actions: <Widget>[
                type == 1
                    ? TextButton(
                        child: const Text('Ignore'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : SizedBox(),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    type == 0 ? majorUpdate() : minorUpdate();
                  },
                ),
              ],
            ));
      },
    );
  }

  Future<void> _showXmasBonusDialog(amount) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: InkWell(
            child: new Stack(
              children: <Widget>[
                Container(
                  child: Image.asset("assets/images/bonuses/xmas_bonus.png",
                      fit: BoxFit.contain),
                ),
                new Positioned.fill(
                  child: new LayoutBuilder(
                    builder: (context, constraints) {
                      return new Padding(
                        padding: new EdgeInsets.only(
                            top: constraints.biggest.height * .370,
                            left: constraints.biggest.height * .48),
                        child: new Text(
                          amount.toStringAsFixed(0),
                          style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  subscribeBetDomains(odds) {
    odds.forEach((odd) => {
          unsubscribeBetDomainData = stomp.stompClient.subscribe(
            destination: '/betdomain/${odd['sport']}/${odd['betDomainId']}',
            headers: {'id': '/betdomain/${odd['sport']}/${odd['betDomainId']}'},
            callback: (frame) {
              var result = jsonDecode(frame.body!);
              if (result['betslipBetdomainDto'] != null) {
                widget.store.dispatch(SetOddsBetDomainInfoAction(
                    oddsBetDomainInfo: result['betslipBetdomainDto']));
              } else if (result['betdomainStatusMessage'] != null) {
                widget.store.dispatch(UpdateStatusOddsBetDomainInfoAction(
                    oddsBetDomainInfo: result['betdomainStatusMessage']));
              } else if (result['status'] == "not found") {
                if (odd['sport'] == 100) {
                  StoreProvider.of<AppState>(context).dispatch(
                      RemoveHorsesOddsAction(horsesOdds: {
                    'match': odd['match'],
                    'oddId': odd['oddId']
                  }));
                } else if (odd['sport'] == 101) {
                  StoreProvider.of<AppState>(context).dispatch(
                      RemoveDogsOddsAction(dogsOdds: {
                    'match': odd['match'],
                    'oddId': odd['oddId']
                  }));
                } else {
                  StoreProvider.of<AppState>(context).dispatch(RemoveOddsAction(
                      odds: {'match': odd['match'], 'oddId': odd['oddId']}));
                }
              }
            },
          )
        });
  }

  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    debugPrint("disconnect");
    //stompClient.deactivate();
    super.dispose();
  }

  genereateFireBaseToken() async {
    await FirebaseMessaging.instance.deleteToken();

    firebaseToken = await FirebaseMessaging.instance.getToken();

    debugPrint(firebaseToken);
  }

  getIcon(type) {
    switch (type) {
      case "TournamentFreebet":
        return CategoryIcon(1, AppIcons.mybets_coins);
      case "First deposit":
        return CategoryIcon(2, AppIcons.bonus_principal);
      case "Regular":
        return CategoryIcon(3, AppIcons.bonus_cashback);
      case "XMAS":
        return CategoryIcon(4, AppIcons.xmas_gift);
      case "WELCOME BONUS":
        return CategoryIcon(5, AppIcons.bonus_welcome);
      default:
        return CategoryIcon(6, Icons.card_giftcard);
    }
  }

  int currentTab = 0; // to keep track of active tab index
  late final List<Widget> screens = [
    Prematch(store: widget.store),
    Live(store: widget.store),
    BSForm(),
    LiveChat()
  ]; // to store nested tabs
  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen =
      Prematch(store: widget.store); // Our first view in viewport

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        distinct: true,
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (viewModel.odds.length > oldViewModel!.odds.length &&
              viewModel.racesSportName == "") {
            subscribeBetDomains(widget.store.state.odds);
          }
          if (viewModel.odds.length < oldViewModel.odds.length &&
              viewModel.racesSportName == "") {
            debugPrint("done remove");
            widget.store.state.oddsBetDomainInfo.forEach((betDomainOdd) => {
                  if (widget.store.state.odds.firstWhere(
                          (element) =>
                              element['betDomainId'] ==
                              betDomainOdd['betDomainId'],
                          orElse: () => null) ==
                      null)
                    {
                      unsubscribeBetDomainData(unsubscribeHeaders: {
                        'id':
                            '/betdomain/${oldViewModel.odds.firstWhere((element) => element['betDomainId'] == betDomainOdd['betDomainId'], orElse: () => null)['sport']}/${betDomainOdd['betDomainId']}'
                      }),
                      widget.store.dispatch(RemoveOddsBetDomainInfoAction(
                          oddsBetDomainInfo: betDomainOdd))
                    }
                });
          }
          if (viewModel.horsesOdds.length > oldViewModel.horsesOdds.length &&
              viewModel.racesSportName == "horses") {
            subscribeBetDomains(widget.store.state.horsesOdds);
          }
          if (viewModel.horsesOdds.length < oldViewModel.horsesOdds.length &&
              viewModel.racesSportName == "horses") {
            widget.store.state.oddsBetDomainInfo.forEach((betDomainOdd) => {
                  if (widget.store.state.horsesOdds.firstWhere(
                          (element) =>
                              element['betDomainId'] ==
                              betDomainOdd['betDomainId'],
                          orElse: () => null) ==
                      null)
                    {
                      unsubscribeBetDomainData(unsubscribeHeaders: {
                        'id':
                            '/betdomain/${oldViewModel.horsesOdds.firstWhere((element) => element['betDomainId'] == betDomainOdd['betDomainId'], orElse: () => null)['sport']}/${betDomainOdd['betDomainId']}'
                      }),
                      widget.store.dispatch(RemoveOddsBetDomainInfoAction(
                          oddsBetDomainInfo: betDomainOdd))
                    }
                });
          }
          if (viewModel.dogsOdds.length > oldViewModel.dogsOdds.length &&
              viewModel.racesSportName == "dogs") {
            subscribeBetDomains(widget.store.state.dogsOdds);
          }
          if (viewModel.dogsOdds.length < oldViewModel.dogsOdds.length &&
              viewModel.racesSportName == "dogs") {
            widget.store.state.oddsBetDomainInfo.forEach((betDomainOdd) => {
                  if (widget.store.state.dogsOdds.firstWhere(
                          (element) =>
                              element['betDomainId'] ==
                              betDomainOdd['betDomainId'],
                          orElse: () => null) ==
                      null)
                    {
                      unsubscribeBetDomainData(unsubscribeHeaders: {
                        'id':
                            '/betdomain/${oldViewModel.dogsOdds.firstWhere((element) => element['betDomainId'] == betDomainOdd['betDomainId'], orElse: () => null)['sport']}/${betDomainOdd['betDomainId']}'
                      }),
                      widget.store.dispatch(RemoveOddsBetDomainInfoAction(
                          oddsBetDomainInfo: betDomainOdd))
                    }
                });
          }
          if (viewModel.authorization != oldViewModel.authorization &&
              viewModel.authorization == true) {
            handleUserData();
            handleLimitsAuth();
            handleBonusBalance(0);
            timer = Timer.periodic(new Duration(seconds: 30), (timer) {
              handleBonusBalance(0);
            });
          }

          if (viewModel.authorization != oldViewModel.authorization &&
              viewModel.authorization == false) {
            timer.cancel();
            genereateFireBaseToken();
            //updateFireBaseToken(null);
            widget.store.dispatch(RemoveUserDataAction(userData: []));
            _storageService.writeSecureData(StorageItem('token', ''));
          }

          if (viewModel.showErrorDialog != oldViewModel.showErrorDialog &&
              viewModel.showErrorDialog == false) {
            Navigator.of(context).pop();
          }

          if (viewModel.showErrorDialog != oldViewModel.showErrorDialog &&
              viewModel.showErrorDialog == true) {
            _showErrorDialog();
          }

          if (viewModel.webSocketReConnect != oldViewModel.webSocketReConnect) {
            if (viewModel.odds.length > 0) {
              subscribeBetDomains(viewModel.odds);
            }
          }
        },
        builder: (context, state) {
          getBonusSize() {
            double bonus = 0;
            if (state.bonusBalance.length > 0 &&
                state.bonusBalance[0]['bonusBalances'].length > 0) {
              state.bonusBalance[0]['bonusBalances']
                  .forEach((e) => {bonus += e['availableAmount']});
            }
            if (bonus.toInt().toString().length == 4) {
              {
                return '${bonus.toString()[0]}k+';
              }
            }
            if (bonus.toInt().toString().length == 5) {
              {
                return '${bonus.toString().substring(0, 2)}k+';
              }
            }
            if (bonus.toInt().toString().length == 6) {
              {
                return '${bonus.toString().substring(0, 3)}k+';
              }
            }
            return bonus.toInt().toString();
          }

          return Scaffold(
            body: PageStorage(
              child: currentScreen,
              bucket: bucket,
            ),
            floatingActionButton: currentTab == 2
                ? null
                : FloatingActionButton(
                    child: Text(getArrayOdds(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (context) => BSForm()));
                    },
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              shape: CircularNotchedRectangle(),
              notchMargin: 10,
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MaterialButton(
                          minWidth: 40,
                          onPressed: () {
                            setState(() {
                              currentScreen = Prematch(
                                  store: widget
                                      .store); // if user taps on this dashboard tab will be active
                              currentTab = 0;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.sports_soccer,
                                color: currentTab == 0
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context)
                                        .colorScheme
                                        .primaryVariant,
                              ),
                              Text(
                                LocaleKeys.prematch.tr(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: currentTab == 0
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        MaterialButton(
                          minWidth: 40,
                          onPressed: () {
                            setState(() {
                              currentScreen = Live(
                                  store: widget
                                      .store); // if user taps on this dashboard tab will be active
                              currentTab = 1;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                AppIcons.badge_LIVE,
                                color: currentTab == 1
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context)
                                        .colorScheme
                                        .primaryVariant,
                              ),
                              Text(
                                LocaleKeys.live.tr(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: currentTab == 1
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    // Right Tab bar icons

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MaterialButton(
                          minWidth: 40,
                          onPressed: () {
                            setState(() {
                              currentScreen = LiveChat();
                              currentTab = 2;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.chat,
                                color: currentTab == 2
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context)
                                        .colorScheme
                                        .primaryVariant,
                              ),
                              Text(
                                LocaleKeys.liveChat.tr(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: currentTab == 2
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        MaterialButton(
                          minWidth: 40,
                          onPressed: () {
                            state.authorization &&
                                    state.bonusBalance.length > 0 &&
                                    state.bonusBalance[0]['bonusBalances']
                                            .length >
                                        0
                                ? showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10),
                                      ),
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    context: context,
                                    builder: (context) => MyBonusProfile(),
                                  )
                                : setState(() {
                                    currentScreen =
                                        Promo(); // if user taps on this dashboard tab will be active
                                    currentTab = 3;
                                  });
                          },
                          child: Stack(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  state.authorization &&
                                          state.bonusBalance.length > 0 &&
                                          state.bonusBalance[0]['bonusBalances']
                                                  .length >
                                              0
                                      ? getIcon(
                                          state.activeBonus.isNotEmpty
                                              ? state.activeBonus['type']
                                              : 0,
                                        ).icon
                                      : Icons.local_offer,
                                  color: currentTab == 3
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryVariant,
                                ),
                                Text(
                                  state.authorization &&
                                          state.bonusBalance.length > 0 &&
                                          state.bonusBalance[0]['bonusBalances']
                                                  .length >
                                              0
                                      ? LocaleKeys.bonuses.tr()
                                      : LocaleKeys.promo.tr(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: currentTab == 3
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primaryVariant,
                                  ),
                                ),
                              ],
                            ),
                            state.authorization &&
                                    state.bonusBalance.length > 0 &&
                                    state.bonusBalance[0]['bonusBalances']
                                            .length >
                                        0
                                ? Positioned(
                                    right: 0,
                                    top: 3,
                                    child: new Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: new BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 12,
                                        minHeight: 12,
                                      ),
                                      child: new Text(
                                        '${getBonusSize()}',
                                        style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : SizedBox()
                          ]),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class CategoryIcon {
  int index;
  IconData icon;

  CategoryIcon(this.index, this.icon);
}

class AcceptedCustomAlert extends StatelessWidget {
  AcceptedCustomAlert(this.msg);
  final Map msg;

  getStringArgs(type) {
    List<String> list = [];
    switch (type) {
      case "TournamentFreebet":
        list = [msg['p2'], msg['p3']];
        return list;
      case "Regular":
        list = [msg['p2'], msg['p3'], msg['p4'], msg['p5']];
        return list;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: new Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor),
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                  child: Column(
                    children: [
                      Text(
                        msg['p4'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).indicatorColor),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        msg['tag'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ).tr(args: getStringArgs(msg['bonustype'])),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).indicatorColor),
                        child: Text(
                          LocaleKeys.ok.tr(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ]),
            Positioned(
                top: -35,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).indicatorColor,
                  radius: 40,
                  child: Icon(
                    AppIcons.xmas_gift,
                    color: Theme.of(context).colorScheme.surface,
                    size: 40,
                  ),
                )),
          ],
        ));
  }
}
