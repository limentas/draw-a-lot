import 'dart:math';

import 'package:flutter/material.dart';

Future<double?> showThicknessDialog(
  BuildContext context,
  double x,
  double y,
  double currentThickness,
) async {
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
              x,
              MediaQuery.of(context).size.width,
              currentThickness,
            ),
          ),
        ),
      );
    },
  );
}

List<Widget> listButtonsForDialog(
  double x,
  double width,
  double currentThickness,
) {
  var res = List<Widget>.empty(growable: true);

  const minimumButtonWidth = 52.0;
  const maximumButtonWidth = 100.0;
  final availableSpace = width - x;
  final buttonsCount = min(
    max((availableSpace / minimumButtonWidth).floor(), 1.0),
    12.0,
  );
  final buttonSize = min(max(minimumButtonWidth, availableSpace / buttonsCount),
      maximumButtonWidth);

  print(
      "listButtonsForDialog ${x}, ${width}, ${minimumButtonWidth}, ${buttonSize}, ${buttonsCount}");

  if (buttonsCount > 11)
    res.add(ThicknessButton(1, buttonSize, currentThickness == 1));
  if (buttonsCount > 10)
    res.add(ThicknessButton(2, buttonSize, currentThickness == 2));
  if (buttonsCount > 5)
    res.add(ThicknessButton(4, buttonSize, currentThickness == 4));
  if (buttonsCount > 4)
    res.add(ThicknessButton(6, buttonSize, currentThickness == 6));
  if (buttonsCount > 3)
    res.add(ThicknessButton(8, buttonSize, currentThickness == 8));
  if (buttonsCount > 2)
    res.add(ThicknessButton(12, buttonSize, currentThickness == 12));
  if (buttonsCount > 1)
    res.add(ThicknessButton(16, buttonSize, currentThickness == 16));
  if (buttonsCount >= 0)
    res.add(ThicknessButton(20, buttonSize, currentThickness == 20));
  if (buttonsCount > 6)
    res.add(ThicknessButton(24, buttonSize, currentThickness == 24));
  if (buttonsCount > 7)
    res.add(ThicknessButton(28, buttonSize, currentThickness == 28));
  if (buttonsCount > 8)
    res.add(ThicknessButton(36, buttonSize, currentThickness == 36));
  if (buttonsCount > 9)
    res.add(ThicknessButton(48, buttonSize, currentThickness == 48));

  return res;
}

class ThicknessButton extends StatelessWidget {
  ThicknessButton(this.thickness, this.buttonSize, this.toggled);

  final double thickness;
  final double buttonSize;
  final double _defaultElevation = 3;
  final bool toggled;

  @override
  Widget build(BuildContext context) {
    final preferedTextSize = buttonSize - 20 - 48;
    final textSize = min(max(preferedTextSize, 15.0), 24.0);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(0),
        minimumSize: Size(buttonSize, buttonSize),
        maximumSize: Size(buttonSize, 2 * buttonSize),
        backgroundColor: toggled ? Colors.yellowAccent[100] : Colors.white,
        overlayColor: Colors.yellowAccent[100],
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ).copyWith(
        elevation: WidgetStateProperty.fromMap(<WidgetStatesConstraint, double>{
          WidgetState.any: _defaultElevation,
          WidgetState.hovered: _defaultElevation * 3,
          WidgetState.pressed | WidgetState.selected: 0,
        }),
      ),
      onPressed: () {
        Navigator.of(context).pop(thickness);
      },
      child: SizedBox(
        width: buttonSize * 0.55,
        height: buttonSize + textSize - preferedTextSize - 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 5),
            Expanded(
              child: Container(
                height: thickness,
                width: thickness,
                padding: EdgeInsets.all(0),
                decoration: ShapeDecoration(
                  color: Colors.blueGrey.shade900,
                  shape: CircleBorder(
                    side: BorderSide(
                      style: BorderStyle.none,
                      color: Colors.blueGrey.shade900,
                      width:
                          thickness / MediaQuery.of(context).devicePixelRatio,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              "${thickness.toStringAsFixed(0)}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: textSize),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
