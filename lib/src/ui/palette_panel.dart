import 'package:flutter/material.dart';

import 'palette_button.dart';

class PalettePanel extends StatelessWidget {
  PalettePanel(this.onColorChanged);

  final void Function(Color) onColorChanged;

  final _whiteColorButtonKey = GlobalKey<PaletteButtonState>();
  final _redColorButtonKey = GlobalKey<PaletteButtonState>();
  final _orangeColorButtonKey = GlobalKey<PaletteButtonState>();
  final _yellowColorButtonKey = GlobalKey<PaletteButtonState>();
  final _greenColorButtonKey = GlobalKey<PaletteButtonState>();
  final _lightBlueColorButtonKey = GlobalKey<PaletteButtonState>();
  final _blueColorButtonKey = GlobalKey<PaletteButtonState>();
  final _purpleColorButtonKey = GlobalKey<PaletteButtonState>();
  final _blackColorButtonKey = GlobalKey<PaletteButtonState>();

  final Color _startColor = Colors.lightBlue;

  void _updateSelectedColor(Color newColor) {
    onColorChanged(newColor);
    _whiteColorButtonKey.currentState.updateSelectedColor(newColor);
    _redColorButtonKey.currentState.updateSelectedColor(newColor);
    _orangeColorButtonKey.currentState.updateSelectedColor(newColor);
    _yellowColorButtonKey.currentState.updateSelectedColor(newColor);
    _greenColorButtonKey.currentState.updateSelectedColor(newColor);
    _lightBlueColorButtonKey.currentState.updateSelectedColor(newColor);
    _blueColorButtonKey.currentState.updateSelectedColor(newColor);
    _purpleColorButtonKey.currentState.updateSelectedColor(newColor);
    _blackColorButtonKey.currentState.updateSelectedColor(newColor);
  }

  List<Color> listAllMaterialColors(MaterialColor color) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      const SizedBox(height: 15),
      PaletteButton(
        Colors.white,
        _startColor,
        null,
        key: _whiteColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.red,
        _startColor,
        listAllMaterialColors(Colors.red),
        key: _redColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.orange,
        _startColor,
        listAllMaterialColors(Colors.orange),
        key: _orangeColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.yellow,
        _startColor,
        listAllMaterialColors(Colors.yellow),
        key: _yellowColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.green,
        _startColor,
        listAllMaterialColors(Colors.green),
        key: _greenColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.lightBlue,
        _startColor,
        listAllMaterialColors(Colors.lightBlue),
        key: _lightBlueColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.blue[900],
        _startColor,
        listAllMaterialColors(Colors.blue),
        key: _blueColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.purple[800],
        _startColor,
        listAllMaterialColors(Colors.purple),
        key: _purpleColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const Spacer(),
      PaletteButton(
        Colors.black,
        _startColor,
        null,
        key: _blackColorButtonKey,
        onPressed: (color) {
          _updateSelectedColor(color);
        },
      ),
      const SizedBox(height: 15),
    ]);
  }
}
