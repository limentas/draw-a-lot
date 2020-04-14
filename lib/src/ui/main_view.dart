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

class MainViewState extends State<MainView> {
  final _paintWidgetKey = GlobalKey<PaintWidgetState>();

  final _startPaintTool = PaintTool.Pen;
  final _startThickness = 20.0;

  Color _selectedColor = Colors.lightBlue;

  GlobalKey<PaintWidgetState> get paintWidgetKey => _paintWidgetKey;

  void undo() {
    paintWidgetKey.currentState.undo();
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

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context);
    print(
        "Screen size: ${query.size}, ratio: ${query.devicePixelRatio}, text scale factor: ${query.textScaleFactor}");

    return new Stack(
      children: <Widget>[
        PaintWidget(_selectedColor, _startPaintTool, _startThickness,
            key: paintWidgetKey),
        Align(
            alignment: Alignment.centerRight,
            child: PalettePanel((newColor) {
              paintWidgetKey.currentState.color = newColor;
            })),
        Align(
            alignment: Alignment.centerLeft,
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
                  onSaveCalled: () {
                    print("Saving picture...");
                    final imageFuture =
                        paintWidgetKey.currentState.saveToImage();
                    OsFunctions.saveToGallery(imageFuture).catchError((error) {
                      print("An error occurred while saving the image: $error");
                      _showSnackBar(context,
                          "An error occurred while saving the image: $error");
                    }).then((result) {
                      if (result == null) {
                        print("Unknow result");
                      }
                      else if (result) {
                        print("Saved successfully");
                        _showSnackBar(
                            context, "Image saved successfully to the gallery");
                      } else {
                        print("An error occurred while saving the image");
                        _showSnackBar(context,
                            "An error occurred while saving the image");
                      }
                    });
                  },
                  onCleanCalled: () {
                    print("Clean clicked");
                    paintWidgetKey.currentState.clean();
                  },
                ))),
      ],
    );
  }
}
