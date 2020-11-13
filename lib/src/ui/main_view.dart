import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:draw_a_lot/src/ui/tools_panel.dart';
import 'package:draw_a_lot/src/paint_tool.dart';
import 'package:draw_a_lot/src/os_functions.dart';
import 'paint_widget.dart';
import 'palette_panel.dart';

class MainView extends StatefulWidget {
  MainView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  final _paintWidgetKey = GlobalKey<PaintWidgetState>();

  final _startPaintTool = PaintTool.Pen;
  final _startThickness = 20.0;

  Color _selectedColor = Colors.lightBlue;

  AnimationController _uiLockingController;
  Animation<Offset> _uiLockingToolbarAnimation;
  Animation<Offset> _uiLockingPalletteAnimation;
  Animation<Offset> _uiLockingUnlockAnimation;

  GlobalKey<PaintWidgetState> get paintWidgetKey => _paintWidgetKey;

  void undo() {
    paintWidgetKey.currentState.undo();
  }

  void saveToGallery() {
    print("Saving picture...");
    final imageFuture = paintWidgetKey.currentState.saveToImage();
    OsFunctions.saveToGallery(imageFuture).catchError((error) {
      print("An error occurred while saving the image: $error");
      _showSnackBar(
          context, "An error occurred while saving the image: $error");
    }).then((result) {
      if (result == null) {
        print("Unknow result");
      } else if (result) {
        print("Saved successfully");
        _showSnackBar(context, "Image saved successfully to the gallery");
      } else {
        print("An error occurred while saving the image");
        _showSnackBar(context, "An error occurred while saving the image");
      }
    });
  }

  Future<void> _updateThickness(Future<double> val) async {
    var res = await val;
    if (res != null) {
      print("New thickness: $res");
      paintWidgetKey.currentState.penThickness = res;
    }
  }

  void _updateTool(PaintTool tool) {
    paintWidgetKey.currentState.paintTool = tool;
  }

  void _showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
        content: Text(
      text,
      textAlign: TextAlign.center,
    ));

    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _lockUi() {
    print("Locking ui");
    _uiLockingController.forward();
  }

  void _unlockUi() {
    print("Unlocking ui");
    _uiLockingController.reverse();
  }

  @override
  void initState() {
    super.initState();

    _uiLockingController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    _uiLockingToolbarAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(-1, 0))
            .animate(_uiLockingController);
    _uiLockingPalletteAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(1, 0))
            .animate(_uiLockingController);

    _uiLockingUnlockAnimation =
        Tween<Offset>(begin: Offset(0, -2), end: Offset.zero)
            .animate(_uiLockingController);
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context);
    print(
        "Screen size: ${query.size}, ratio: ${query.devicePixelRatio}, text scale factor: ${query.textScaleFactor}");
    print("ratio: ${WidgetsBinding.instance.window.devicePixelRatio}");

    return new Stack(
      children: <Widget>[
        PaintWidget(_selectedColor, _startPaintTool, _startThickness,
            key: paintWidgetKey),
        Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
                position: _uiLockingUnlockAnimation,
                child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: ButtonTheme(
                        minWidth: 100.0,
                        height: 48.0,
                        child: RaisedButton.icon(
                            onPressed: () => _unlockUi(),
                            icon: Icon(Icons.fullscreen_exit, size: 30),
                            label: Text("Show toolbars",
                                style: TextStyle(fontSize: 18)),
                            color: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)))))))),
        Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
                position: _uiLockingPalletteAnimation,
                child: PalettePanel((newColor) {
                  paintWidgetKey.currentState.color = newColor;
                }))),
        Align(
            alignment: Alignment.centerLeft,
            child: SlideTransition(
                position: _uiLockingToolbarAnimation,
                child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: ToolsPanel(
                      _startPaintTool,
                      _startThickness,
                      onPaintToolChanged: (tool) {
                        print("Paint tool changed: $tool");
                        _updateTool(tool);
                      },
                      onThicknessChanged: (thickness) {
                        _updateThickness(thickness);
                      },
                      onUndoCalled: () {
                        print("Undo clicked");
                        paintWidgetKey.currentState.undo();
                      },
                      onRedoCalled: () {
                        print("Redo clicked");
                        paintWidgetKey.currentState.redo();
                      },
                      onLockCalled: () {
                        _lockUi();
                      },
                      onMenuCalled: () {
                        Scaffold.of(context).openDrawer();
                      },
                    )))),
      ],
    );
  }
}
