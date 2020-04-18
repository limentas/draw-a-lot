import 'dart:math';

import 'package:flutter/material.dart';

Future<Color> showColorPickDialog(
    BuildContext context,
    double y,
    double buttonSize,
    Color currentColor,
    List<Color> colorsToChoiceFrom) async {
  return showGeneralDialog<Color>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Color.fromARGB(0, 1, 1, 1),
      transitionDuration: Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) {
        return new Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.only(top: y),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: listButtonsForDialog(
                        MediaQuery.of(context).size.width,
                        buttonSize,
                        currentColor,
                        colorsToChoiceFrom))));
      });
}

List<Widget> listButtonsForDialog(double screenWidth, double buttonSize,
    Color currentColor, List<Color> colorsToChoiceFrom) {
  var res = List<Widget>();

  for (var color in colorsToChoiceFrom)
    res.add(ColorButton(color, buttonSize, color == currentColor));

  return res;
}

class ColorButton extends StatelessWidget {
  ColorButton(this.color, this.buttonSize, this.toggled);

  final Color color;
  final double buttonSize;
  final double _defaultElevation = 3;
  final bool toggled;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(1),
        child: ButtonTheme(
            padding: EdgeInsets.all(0),
            height: buttonSize,
            minWidth: buttonSize,
            child: RaisedButton(
              color: color,
              materialTapTargetSize: buttonSize < 48
              ? MaterialTapTargetSize.shrinkWrap
              : MaterialTapTargetSize.padded,
              highlightColor: Colors.yellowAccent[100],
              elevation: _defaultElevation,
              focusElevation: _defaultElevation,
              hoverElevation: _defaultElevation * 3,
              highlightElevation: 0,
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(buttonSize))),
              onPressed: () {
                Navigator.of(context).pop(color);
              },
            )));
  }
}
