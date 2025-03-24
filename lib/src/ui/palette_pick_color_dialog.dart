import 'dart:math';

import 'package:flutter/material.dart';

Future<Color?> showColorPickDialog(
  BuildContext context,
  double y,
  double buttonSize,
  Color currentColor,
  List<Color> colorsToChoiceFrom,
) async {
  return showGeneralDialog<Color>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    barrierColor: Color.fromARGB(0, 0, 0, 0),
    transitionDuration: Duration(milliseconds: 100),
    pageBuilder: (context, animation, secondaryAnimation) {
      final minSideIndent = buttonSize + 12;
      //Button size must be not more than buttonSize * 2
      var pickButtonSize = min(buttonSize, buttonSize * 2);
      var colors = listButtonsForDialog(
        pickButtonSize,
        currentColor,
        colorsToChoiceFrom,
      );
      var columnsCount =
          MediaQuery.of(context).size.width - 2 * minSideIndent >
                  colors.length * pickButtonSize
              ? colors.length
              : (colors.length / 2).ceil();
      var sideIndent =
          (MediaQuery.of(context).size.width -
                  (pickButtonSize + 1) * columnsCount) /
              2 -
          20 * 5;
      //Indent must not be less than minSideIndent
      sideIndent = max(minSideIndent, sideIndent);

      return new Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(
          top: 0,
          left: sideIndent + 10,
          right: sideIndent - 10,
        ),
        child: GridView.count(
          crossAxisCount: columnsCount,
          padding: EdgeInsets.all(8),
          mainAxisSpacing: 5,
          crossAxisSpacing: 3,
          shrinkWrap: true,
          children: colors,
        ),
      );
    },
  );
}

List<Widget> listButtonsForDialog(
  double buttonSize,
  Color currentColor,
  List<Color> colorsToChoiceFrom,
) {
  return colorsToChoiceFrom
      .map((color) => ColorButton(color, buttonSize, color == currentColor))
      .toList();
}

class ColorButton extends StatelessWidget {
  ColorButton(this.color, this.buttonSize, this.toggled);

  final Color color;
  final double buttonSize;
  final double _defaultElevation = 4;
  final bool toggled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: ButtonTheme(
        padding: EdgeInsets.all(0),
        height: buttonSize,
        minWidth: buttonSize,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            overlayColor: Colors.yellowAccent.shade400,
            tapTargetSize:
                buttonSize < 48
                    ? MaterialTapTargetSize.shrinkWrap
                    : MaterialTapTargetSize.padded,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(buttonSize)),
            ),
          ).copyWith(
            elevation:
                WidgetStateProperty.fromMap(<WidgetStatesConstraint, double>{
                  WidgetState.any: _defaultElevation,
                  WidgetState.hovered: _defaultElevation * 3,
                  WidgetState.pressed | WidgetState.selected: 0,
                }),
          ),
          child: null,
          onPressed: () {
            Navigator.of(context).pop(color);
          },
        ),
      ),
    );
  }
}
