import 'dart:math';

import 'package:flutter/material.dart';

Future<double> showThicknessDialog(
    BuildContext context, double x, double y) async {
  return showGeneralDialog<double>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Color.fromARGB(0, 1, 1, 1),
      transitionDuration: Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) {
        return new Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.only(left: x, top: y),
                child: Row(
                    children: listButtonsForDialog(
                        x, MediaQuery.of(context).size.width))));
      });
}

List<Widget> listButtonsForDialog(double x, double width) {
  var res = List<Widget>();
  final minimumButtonWidth = 48.0;

  var buttonsCount =
      min(max(((width - x - 20) / minimumButtonWidth).floor(), 1), 12);
  final buttonSize = max(minimumButtonWidth, (width - x - 20) / buttonsCount);

  if (buttonsCount > 11) res.add(ThicknessButton(1, buttonSize));
  if (buttonsCount > 10) res.add(ThicknessButton(2, buttonSize));
  if (buttonsCount > 5) res.add(ThicknessButton(4, buttonSize));
  if (buttonsCount > 4) res.add(ThicknessButton(6, buttonSize));
  if (buttonsCount > 3) res.add(ThicknessButton(8, buttonSize));
  if (buttonsCount > 2) res.add(ThicknessButton(12, buttonSize));
  if (buttonsCount > 1) res.add(ThicknessButton(16, buttonSize));
  if (buttonsCount >= 0) res.add(ThicknessButton(20, buttonSize));
  if (buttonsCount > 6) res.add(ThicknessButton(24, buttonSize));
  if (buttonsCount > 7) res.add(ThicknessButton(28, buttonSize));
  if (buttonsCount > 8) res.add(ThicknessButton(36, buttonSize));
  if (buttonsCount > 9) res.add(ThicknessButton(48, buttonSize));

  return res;
}

class ThicknessButton extends StatelessWidget {
  ThicknessButton(this.thickness, this.buttonSize);

  final double thickness;
  final double buttonSize;
  final double _defaultElevation = 3;

  @override
  Widget build(BuildContext context) {
    final preferedTextSize = buttonSize - 20 - 48;
    final textSize = min(max(preferedTextSize, 15.0), 24);

    return ButtonTheme(
        padding: EdgeInsets.all(0),
        height: buttonSize,
        minWidth: buttonSize,
        child: RaisedButton(
            color: Colors.white,
            elevation: _defaultElevation,
            focusElevation: _defaultElevation,
            hoverElevation: _defaultElevation * 3,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            onPressed: () {
              Navigator.of(context).pop(thickness);
            },
            child: SizedBox(
                width: buttonSize * 0.55,
                height: buttonSize + textSize - preferedTextSize - 5,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  SizedBox(height: 5),
                  Expanded(
                      child: Container(
                    height: thickness,
                    width: thickness,
                    padding: EdgeInsets.all(0),
                    decoration: ShapeDecoration(
                        color: Colors.blueGrey[900],
                        shape: CircleBorder(
                            side: BorderSide(
                                style: BorderStyle.none,
                                color: Colors.blueGrey[900],
                                width: thickness /
                                    MediaQuery.of(context).devicePixelRatio))),
                  )),
                  SizedBox(height: 5),
                  Text("${thickness.toStringAsFixed(0)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: textSize)),
                  SizedBox(height: 5),
                ]))));
  }
}
