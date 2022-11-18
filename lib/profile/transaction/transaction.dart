import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../config/defaultConfig.dart' as config;
import './transactionFilter.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';

class Transaction extends StatefulWidget {
  const Transaction({Key? key}) : super(key: key);

  @override
  TransactionState createState() => TransactionState();
}

class TransactionState extends State<Transaction> {
  List tickets = [];
  String period = 'Today';
  var from;
  var to;
  String ticketType = '';
  bool isLoading = false;
  String timeFormat = "";

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
        'type': ticketType,
        'offset': 0.toString(), // number,
        'limit': 100.toString(), // number,
      };

      final StorageService _storageService = StorageService();
      String? accessToken = await _storageService.readSecureData('token');

      if (accessToken!.length > 0) {
        var url = Uri(
          scheme: config.protocol,
          host: config.hostname,
          path: 'betting-api-gateway/user/rest/statistics/history',
          queryParameters: getParams,
        );

        await http.get(url, headers: {
          "content-type": "application/json",
          "Authorization": accessToken
        }).then((response) {
          if (response.statusCode == 200) {
            var result = jsonDecode(response.body);
            if (result['response'] != null) {
              setState(() {
                tickets = result['response']['history'];
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

  Widget _showTable() {
    List<DataRow> rows = [];

    tickets.forEach((e) {
      rows.add(DataRow(cells: [
        DataCell(
          Text(e['typeName'], style: TextStyle(fontSize: 9)),
        ),
        DataCell(
          Text('${e['amount']}', style: TextStyle(fontSize: 9)),
        ),
        DataCell(
          Text(
              DateFormat(timeFormat)
                  .format(DateTime.fromMillisecondsSinceEpoch(e['createdAt']))
                  .toString(),
              style: TextStyle(fontSize: 9)),
        ),
      ]));
    });

    return DataTable(columns: <DataColumn>[
      DataColumn(
        label: Text(
          LocaleKeys.ticketNumber.tr(),
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
        ),
      ),
      DataColumn(
        label: Text(
          LocaleKeys.amount.tr(),
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
        ),
      ),
      DataColumn(
        label: Text(
          LocaleKeys.date.tr(),
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
        ),
      ),
    ], rows: rows);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (config.timeFormat[context.locale.toString()] == 0) {
            timeFormat = "MM/dd/yyyy' 'h:mma";
          } else {
            timeFormat = "MM/dd/yyyy' 'HH:mm:ss";
          }
          return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.transaction.tr()),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: <Widget>[LoginAction()],
              ),
              body: Column(
                children: [
                  TransactionFilter(dateChnaged: (to, from, period, type) {
                    dateChnaged(to, from, period, type);
                  }),
                  tickets.length > 0 && !isLoading
                      ? Expanded(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: _showTable()))
                      : isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Text(LocaleKeys.noTransactionFound.tr(),
                                  style: TextStyle(color: Colors.white)))
                ],
              ));
        });
  }
}
