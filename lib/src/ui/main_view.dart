import 'package:draw_a_lot/src/ui/all_tools_overlay.dart';
import 'package:flutter/material.dart';

import 'package:draw_a_lot/src/paint_tool.dart';
import 'package:draw_a_lot/src/os_functions.dart';
import 'paint_widget.dart';

// The only reason to have this widget stateful is to be able to use AnimationController
class MainView extends StatelessWidget {
  MainView({Key? key}) : super(key: key);

  final PaintTool startTool = PaintTool.Pen;
  final Color startColor = Colors.red;
  final double startThickness = 20.0;

  final _paintWidgetKey = GlobalKey<PaintWidgetState>();

  void newBlankCanvas() {
    print("New blank canvas");
    _paintWidgetKey.currentState?.setImageForColoring("");
  }

  void setImageForColoring(String imagePath) {
    print("Set image for coloring: $imagePath");
    _paintWidgetKey.currentState?.setImageForColoring(imagePath);
  }

  void saveToGallery(BuildContext context) async {
    print("Saving picture...");
    final imageFuture = _paintWidgetKey.currentState?.saveToImage();
    if (imageFuture == null) return;

    try {
      var saveResult = await OsFunctions.saveToGallery(imageFuture);
      if (saveResult) {
        print("Saved successfully");
        _showSnackBar(context, "Image saved successfully to the gallery");
      } else {
        print("An error occurred while saving the image");
        _showSnackBar(context, "An error occurred while saving the image");
      }
    } catch (error) {
      print("An exception occurred while saving the image: $error");
      _showSnackBar(
        context,
        "An error occurred while saving the image: $error",
      );
    }
  }

  void undo() {
    _paintWidgetKey.currentState?.undo();
  }

  void _updateTool(PaintTool tool) {
    print("Paint tool changed: $tool");
    _paintWidgetKey.currentState?.paintTool = tool;
  }

  void _updateColor(Color color) {
    print("Tool color changed: $color");
    _paintWidgetKey.currentState?.color = color;
  }

  void _updateThickness(double thickness) {
    print("New pen thickness: $thickness");
    _paintWidgetKey.currentState?.penThickness = thickness;
  }

  void _showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text, textAlign: TextAlign.center));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context);
    print(
      "Screen size              : ${query.size.width}x${query.size.height}, "
      "ratio: ${query.devicePixelRatio}, "
      "text scale factor: ${query.textScaler.scale(16) / 16}",
    );
    print("View ratio               : ${View.of(context).devicePixelRatio}");

    return new Stack(
      children: <Widget>[
        PaintWidget(
          startTool,
          startColor,
          startThickness,
          key: _paintWidgetKey,
        ),
        AllToolsOverlay(startTool, startColor, startThickness,
            onPaintToolChanged: _updateTool,
            onThicknessChanged: _updateThickness,
            onUndoCalled: undo,
            onRedoCalled: () => _paintWidgetKey.currentState?.redo(),
            onMenuCalled: () => Scaffold.of(context).openDrawer(),
            onColorChanged: _updateColor),
      ],
    );
  }
}
