import 'dart:math';

import 'package:flutter/material.dart';

class PaletteButton extends StatefulWidget {
  PaletteButton(Color color, Color selectedColor,
      {Key key, void Function(Color) onPressed})
      : _myColor = color,
        _selectedColor = selectedColor,
        _onPressed = onPressed,
        super(key: key);

  final Color _myColor;
  final Color _selectedColor;
  final void Function(Color) _onPressed;

  @override
  PaletteButtonState createState() =>
      PaletteButtonState(_myColor, _selectedColor);
}

class PaletteButtonState extends State<PaletteButton> {
  PaletteButtonState(Color myColor, Color selectedColor)
      : selectedColor = selectedColor {
    selected = selectedColor == myColor;
  }

  final double _defaultButtonElevation = 5.0;
  final double _toggledButtonElevation = 0.0;

  void updateSelectedColor(Color selectedColor) {
    setState(() {
      selectedColor = selectedColor;
      selected = selectedColor == widget._myColor;
    });
  }

  Color selectedColor;
  bool selected;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = min(60, MediaQuery.of(context).size.height / 9 - 10);
    return ButtonTheme(
        height: selected ? buttonHeight / 1.3 : buttonHeight,
        minWidth: 40,
        child: RaisedButton(
          color: widget._myColor,
          shape: CircleBorder(),
          materialTapTargetSize: buttonHeight < 48 ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
          elevation:
              selected ? _toggledButtonElevation : _defaultButtonElevation,
          focusElevation:
              selected ? _toggledButtonElevation : _defaultButtonElevation,
          hoverElevation:
              selected ? _toggledButtonElevation : _defaultButtonElevation,
          highlightElevation: _toggledButtonElevation,
          onPressed: () {
            widget._onPressed(widget._myColor);
          },
        ));
  }
}
