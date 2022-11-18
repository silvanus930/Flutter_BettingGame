import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class ErrorDialog extends StatefulWidget {
  const ErrorDialog({Key? key}) : super(key: key);

  @override
  ErrorDialogState createState() => ErrorDialogState();
}

class ErrorDialogState extends State<ErrorDialog> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return AlertDialog(
            title: Text(LocaleKeys.unadleLoadData.tr()),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(LocaleKeys.noInternetConnection.tr()),
                  SizedBox(height: 10),
                  Center(child: CircularProgressIndicator())
                ],
              ),
            ),
          );
        });
  }
}
