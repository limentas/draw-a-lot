import 'dart:math';

import 'package:flutter/material.dart';

import 'palette_pick_color_dialog.dart';
import 'package:draw_a_lot/src/app_config.dart';

class PaletteButton extends StatefulWidget {
  PaletteButton(
      Color myColor, Color selectedColor, List<Color> colorsToChoiseFrom,
      {Key key, void Function(Color) onPressed})
      : _myColor = myColor,
        _selectedColor = selectedColor,
        _colorsToChoiseFrom = colorsToChoiseFrom,
        _onPressed = onPressed,
        super(key: key);

  final Color _myColor;
  final Color _selectedColor;
  final List<Color> _colorsToChoiseFrom;
  final void Function(Color) _onPressed;

  @override
  PaletteButtonState createState() =>
      PaletteButtonState(_myColor, _selectedColor);
}

class PaletteButtonState extends State<PaletteButton> {
  PaletteButtonState(Color myColor, Color selectedColor)
      : selectedColor = selectedColor,
        currentColor = myColor {
    selected = selectedColor == myColor;
  }

  final double _defaultButtonElevation = 5.0;
  final double _toggledButtonElevation = 0.0;

  void updateSelectedColor(Color selectedColor) {
    setState(() {
      selectedColor = selectedColor;
      selected = selectedColor == currentColor;
    });
  }

  Color selectedColor; //color selected from whole palette
  Color currentColor; //color of this button
  bool selected;

  @override
  Widget build(BuildContext context) {
    final buttonSize = max(30.0, MediaQuery.of(context).size.height / 9 - 10);
    final height = selected ? buttonSize * 0.7 : buttonSize;
    return ButtonTheme(
        height: height,
        minWidth: buttonSize,
        child: RaisedButton(
          color: currentColor,
          shape: CircleBorder(),
          materialTapTargetSize: buttonSize < 48
              ? MaterialTapTargetSize.shrinkWrap
              : MaterialTapTargetSize.padded,
          elevation:
              selected ? _toggledButtonElevation : _defaultButtonElevation,
          focusElevation:
              selected ? _toggledButtonElevation : _defaultButtonElevation,
          hoverElevation:
              selected ? _toggledButtonElevation : _defaultButtonElevation,
          highlightElevation: _toggledButtonElevation,
          onPressed: () {
            widget._onPressed(currentColor);
          },
          onLongPress: () {
            if (!AppConfig.fullAccess) return;
            if (widget._colorsToChoiseFrom == null ||
                widget._colorsToChoiseFrom.isEmpty) return;

            RenderBox box = context.findRenderObject();
            var colorFuture = showColorPickDialog(
                context,
                box.localToGlobal(Offset.zero).dy - (buttonSize - height) / 2,
                buttonSize,
                currentColor,
                widget._colorsToChoiseFrom);
            colorFuture.then((color) {
              if (color != null)
                setState(() {
                  currentColor = color;
                });
              widget._onPressed(currentColor);
            });
          },
        ));
  }
}
