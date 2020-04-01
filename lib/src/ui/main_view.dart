import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'paint_widget.dart';
import 'palette_button.dart';
import 'tool_button.dart';

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

  Color _selectedColor = Colors.black;

  Future<void> saveImage() async {
    var dirs = await getExternalStorageDirectories(type: StorageDirectory.pictures);
    print("${dirs.length}, $dirs");
  }

  void updateSelectedColor(Color color) {
    //setState(() {_selectedColor = color;});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        body: Stack(
          children: <Widget>[
            PaintWidget(_selectedColor, 0.0, key: _paintWidgetKey),
            Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                  SizedBox(height: 15),
                  PaletteButton(
                    Colors.white,
                    _selectedColor,
                    key: _whiteColorButtonKey,
                    onPressed: (color) {
                      _paintWidgetKey.currentState.color = color;
                      updateSelectedColor(color);
                    },
                  ),
                  Spacer(),
                  PaletteButton(
                    Colors.red,
                    _selectedColor,
                    key: _redColorButtonKey,
                    onPressed: (color) {
                      _paintWidgetKey.currentState.color = color;
                      updateSelectedColor(color);
                    },
                  ),
                  Spacer(),
                  PaletteButton(
                    Colors.orange,
                    _selectedColor,
                    key: _orangeColorButtonKey,
                    onPressed: (color) {
                      _paintWidgetKey.currentState.color = color;
                      updateSelectedColor(color);
                    },
                  ),
                  Spacer(),
                  PaletteButton(
                    Colors.yellow,
                    _selectedColor,
                    key: _yellowColorButtonKey,
                    onPressed: (color) {
                      _paintWidgetKey.currentState.color = color;
                      updateSelectedColor(color);
                    },
                  ),
                  Spacer(),
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
                  Spacer(),
                  PaletteButton(
                    Colors.lightBlue,
                    _selectedColor,
                    key: _lightBlueColorButtonKey,
                    onPressed: (color) {
                      _paintWidgetKey.currentState.color = color;
                      updateSelectedColor(color);
                    },
                  ),
                  Spacer(),
                  PaletteButton(
                    Colors.blue[900],
                    _selectedColor,
                    key: _blueColorButtonKey,
                    onPressed: (color) {
                      _paintWidgetKey.currentState.color = color;
                      updateSelectedColor(color);
                    },
                  ),
                  Spacer(),
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
                child: Column(children: <Widget>[
                  Spacer(flex: 6),
                  ToolButton(
                    icon: Icons.undo,
                    onPressed: () {
                      print("Undo clicked");
                      _paintWidgetKey.currentState.undo();
                    },
                  ),
                  Spacer(),
                  ToolButton(
                    icon: Icons.redo,
                    onPressed: () {
                      print("Redo clicked");
                      _paintWidgetKey.currentState.redo();
                    },
                  ),
                  Spacer(flex: 6),
                ])),
            Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                  ToolButton(
                    icon: Icons.save,
                    disabled: kIsWeb,
                    onPressed: () {
                      print("Save clicked");
                      saveImage().whenComplete(() {print("complete");} );
                    },
                  ),
                  const SizedBox(height: 10,),
                  ToolButton(
                    icon: Icons.delete_outline,
                    onPressed: () {
                      print("Clean clicked");
                      _paintWidgetKey.currentState.clean();
                    },
                  ),
                  const SizedBox(height: 15,),
                ]))
          ],
        ));
  }
}
