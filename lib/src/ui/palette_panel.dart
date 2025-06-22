import 'dart:math';

import 'package:flutter/material.dart';

import 'palette_button.dart';

class PalettePanel extends StatefulWidget {
  PalettePanel(this.startColor, this.onColorChanged);

  final Color startColor;
  final void Function(Color) onColorChanged;

  @override
  State<StatefulWidget> createState() {
    return PalettePanelState(startColor, onColorChanged);
  }
}

class PalettePanelState extends State<PalettePanel> {
  PalettePanelState(this._color, this.onColorChanged);

  Color _color;
  final void Function(Color) onColorChanged;

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

  void _updateSelectedColor(Color newColor) {
    onColorChanged(newColor);
    setState(() {
      _color = newColor;
    });
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
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.brown,
                selectedColor: _color,
                colorsToChoiseFrom: listAllMaterialColors(Colors.brown),
                buttonSize: buttonSize,
                onPressed: (color) {
                  _updateSelectedColor(color);
                },
              ),
              PaletteButton(
                myColor: Colors.black,
                selectedColor: _color,
                colorsToChoiseFrom: listGreyscale(),
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
