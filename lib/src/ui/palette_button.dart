import 'package:flutter/material.dart';

import 'palette_pick_color_dialog.dart';

class PaletteButton extends StatefulWidget {
  PaletteButton({
    required Color myColor,
    required Color selectedColor,
    required List<Color> colorsToChoiseFrom,
    required double buttonSize,
    Key? key,
    required void Function(Color) onPressed,
  })  : _myColor = myColor,
        _selectedColor = selectedColor,
        _colorsToChoiseFrom = colorsToChoiseFrom,
        _onPressed = onPressed,
        _buttonSize = buttonSize,
        super(key: key);

  final Color _myColor;
  final Color _selectedColor;
  final List<Color> _colorsToChoiseFrom;
  final void Function(Color) _onPressed;
  final double _buttonSize;

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
  late bool selected;

  @override
  Widget build(BuildContext context) {
    final buttonSize = selected ? widget._buttonSize * 0.7 : widget._buttonSize;
    return Padding(
      padding: EdgeInsets.all(1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size.square(buttonSize),
          backgroundColor: currentColor,
          shape: CircleBorder(),
          tapTargetSize: widget._buttonSize < 48
              ? MaterialTapTargetSize.shrinkWrap
              : MaterialTapTargetSize.padded,
        ).copyWith(
          elevation:
              WidgetStateProperty.fromMap(<WidgetStatesConstraint, double>{
            WidgetState.any: _defaultButtonElevation,
            WidgetState.pressed | WidgetState.selected: _toggledButtonElevation,
          }),
        ),
        child: null,
        onPressed: () {
          widget._onPressed(currentColor);
        },
        onLongPress: () {
          if (widget._colorsToChoiseFrom.isEmpty) return;

          widget._onPressed(currentColor);

          RenderBox box = context.findRenderObject() as RenderBox;
          var colorFuture = showColorPickDialog(
            context,
            box.localToGlobal(Offset.zero).dy -
                (widget._buttonSize - buttonSize) / 2,
            widget._buttonSize,
            currentColor,
            widget._colorsToChoiseFrom,
          );
          colorFuture.then((color) {
            if (color != null)
              setState(() {
                currentColor = color;
              });
            widget._onPressed(currentColor);
          });
        },
      ),
    );
  }
}
