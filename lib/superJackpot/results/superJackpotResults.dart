import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:convert';
import '../../config/defaultConfig.dart' as config;
import 'package:http/http.dart' as http;
import 'jackpotResult.dart';

class SuperJackpotResults extends StatefulWidget {
  final jackpotResultsList;
  const SuperJackpotResults({Key? key, this.jackpotResultsList})
      : super(key: key);

  @override
  SuperJackpotResultsState createState() => SuperJackpotResultsState();
}

class SuperJackpotResultsState extends State<SuperJackpotResults> {
  List jackpotsDataList = [];

  initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => widget.jackpotResultsList.forEach((e) {
              getJackpotData(e['id']);
            }));
  }

  getJackpotData(id) async {
    final getParams = {
      'jackpotId': id.toString(),
      'lang': context.locale.toString()
    };

    var url = Uri(
      scheme: config.protocol,
      host: config.hostname,
      path: 'betting-api-gateway/user/rest/jackpot/get-superjackpot',
      queryParameters: getParams,
    );

    await http.get(url, headers: {"content-type": "application/json"}).then(
        (response) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          jackpotsDataList = [...jackpotsDataList, result['response']];
        });
      } else {
        debugPrint('error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        onWillChange: (oldViewModel, viewModel) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Image.asset(config.imageLocation + "logo/logo_header.png",
                  fit: BoxFit.contain, height: 32),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () => {Navigator.pop(context)}),
              actions: <Widget>[
                LoginAction(),
              ],
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              jackpotsDataList.length > 0
                  ? Container(
                      child: ListView.builder(
                          itemCount: jackpotsDataList.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Container(
                                key: Key("${jackpotsDataList[index]['id']}"),
                                constraints: new BoxConstraints(
                                  minHeight: 50.0,
                                  minWidth: 200.0,
                                ),
                                alignment: Alignment.center,
                                child: JackpotResult(
                                    jackpotResultsData:
                                        jackpotsDataList[index]));
                          }))
                  : Center(child: CircularProgressIndicator())
            ])),
          );
        });
  }
}
