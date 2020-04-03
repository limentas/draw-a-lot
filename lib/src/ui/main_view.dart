import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:intl/intl.dart';
import 'paint_widget.dart';
import 'palette_button.dart';
import 'tool_button.dart';
import 'thickness_dialog.dart';

class MainView extends StatefulWidget {
  MainView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
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

  Future<void> saveImage() async {
    try {
      final picturesPath = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_PICTURES);
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
        _paintWidgetKey.currentState.saveToFile(file);
      });
    } catch (err) {
      print("Error while saving: $err");
    }
  }

  void updateSelectedColor(Color color) {
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

  Future<void> updateThickness(Future<double> val) async {
    var res = await val;
    if (res != null) {
      print("New thickness: $res");
      _paintWidgetKey.currentState.penWidth = _thickness = res;
    }
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context);
    print(
        "Screen size: ${query.size}, ratio: ${query.devicePixelRatio}, text scale factor: ${query.textScaleFactor}");

    return new WillPopScope(
        onWillPop: () {
          print("Back button clicked");
          _paintWidgetKey.currentState.undo();
          return new Future(() => false);
        },
        child: Scaffold(
            extendBodyBehindAppBar: false,
            resizeToAvoidBottomPadding: false,
            body: Stack(
              children: <Widget>[
                PaintWidget(_selectedColor, _thickness, key: _paintWidgetKey),
                Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          const SizedBox(height: 15),
                          PaletteButton(
                            Colors.white,
                            _selectedColor,
                            key: _whiteColorButtonKey,
                            onPressed: (color) {
                              _paintWidgetKey.currentState.color = color;
                              updateSelectedColor(color);
                            },
                          ),
                          const Spacer(),
                          PaletteButton(
                            Colors.red,
                            _selectedColor,
                            key: _redColorButtonKey,
                            onPressed: (color) {
                              _paintWidgetKey.currentState.color = color;
                              updateSelectedColor(color);
                            },
                          ),
                          const Spacer(),
                          PaletteButton(
                            Colors.orange,
                            _selectedColor,
                            key: _orangeColorButtonKey,
                            onPressed: (color) {
                              _paintWidgetKey.currentState.color = color;
                              updateSelectedColor(color);
                            },
                          ),
                          const Spacer(),
                          PaletteButton(
                            Colors.yellow,
                            _selectedColor,
                            key: _yellowColorButtonKey,
                            onPressed: (color) {
                              _paintWidgetKey.currentState.color = color;
                              updateSelectedColor(color);
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
                                updateSelectedColor(color);
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
                              updateSelectedColor(color);
                            },
                          ),
                          const Spacer(),
                          PaletteButton(
                            Colors.blue[900],
                            _selectedColor,
                            key: _blueColorButtonKey,
                            onPressed: (color) {
                              _paintWidgetKey.currentState.color = color;
                              updateSelectedColor(color);
                            },
                          ),
                          const Spacer(),
                          PaletteButton(
                            Colors.purple[800],
                            _selectedColor,
                            key: _purpleColorButtonKey,
                            onPressed: (color) {
                              _paintWidgetKey.currentState.color = color;
                              updateSelectedColor(color);
                            },
                          ),
                          const Spacer(),
                          PaletteButton(
                            Colors.black,
                            _selectedColor,
                            key: _blackColorButtonKey,
                            onPressed: (color) {
                              _paintWidgetKey.currentState.color = color;
                              updateSelectedColor(color);
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
                            onPressed: () {
                              print("Brush width clicked");
                              final buttonHeight = min(80.0,
                                  MediaQuery.of(context).size.height / 5 - 12);
                              var thickness = showThicknessDialog(
                                  context, buttonHeight, 10.0);
                              updateThickness(thickness);
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
                              saveImage().catchError((error) {
                                print("Error during save file: $error");
                              }).whenComplete(() {
                                print("Saving complete successfull");
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
            )));
  }
}
