import 'package:flutter/material.dart';
import '../../redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'myBonusItemProfile.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class MyBonusProfile extends StatefulWidget {
  const MyBonusProfile({Key? key}) : super(key: key);
  @override
  State<MyBonusProfile> createState() => MyBonusProfileState();
}

class MyBonusProfileState extends State<MyBonusProfile> {
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          List bonusArray = state.bonusBalance[0]['bonusBalances']
              .where((e) => e['availableAmount'] > 0 ? true : false)
              .toList();
          bonusArray.sort((a, b) => a["activeTill"].compareTo(b["activeTill"]));
          return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: ListView(children: [
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(LocaleKeys.myBonuses.tr(),
                        style: TextStyle(
                            fontSize: 17.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: bonusArray.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return MyBonusItemProfile(
                          bonusData: bonusArray[index],
                          activeBonus: state.activeBonus);
                    })
              ]));
        });
  }
}
