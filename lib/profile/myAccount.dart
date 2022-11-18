import 'package:flutter/material.dart';
import 'package:flutter_betting_app/Utils/loginAction.dart';
import '/redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'myBonus/myBonusProfile.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/defaultConfig.dart' as config;

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  MyAccountState createState() => MyAccountState();
}

class MyAccountState extends State<MyAccount> {
  getFieldName(String name) {
    switch (name) {
      case "firstname":
        return LocaleKeys.firstName.tr();
      case "lastname":
        return LocaleKeys.lastName.tr();
      case "date_of_birth":
        return LocaleKeys.dateOfBirth.tr();
      case "phone":
        return LocaleKeys.phoneNumber.tr();
      case "email":
        return LocaleKeys.email.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          getBonusSize() {
            double bonus = 0;
            if (state.bonusBalance[0]['bonusBalances'].length > 0) {
              state.bonusBalance[0]['bonusBalances']
                  .forEach((e) => {bonus += e['availableAmount']});
            }
            return bonus.toStringAsFixed(2);
          }

          double balance = state.authorization && state.bonusBalance.length > 0
              ? state.bonusBalance[0]['realAvailableAmount'] -
                  state.bonusBalance[0]['totalReservedAmount']
              : -1;

          return Scaffold(
            appBar: AppBar(
              title: Text(LocaleKeys.myAccount.tr()),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: <Widget>[LoginAction()],
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 40.0,
                                  backgroundColor:
                                      Theme.of(context).indicatorColor,
                                  child: Text(
                                    state.userData[0]['firstname'] != ""
                                ? state.userData[0]['firstname'][0]
                                    .toUpperCase()
                                : state.userData[0]['email'] != null
                                    ? state.userData[0]['email'][0]
                                        .toUpperCase()
                                    : state.userData[0]['username'][0],
                                    style: TextStyle(
                                        fontSize: 40.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface),
                                  ),
                                ),
                                Positioned(
                                  child: GestureDetector(
                                    onTap: () {
                                      debugPrint('Clicked edit image');
                                    },
                                    child: CircleAvatar(
                                        radius: 12,
                                        child: Icon(Icons.edit, size: 15)),
                                  ),
                                  right: 2.0,
                                  bottom: 0.0,
                                ),
                              ]),
                              SizedBox(height: 20),
                              Text(
                                  '${state.userData[0]['firstname']} ${state.userData[0]['lastname']}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary))
                            ])
                      ]),
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Color(0xFF464750)),
                                bottom: BorderSide(color: Color(0xFF464750)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  LocaleKeys.deposit.tr(),
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  balance.toStringAsFixed(2),
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                )
                              ],
                            ))),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF464750)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  LocaleKeys.bonus.tr(),
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  getBonusSize(),
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                )
                              ],
                            )))
                  ],
                ),
                Expanded(
                    child: ListView(shrinkWrap: true, children: [
                  Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        LocaleKeys.accountDetails.tr(),
                        style: TextStyle(fontSize: 20.0, color: Colors.grey),
                      )),
                  for (var item in config.profileFields)
                    ListTile(
                      title: Text(
                        getFieldName(item),
                        style: TextStyle(fontSize: 15.0, color: Colors.grey),
                      ),
                      subtitle: Text(
                        state.userData[0]['$item'] != null
                            ? state.userData[0]['$item']
                            : "",
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                ])),
              ],
            ),
            floatingActionButton: state.bonusBalance[0]['bonusBalances']
                        .where((e) => e['availableAmount'] > 0 ? true : false)
                        .toList()
                        .length >
                    0
                ? Container(
                    child: FittedBox(
                      child: Stack(
                        alignment: Alignment(1.2, -1.1),
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) => MyBonusProfile(),
                              );
                            },
                            child: Icon(Icons.card_giftcard),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                  state.bonusBalance[0]['bonusBalances']
                                      .where((e) => e['availableAmount'] > 0
                                          ? true
                                          : false)
                                      .toList()
                                      .length
                                      .toString(),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)),
                            ),
                            padding: EdgeInsets.all(4),
                            constraints:
                                BoxConstraints(minHeight: 16, minWidth: 25),
                            decoration: BoxDecoration(
                              // This controls the shadow
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    color: Colors.black.withAlpha(50))
                              ],
                              borderRadius: BorderRadius.circular(16),
                              color: Colors
                                  .redAccent, // This would be color of the Badge
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          );
        });
  }
}
