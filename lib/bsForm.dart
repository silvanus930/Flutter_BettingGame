import 'package:flutter/material.dart';
import 'package:flutter_betting_app/betslip.dart';
import 'package:flutter_betting_app/myBets/myBets.dart';
import 'betslip/myBonus/myBonus.dart';
import '../../redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'betslip/couponCheck.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_betting_app/presentation/app_icons.dart';
import 'dart:convert';
import '../redux/actions.dart';
import '../Utils/stomp.dart' as stomp;

class BSForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BSFormState();
  }
}

class _BSFormState extends State<BSForm> {
  void onTabTapped(int index) {
    if (index < 3) {
      setState(() {
        currentIndex = index;
      });
    } else {
      if (index == 3) {
        showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          isScrollControlled: true,
          backgroundColor: Colors.white,
          context: context,
          builder: (context) => CouponCheck(),
        );
      }
      if (index == 4) {
        showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          isScrollControlled: true,
          backgroundColor: Colors.white,
          context: context,
          builder: (context) => MyBonus(),
        );
      }
    }
  }

  dynamic unsubscribeMyBetsTickets;
  int currentIndex = 1;
  bool showDrawer = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final List<Widget> children = [
    MyBets(ticketsType: 0),
    Betslip(),
    MyBets(ticketsType: 1),
  ];

  void onConnect() {
    unsubscribeMyBetsTickets = stomp.stompClientMyBets.subscribe(
      destination:
          '/tickets/${StoreProvider.of<AppState>(context).state.userId}',
      headers: {'id': 'MyBets'},
      callback: (frame) {
        var result = jsonDecode(frame.body!);
        if (result['tickets'] != null) {
          StoreProvider.of<AppState>(context).dispatch(
              SetMyBetsTicketsAction(myBetsTickets: result['tickets']));
        }
      },
    );
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

  initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) =>
        stomp.stompClientMyBets.connected &&
                StoreProvider.of<AppState>(context).state.authorization
            ? onConnect()
            : null);
  }

  @override
  void dispose() {
    if (unsubscribeMyBetsTickets != null) {
      unsubscribeMyBetsTickets(unsubscribeHeaders: {'id': 'MyBets'});
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {
          if (oldViewModel!.authorization != viewModel.authorization &&
              viewModel.authorization) {
            onConnect();
          }
        },
        builder: (context, state) {
          getBonusSize() {
            double bonus = 0;
            if (state.bonusBalance.length > 0 &&
                state.bonusBalance[0]['bonusBalances']
                        .where((e) =>
                            e['availableAmount'] > 0 && e['type'] != 'TVBETCODE'
                                ? true
                                : false)
                        .toList()
                        .length >
                    0) {
              state.bonusBalance[0]['bonusBalances']
                  .where((e) =>
                      e['availableAmount'] > 0 && e['type'] != 'TVBETCODE'
                          ? true
                          : false)
                  .toList()
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
            key: _scaffoldKey,
            body: children[currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onTabTapped,
              currentIndex:
                  currentIndex, // this will be set when a new tab is tapped
              items: state.authorization &&
                      state.bonusBalance.length > 0 &&
                      state.bonusBalance[0]['bonusBalances']
                              .where((e) => e['availableAmount'] > 0 &&
                                      e['type'] != 'TVBETCODE'
                                  ? true
                                  : false)
                              .toList()
                              .length >
                          0
                  ? [
                      BottomNavigationBarItem(
                        icon: new Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              new Icon(Icons.published_with_changes),
                              new Positioned(
                                right: -5,
                                top: -5,
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
                                    '${state.myBetsTickets.where((e) => e['ticketStatus'] != 5 && e['ticketStatus'] != 7).length}',
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ]),
                        label: LocaleKeys.openBets.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: new Icon(Icons.shopping_cart),
                        label: LocaleKeys.betslip.tr(),
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.history),
                          label: LocaleKeys.history.tr()),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.confirmation_number),
                          label: LocaleKeys.coupon.tr()),
                      BottomNavigationBarItem(
                          icon: new Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                new Icon(
                                    getIcon(
                                      state.activeBonus.isNotEmpty
                                          ? state.activeBonus['type']
                                          : 0,
                                    ).icon,
                                    color: Colors.green),
                                Positioned(
                                  right: -5,
                                  top: -5,
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
                              ]),
                          label: LocaleKeys.myBonus.tr())
                    ]
                  : [
                      BottomNavigationBarItem(
                        icon: new Stack(children: <Widget>[
                          new Icon(Icons.published_with_changes),
                          new Positioned(
                            right: 0,
                            child: new Container(
                              padding: EdgeInsets.all(1),
                              decoration: new BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: new Text(
                                '${state.myBetsTickets.where((e) => e['ticketStatus'] != 5 && e['ticketStatus'] != 7).length}',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ]),
                        label: LocaleKeys.openBets.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: new Icon(Icons.shopping_cart),
                        label: LocaleKeys.betslip.tr(),
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.history),
                          label: LocaleKeys.history.tr()),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.confirmation_number),
                          label: LocaleKeys.coupon.tr())
                    ],
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
