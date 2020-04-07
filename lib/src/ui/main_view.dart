import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'paint_widget.dart';
import 'palette_button.dart';
import 'tool_button.dart';
import 'thickness_dialog.dart';

class MainView extends StatefulWidget {
  MainView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  static const _platform = const MethodChannel('slebe.dev/draw-a-lot');
  static const String _DIRECTORY_PICTURES = "Pictures";

  final _paintWidgetKey = GlobalKey<PaintWidgetState>();
  final _whiteColorButtonKey = GlobalKey<PaletteButtonState>();
  final _redColorButtonKey = GlobalKey<PaletteButtonState>();
  final _orangeColorButtonKey = GlobalKey<PaletteButtonState>();
  final _yellowColorButtonKey = GlobalKey<PaletteButtonState>();
  final _greenColorButtonKey = GlobalKey<PaletteButtonState>();
  final _lightBlueColorButtonKey = GlobalKey<PaletteButtonState>();
  final _blueColorButtonKey = GlobalKey<PaletteButtonState>();
  final _purpleColorButtonKey = GlobalKey<PaletteButtonState>();
  final _blackColorButtonKey = GlobalKey<PaletteButtonState>();

  Color _selectedColor = Colors.lightBlue;
  double _thickness = 20;
  PaintTool _tool = PaintTool.Pen;

  void undo() {
    _paintWidgetKey.currentState.undo();
  }

  Future<String> _getExternalStoragePublicDirectory(String type) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }
    return await _platform
        .invokeMethod('getExternalStoragePublicDirectory', {'type': type});
  }

  void _rescanGallery(String path) {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }
    try {
      _platform.invokeMethod('rescanGallery', <String, dynamic>{'path': path});
    } catch (e) {
      print("Failed to rescan gallery: $e");
    }
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      final picturesPath =
          await _getExternalStoragePublicDirectory(_DIRECTORY_PICTURES);
      final myImagePath = '$picturesPath/DrawALot';
      final myImgDir = new Directory(myImagePath).create();

      String newFileName;
      var i = 0;
      var formatter = new DateFormat('yyyyMMdd');
      do {
        newFileName =
            "$myImagePath/drawing_${formatter.format(DateTime.now())}_${i++}.png";
      } while (FileSystemEntity.typeSync(newFileName) !=
          FileSystemEntityType.notFound);

      var file = myImgDir.then((value) => new File(newFileName).create());
      return file.then((file) {
        _paintWidgetKey.currentState.saveToFile(file).then((file) {
          _rescanGallery(file.path);
          final snackBar = SnackBar(
              content: Text(
            "Saved successfully to ${file.path}",
            textAlign: TextAlign.center,
          ));

          // Find the Scaffold in the widget tree and use it to show a SnackBar.
          Scaffold.of(context).showSnackBar(snackBar);
        });
      });
    } catch (err) {
      print("Error while saving: $err");
    }
  }

  void _updateSelectedColor(Color color) {
    _selectedColor = color;
    _whiteColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _redColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _orangeColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _yellowColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _greenColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _lightBlueColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _blueColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _purpleColorButtonKey.currentState.updateSelectedColor(_selectedColor);
    _blackColorButtonKey.currentState.updateSelectedColor(_selectedColor);
  }

  Future<void> _updateThickness(Future<double> val) async {
    var res = await val;
    if (res != null) {
      print("New thickness: $res");
      _paintWidgetKey.currentState.penWidth = _thickness = res;
    }
  }

  void _updateTool(PaintTool tool) {
    _paintWidgetKey.currentState.tool = tool;
    setState(() {
      _tool = tool;
    });
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context);
    print(
        "Screen size: ${query.size}, ratio: ${query.devicePixelRatio}, text scale factor: ${query.textScaleFactor}");

    return new Stack(
      children: <Widget>[
        PaintWidget(_selectedColor, _thickness, key: _paintWidgetKey),
        Align(
            alignment: Alignment.centerRight,
            child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              const SizedBox(height: 15),
              PaletteButton(
                Colors.white,
                _selectedColor,
                key: _whiteColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.red,
                _selectedColor,
                key: _redColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.orange,
                _selectedColor,
                key: _orangeColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.yellow,
                _selectedColor,
                key: _yellowColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.green,
                _selectedColor,
                key: _greenColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  setState(() {
                    _selectedColor = color;
                    _updateSelectedColor(color);
                  });
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.lightBlue,
                _selectedColor,
                key: _lightBlueColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.blue[900],
                _selectedColor,
                key: _blueColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.purple[800],
                _selectedColor,
                key: _purpleColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const Spacer(),
              PaletteButton(
                Colors.black,
                _selectedColor,
                key: _blackColorButtonKey,
                onPressed: (color) {
                  _paintWidgetKey.currentState.color = color;
                  _updateSelectedColor(color);
                },
              ),
              const SizedBox(height: 15),
            ])),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: Column(children: <Widget>[
                  SizedBox(height: 15),
                  ToolButton(
                    imageIcon: AssetImage('icons/brush_thickness.png'),
                    toggled: _tool == PaintTool.Pen,
                    onPressed: () {
                      print("Brush width clicked");
                      _updateTool(PaintTool.Pen);
                      final buttonHeight = min(
                          80.0, MediaQuery.of(context).size.height / 5 - 12);
                      var thickness =
                          showThicknessDialog(context, buttonHeight, 10.0, _thickness);
                      _updateThickness(thickness);
                    },
                  ),
                  const Spacer(),
                  ToolButton(
                    iconData: Icons.format_color_fill,
                    color: Colors.green[900],
                    toggled: _tool == PaintTool.Fill,
                    onPressed: () {
                      _updateTool(PaintTool.Fill);
                    },
                  ),
                  const Spacer(flex: 6),
                  ToolButton(
                    iconData: Icons.undo,
                    color: Colors.blue[900],
                    onPressed: () {
                      print("Undo clicked");
                      _paintWidgetKey.currentState.undo();
                    },
                  ),
                  const Spacer(),
                  ToolButton(
                    iconData: Icons.redo,
                    color: Colors.blue[900],
                    onPressed: () {
                      print("Redo clicked");
                      _paintWidgetKey.currentState.redo();
                    },
                  ),
                  const Spacer(flex: 6),
                  ToolButton(
                    iconData: Icons.save,
                    color: Colors.indigo[900],
                    disabled: kIsWeb,
                    onPressed: () {
                      print("Saving picture...");
                      _saveImage(context).catchError((error) {
                        print("Error during save file: $error");
                      }).whenComplete(() {
                        print("Saving complete");
                      });
                    },
                  ),
                  const Spacer(),
                  ToolButton(
                    iconData: Icons.delete_outline,
                    color: Colors.red[900],
                    onPressed: () {
                      print("Clean clicked");
                      _paintWidgetKey.currentState.clean();
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ]))),
      ],
    );
  }
}
