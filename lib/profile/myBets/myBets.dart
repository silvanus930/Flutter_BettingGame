import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:convert';
import 'myBetsFilter.dart';
import 'myBetsCard.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../config/defaultConfig.dart' as config;
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';

class MyBets extends StatefulWidget {
  const MyBets({Key? key}) : super(key: key);

  @override
  MyBetsState createState() => MyBetsState();
}

class MyBetsState extends State<MyBets> {
  List tickets = [];
  String period = 'Today';
  var from;
  var to;
  String ticketType = 'All';
  bool isLoading = false;

  void dateChnaged(toDate, fromDate, periodDate, type) {
    setState(() {
      to = toDate;
      from = fromDate;
      period = periodDate;
      ticketType = type;
    });

    fetchTickets();
  }

  void fetchTickets() async {
    if (from != null && to != null) {
      setState(() {
        isLoading = true;
      });

      final getParams = {
        'from': DateFormat("yyyy-MM-dd' 'HH:mm:ss '+0300'")
            .format(from)
            .toString(), // date (format "yyyy-MM-dd HH:mm:ss"),
        'till': DateFormat("yyyy-MM-dd' 'HH:mm:ss '+0300'")
            .format(to)
            .toString(), // date (format "yyyy-MM-dd HH:mm:ss"),
        'category':
            ticketType, // string enum { All, Won, Lost, Canceled, Open, PendingForApproval },
        'sortingField':
            'DateCreated', // string enum { TicketNumber, DateCreated },
        'sortingValue': 'Desc', // string enum { Asc, Desc },
        'offset': 0.toString(), // number,
        'limit': 100.toString(), // number,
      };

      final StorageService _storageService = StorageService();
      String? accessToken = await _storageService.readSecureData('token');

      if (accessToken!.length > 0) {
        var url = Uri(
          scheme: config.protocol,
          host: config.hostname,
          path: 'betting-api-gateway/user/rest/statistics/tickets',
          queryParameters: getParams,
        );

        await http.get(url, headers: {
          "content-type": "application/json",
          "Authorization": accessToken
        }).then((response) {
          if (response.statusCode == 200) {
            var result = jsonDecode(response.body);
            if (result['response']['tickets'] != null) {
              setState(() {
                tickets = result['response']['tickets'];
                isLoading = false;
              });
            } else {
              tickets = [];
              isLoading = false;
            }
          } else {
            tickets = [];
            isLoading = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.myBets.tr()),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: <Widget>[LoginAction()],
              ),
              body: Column(
                children: [
                  MyBetsFilter(dateChnaged: (to, from, period, type) {
                    dateChnaged(to, from, period, type);
                  }),
                  tickets.length > 0 && !isLoading
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: tickets.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return MyBetsCard(
                                    key: UniqueKey(),
                                    ticketData: tickets[index]);
                              }))
                      : isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Text(LocaleKeys.noBetsPeriod.tr(),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)))
                ],
              ));
        });
  }
}
