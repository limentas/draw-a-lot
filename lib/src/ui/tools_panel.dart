import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:draw_a_lot/src/paint_tool.dart';
import 'tool_button.dart';
import 'thickness_dialog.dart';

class ToolsPanel extends StatelessWidget {
  ToolsPanel(this._startTool, this._thickness,
      {this.onPaintToolChanged,
      this.onThicknessChanged,
      this.onUndoCalled,
      this.onRedoCalled,
      this.onSaveCalled,
      this.onCleanCalled});

  final _thicknessButtonKey = GlobalKey<ToolButtonState>();
  final _fillButtonKey = GlobalKey<ToolButtonState>();

  final _startTool;
  final _thickness;

  final void Function(PaintTool) onPaintToolChanged;
  final void Function(Future<double>) onThicknessChanged;

  final void Function() onUndoCalled;
  final void Function() onRedoCalled;

  final void Function() onSaveCalled;
  final void Function() onCleanCalled;

  void _updateTool(PaintTool tool) {
    onPaintToolChanged(tool);
    _thicknessButtonKey.currentState.setToggled(tool == PaintTool.Pen);
    _fillButtonKey.currentState.setToggled(tool == PaintTool.Fill);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(height: 15),
      ToolButton(
        key: _thicknessButtonKey,
        imageIcon: AssetImage('icons/brush_thickness.png'),
        startToggled: _startTool == PaintTool.Pen,
        onPressed: () {
          _updateTool(PaintTool.Pen);
          final buttonHeight =
              min(80.0, MediaQuery.of(context).size.height / 5 - 12);
          var thicknessFuture =
              showThicknessDialog(context, buttonHeight, 10.0, _thickness);
          onThicknessChanged(thicknessFuture);
        },
      ),
      const Spacer(),
      ToolButton(
          key: _fillButtonKey,
          iconData: Icons.format_color_fill,
          color: Colors.green[900],
          startToggled: _startTool == PaintTool.Fill,
          disabled: kIsWeb == true,
          onPressed: () => _updateTool(PaintTool.Fill)),
      const Spacer(flex: 6),
      ToolButton(
          iconData: Icons.undo,
          color: Colors.blue[900],
          onPressed: onUndoCalled),
      const Spacer(),
      ToolButton(
          iconData: Icons.redo,
          color: Colors.blue[900],
          onPressed: onRedoCalled),
      const Spacer(flex: 6),
      ToolButton(
          iconData: Icons.save,
          color: Colors.indigo[900],
          disabled: kIsWeb,
          onPressed: onSaveCalled),
      const Spacer(),
      ToolButton(
          iconData: Icons.delete_outline,
          color: Colors.red[900],
          onPressed: onCleanCalled),
      const SizedBox(
        height: 15,
      ),
    ]);
  }
}
