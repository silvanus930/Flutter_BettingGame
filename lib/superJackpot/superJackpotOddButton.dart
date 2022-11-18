import 'package:flutter/material.dart';

class OddButton extends StatefulWidget {
  final odd;
  final sportId;
  final matchId;
  final status;
  final enabled;
  final disabled;
  final Function handleOddButton;

  const OddButton({
    Key? key,
    this.odd,
    this.sportId,
    this.matchId,
    this.status,
    this.enabled,
    this.disabled,
    required this.handleOddButton
  }) : super(key: key);

  @override
  State<OddButton> createState() => OddButtonState();
}

class OddButtonState extends State<OddButton> with TickerProviderStateMixin {
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void handleOddClick() {
      widget.handleOddButton(widget.odd);
    }

    double opacityValue =
        widget.disabled && !widget.enabled  || widget.status == 16
            ? 0.40
            : 1.00;

    return Opacity(
        opacity: opacityValue,
        child: IgnorePointer(
            ignoring: widget.disabled && !widget.enabled ||
                widget.status == 16 ||
                widget.odd['value'] == 0,
            child: InkWell(
                child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.12,
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: widget.enabled
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary)),
                    child: Column(children: [
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(7),
                                topLeft: Radius.circular(7),
                              ),
                              color: widget.enabled
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            widget.odd['tipDetailsWS']['tip'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10.0,
                                color: widget.enabled
                                    ? Theme.of(context).colorScheme.surface
                                    : Colors.white),
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
                    ])),
                onTap: () {
                  handleOddClick();
                })));
  }
}
