import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import '../redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../drawerWidget/MyDrawer.dart';
//import 'dart:convert';
//import 'redux/reducer.dart';
import '../redux/actions.dart';
import 'myBetsListItem.dart';
import 'myBetsListItemSettled.dart';
//import '../Utils/stomp.dart' as stomp;
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class MyBets extends StatefulWidget {
  final ticketsType;
  const MyBets({Key? key, this.ticketsType}) : super(key: key);
  @override
  State<MyBets> createState() => MyBetsState();
}

class MyBetsState extends State<MyBets> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  dynamic unsubscribeMyBetsTickets;

  initState() {
    super.initState();
    /*if (stomp.stompClientMyBets.connected) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => onConnect());
    }*/
  }

  /*void onConnect() {
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
  }*/

  @override
  void dispose() {
    super.dispose();
  }

  drawMybetsList(List tickets) {
    List data = [];
    tickets.forEach((e) => {
          if (e['ticketStatus'] != 5 && e['ticketStatus'] != 7) {data.add(e)}
        });
    if (data.length > 0) {
      data.sort((a, b) => a["acceptedTime"].compareTo(b["acceptedTime"]));
    }
    return data.reversed.toList();
  }

  drawMybetsListSettled(List tickets) {
    List data = [];
    tickets.forEach((e) => {
          if (e['ticketStatus'] == 5 || e['ticketStatus'] == 7) {data.add(e)}
        });
    if (data.length > 0) {
      data.sort((a, b) => a["acceptedTime"].compareTo(b["acceptedTime"]));
    }
    return data.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          List tickets = widget.ticketsType == 0
              ? drawMybetsList(state.myBetsTickets)
              : drawMybetsListSettled(state.myBetsTickets);
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(widget.ticketsType == 0
                  ? LocaleKeys.openBets.tr()
                  : LocaleKeys.settledBets.tr()),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () => {Navigator.pop(context)}),
              actions: <Widget>[LoginAction()],
            ),
            body: Container(
              child: !state.authorization
                  ? Center(child: Text(LocaleKeys.loginToSeeBets.tr()))
                  : tickets.length > 0
                      ? Container(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.builder(
                              itemCount: tickets.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return widget.ticketsType == 0
                                    ? MyBetsListItem(
                                        ticketData: tickets[index],
                                        key: Key(tickets[index]['ticketNbr']))
                                    : MyBetsListItemSettled(
                                        ticketData: tickets[index],
                                        key: Key(tickets[index]['ticketNbr']));
                              }))
                      : Center(child: CircularProgressIndicator()),
            ),
            drawer: MyDrawer(),
          );
        });
  }
}
