import 'package:flutter/material.dart';


class OddButtonResult extends StatefulWidget {
  final odd;

  const OddButtonResult({
    Key? key,
    this.odd,
  }) : super(key: key);

  @override
  State<OddButtonResult> createState() => OddButtonResultState();
}

class OddButtonResultState extends State<OddButtonResult> with TickerProviderStateMixin {
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.12,
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: widget.odd['won']
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary)),
                    child: Column(children: [
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(7),
                                topLeft: Radius.circular(7),
                              ),
                              color: widget.odd['won']
                                  ? Colors.green
                                  : Colors.red),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            widget.odd['tipDetailsWS']['tip'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10.0,
                                ),
                          )),
                      SizedBox(height: 5),
                      widget.odd['value'] != 0
                          ? Text(
                              widget.odd['odd'].toString(),
                              style: TextStyle(color: Colors.white),
                            )
                          : Icon(
                              Icons.lock,
                              color: Colors.grey,
                              size: 15.0,
                              semanticLabel: 'value 0',
                            ),
                    ]));
                
  }
}
