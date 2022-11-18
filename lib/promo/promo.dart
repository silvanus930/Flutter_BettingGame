import 'package:flutter/material.dart';
import 'promoItem.dart';
import '../../config/defaultConfig.dart' as config;
import '../Utils/loginAction.dart';
import '../../redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../drawerWidget/MyDrawer.dart';
import '../drawerWidget/MyDrawerUnAuth.dart';

class Promo extends StatefulWidget {
  final from;
  const Promo({Key? key, this.from}) : super(key: key);
  @override
  State<Promo> createState() => PromoState();
}

class PromoState extends State<Promo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Image.asset(config.imageLocation + "logo/logo_header.png",
                  fit: BoxFit.contain, height: 32),
              leading: widget.from == 1
                  ? new IconButton(
                      icon: new Icon(Icons.arrow_back),
                      onPressed: () => {Navigator.pop(context)})
                  : new IconButton(
                      icon: new Icon(Icons.menu),
                      onPressed: () =>
                          {_scaffoldKey.currentState!.openDrawer()}),
              actions: <Widget>[
                LoginAction(),
              ],
            ),
            body: Container(
                padding: EdgeInsets.all(10.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ListView(children: [
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: config.promoCampaigns.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return PromoItem(
                          promoName: config.promoCampaigns[index],
                        );
                      })
                ])),
            drawer: !state.authorization ? MyDrawerUnAuth() : MyDrawer(),
          );
        });
  }
}
