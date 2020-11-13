import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'palette_button.dart';

class PalettePanel extends StatelessWidget {
  PalettePanel(this.onColorChanged);

  final void Function(Color) onColorChanged;

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

  final Color _startColor = Colors.lightBlue;

  void _updateSelectedColor(Color newColor) {
    onColorChanged(newColor);
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

  List<Color> listAllMaterialColors(MaterialColor color,
      {MaterialAccentColor accent}) {
    if (accent == null)
      return [
        color[50],
        color[100],
        color[200],
        color[300],
        color[400],
        color[500],
        color[600],
        color[700],
        color[800],
        color[900]
      ];
    else
      return [
        accent[100],
        accent[200],
        accent[400],
        accent[700],
        color[50],
        color[100],
        color[200],
        color[300],
        color[400],
        color[500],
        color[600],
        color[700],
        color[800],
        color[900]
      ];
  }

  List<Color> listGreyscale() {
    return [
      Colors.grey[50],
      Colors.grey[100],
      Colors.grey[200],
      Colors.grey[300],
      Colors.grey[400],
      Colors.grey[500],
      Colors.grey[600],
      Colors.grey[700],
      Colors.grey[800],
      Colors.grey[900],
      Colors.black,
    ];
  }

  @override
  Widget build(BuildContext context) {
    var buttonSize = max(
        48.0,
        min(MediaQuery.of(context).size.height / 9 - 10,
            (MediaQuery.of(context).size.width - 90) / 14 - 2));
    //return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
    print("buttonSize = $buttonSize");
    return SizedBox(
        width: buttonSize,
        child: Stack(children: [
          ListView(children: <Widget>[
            SizedBox(height: buttonSize / 2),
            PaletteButton(
              myColor: Colors.white,
              selectedColor: _startColor,
              colorsToChoiseFrom: null,
              key: _whiteColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.red,
              selectedColor: _startColor,
              colorsToChoiseFrom:
                  listAllMaterialColors(Colors.red, accent: Colors.redAccent),
              key: _redColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.deepOrange,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.deepOrange,
                  accent: Colors.deepOrangeAccent),
              key: _deepOrangeColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.orange,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.orange,
                  accent: Colors.orangeAccent),
              key: _orangeColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.yellow,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.yellow,
                  accent: Colors.yellowAccent),
              key: _yellowColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.lime,
              selectedColor: _startColor,
              colorsToChoiseFrom:
                  listAllMaterialColors(Colors.lime, accent: Colors.limeAccent),
              key: _limeColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.lightGreen,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.lightGreen,
                  accent: Colors.lightGreenAccent),
              key: _lightGreenColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.green,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.green,
                  accent: Colors.greenAccent),
              key: _greenColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.teal,
              selectedColor: _startColor,
              colorsToChoiseFrom:
                  listAllMaterialColors(Colors.teal, accent: Colors.tealAccent),
              key: _tealColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.cyan,
              selectedColor: _startColor,
              colorsToChoiseFrom:
                  listAllMaterialColors(Colors.cyan, accent: Colors.cyanAccent),
              key: _cyanColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.lightBlue,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.lightBlue,
                  accent: Colors.lightBlueAccent),
              key: _lightBlueColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.indigo,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.indigo,
                  accent: Colors.indigoAccent),
              key: _indigoColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.deepPurple,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.deepPurple,
                  accent: Colors.deepPurpleAccent),
              key: _deepPurpleColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.purple[800],
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.purple,
                  accent: Colors.purpleAccent),
              key: _purpleColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.pink,
              selectedColor: _startColor,
              colorsToChoiseFrom:
                  listAllMaterialColors(Colors.pink, accent: Colors.pinkAccent),
              key: _pinkColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.brown,
              selectedColor: _startColor,
              colorsToChoiseFrom: listAllMaterialColors(Colors.brown),
              key: _brownColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            PaletteButton(
              myColor: Colors.black,
              selectedColor: _startColor,
              colorsToChoiseFrom: listGreyscale(),
              key: _blackColorButtonKey,
              buttonSize: buttonSize,
              onPressed: (color) {
                _updateSelectedColor(color);
              },
            ),
            SizedBox(height: buttonSize / 2),
          ]),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                  height: 20,
                  width: 500,
                  color: Colors.white54,
                  child: SvgPicture.asset("icons/keyboard_arrow_up-24px.svg"))),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  height: 20,
                  width: 500,
                  color: Colors.white54,
                  child:
                      SvgPicture.asset("icons/keyboard_arrow_down-24px.svg"))),
        ]));
  }
}
