import 'dart:math';

import 'package:flutter/material.dart';

import 'palette_button.dart';

class PalettePanel extends StatelessWidget {
  PalettePanel(Color? color, this._onColorChanged)
      : _color = color != null ? color : Colors.red;

  final void Function(Color) _onColorChanged;
  final Color _color;

  final _whiteColorButtonKey = GlobalKey<PaletteButtonState>();
  final _redColorButtonKey = GlobalKey<PaletteButtonState>();
  final _deepOrangeColorButtonKey = GlobalKey<PaletteButtonState>();
  final _orangeColorButtonKey = GlobalKey<PaletteButtonState>();
  final _yellowColorButtonKey = GlobalKey<PaletteButtonState>();
  final _limeColorButtonKey = GlobalKey<PaletteButtonState>();
  final _lightGreenColorButtonKey = GlobalKey<PaletteButtonState>();
  final _greenColorButtonKey = GlobalKey<PaletteButtonState>();
  final _tealColorButtonKey = GlobalKey<PaletteButtonState>();
  final _cyanColorButtonKey = GlobalKey<PaletteButtonState>();
  final _lightBlueColorButtonKey = GlobalKey<PaletteButtonState>();
  final _indigoColorButtonKey = GlobalKey<PaletteButtonState>();
  final _deepPurpleColorButtonKey = GlobalKey<PaletteButtonState>();
  final _purpleColorButtonKey = GlobalKey<PaletteButtonState>();
  final _pinkColorButtonKey = GlobalKey<PaletteButtonState>();
  final _brownColorButtonKey = GlobalKey<PaletteButtonState>();
  final _blackColorButtonKey = GlobalKey<PaletteButtonState>();

  void _updateSelectedColor(Color newColor) {
    _onColorChanged(newColor);
    _whiteColorButtonKey.currentState?.updateSelectedColor(newColor);
    _redColorButtonKey.currentState?.updateSelectedColor(newColor);
    _deepOrangeColorButtonKey.currentState?.updateSelectedColor(newColor);
    _orangeColorButtonKey.currentState?.updateSelectedColor(newColor);
    _yellowColorButtonKey.currentState?.updateSelectedColor(newColor);
    _limeColorButtonKey.currentState?.updateSelectedColor(newColor);
    _lightGreenColorButtonKey.currentState?.updateSelectedColor(newColor);
    _greenColorButtonKey.currentState?.updateSelectedColor(newColor);
    _tealColorButtonKey.currentState?.updateSelectedColor(newColor);
    _cyanColorButtonKey.currentState?.updateSelectedColor(newColor);
    _lightBlueColorButtonKey.currentState?.updateSelectedColor(newColor);
    _indigoColorButtonKey.currentState?.updateSelectedColor(newColor);
    _deepPurpleColorButtonKey.currentState?.updateSelectedColor(newColor);
    _purpleColorButtonKey.currentState?.updateSelectedColor(newColor);
    _pinkColorButtonKey.currentState?.updateSelectedColor(newColor);
    _brownColorButtonKey.currentState?.updateSelectedColor(newColor);
    _blackColorButtonKey.currentState?.updateSelectedColor(newColor);
  }

  List<Color> listAllMaterialColors(
    MaterialColor color, {
    MaterialAccentColor? accent,
  }) {
    if (accent == null)
      return [
        color.shade50,
        color.shade100,
        color.shade200,
        color.shade300,
        color.shade400,
        color.shade500,
        color.shade600,
        color.shade700,
        color.shade800,
        color.shade900,
      ];
    else
      return [
        accent.shade100,
        accent.shade200,
        accent.shade400,
        accent.shade700,
        color.shade50,
        color.shade100,
        color.shade200,
        color.shade300,
        color.shade400,
        color.shade500,
        color.shade600,
        color.shade700,
        color.shade800,
        color.shade900,
      ];
  }

  List<Color> listGreyscale() {
    return [
      Colors.grey.shade50,
      Colors.grey.shade100,
      Colors.grey.shade200,
      Colors.grey.shade300,
      Colors.grey.shade400,
      Colors.grey.shade500,
      Colors.grey.shade600,
      Colors.grey.shade700,
      Colors.grey.shade800,
      Colors.grey[850]!,
      Colors.grey.shade900,
      Colors.black,
    ];
  }

  @override
  Widget build(BuildContext context) {
    var buttonSize = max(
      48.0,
      min(
        MediaQuery.of(context).size.height / 9 - 10,
        (MediaQuery.of(context).size.width - 90) / 14 - 2,
      ),
    );
    //return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
    return SizedBox(
      width: buttonSize,
      child: Stack(
        children: [
          ListView(
            children: <Widget>[
              SizedBox(height: buttonSize / 2),
              PaletteButton(
                myColor: Colors.white,
                selectedColor: _color,
                colorsToChoiseFrom: [],
                key: _whiteColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.red,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.red,
                  accent: Colors.redAccent,
                ),
                key: _redColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.deepOrange,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.deepOrange,
                  accent: Colors.deepOrangeAccent,
                ),
                key: _deepOrangeColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.orange,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.orange,
                  accent: Colors.orangeAccent,
                ),
                key: _orangeColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.yellow,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.yellow,
                  accent: Colors.yellowAccent,
                ),
                key: _yellowColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.lime,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.lime,
                  accent: Colors.limeAccent,
                ),
                key: _limeColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.lightGreen,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.lightGreen,
                  accent: Colors.lightGreenAccent,
                ),
                key: _lightGreenColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.green,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.green,
                  accent: Colors.greenAccent,
                ),
                key: _greenColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.teal,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.teal,
                  accent: Colors.tealAccent,
                ),
                key: _tealColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.cyan,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.cyan,
                  accent: Colors.cyanAccent,
                ),
                key: _cyanColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.lightBlue,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.lightBlue,
                  accent: Colors.lightBlueAccent,
                ),
                key: _lightBlueColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.indigo,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.indigo,
                  accent: Colors.indigoAccent,
                ),
                key: _indigoColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.deepPurple,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.deepPurple,
                  accent: Colors.deepPurpleAccent,
                ),
                key: _deepPurpleColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.purple.shade800,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.purple,
                  accent: Colors.purpleAccent,
                ),
                key: _purpleColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.pink,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(
                  Colors.pink,
                  accent: Colors.pinkAccent,
                ),
                key: _pinkColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.brown,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(Colors.brown),
                key: _brownColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.black,
                selectedColor: _color,
                colorsToChoiseFrom: listGreyscale(),
                key: _blackColorButtonKey,
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              SizedBox(height: buttonSize / 2),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                height: 24,
                width: 500,
                color: Colors.white54,
              ),
              Positioned(
                  top: -8,
                  child: Icon(Icons.keyboard_arrow_up_rounded, size: 40))
            ]),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                height: 24,
                width: 500,
                color: Colors.white54,
              ),
              Positioned(
                  top: -8, // Icon is bigger than Container - shift it up
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 40))
            ]),
          ),
        ],
      ),
    );
  }
}
