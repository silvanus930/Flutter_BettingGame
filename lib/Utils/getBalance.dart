import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../config/defaultConfig.dart' as config;

class GetBalance extends StatefulWidget {
  const GetBalance({Key? key}) : super(key: key);

  @override
  GetBalanceState createState() => GetBalanceState();
}

class GetBalanceState extends State<GetBalance> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          /*getBonusSize() {
            double bonus = 0;
            if (state.bonusBalance.length > 0 &&
                state.bonusBalance[0]['bonusBalances'].length > 0) {
              state.bonusBalance[0]['bonusBalances']
                  .forEach((e) => {bonus += e['availableAmount']});
            }
            return bonus;
          }*/

          //double bonus = getBonusSize();

          double balance = state.authorization && state.bonusBalance.length > 0
              ? state.bonusBalance[0]['realAvailableAmount'] -
                  state.bonusBalance[0]['totalReservedAmount']
              : -1;

          return Text(
            '${balance > 0 ? balance.toStringAsFixed(2) : "..."} ${config.showCurrencyLogo ? "" : state.currency}',
            style: TextStyle(color: Colors.white),
          );
        });
  }
}
