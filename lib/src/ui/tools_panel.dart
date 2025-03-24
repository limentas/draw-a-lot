import 'dart:math';

import 'package:draw_a_lot/src/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:draw_a_lot/src/paint_tool.dart';
import 'tool_button.dart';
import 'thickness_dialog.dart';

class ToolsPanel extends StatelessWidget {
  ToolsPanel(
    this._startTool,
    this._thickness, {
    required this.onPaintToolChanged,
    required this.onThicknessChanged,
    required this.onUndoCalled,
    required this.onRedoCalled,
    required this.onLockCalled,
    required this.onMenuCalled,
  });

  final _thicknessButtonKey = GlobalKey<ToolButtonState>();
  final _fillButtonKey = GlobalKey<ToolButtonState>();

  final _startTool;
  final _thickness;

  final void Function(PaintTool) onPaintToolChanged;
  final void Function(Future<double?>) onThicknessChanged;

  final void Function() onUndoCalled;
  final void Function() onRedoCalled;

  final void Function() onLockCalled;
  final void Function() onMenuCalled;

  void _updateTool(PaintTool tool) {
    onPaintToolChanged(tool);
    _thicknessButtonKey.currentState?.setToggled(tool == PaintTool.Pen);
    _fillButtonKey.currentState?.setToggled(tool == PaintTool.Fill);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        ToolButton(
          key: _thicknessButtonKey,
          color: Colors.black,
          imageIcon: AssetImage('icons/brush_thickness.png'),
          startToggled: _startTool == PaintTool.Pen,
          onPressed: () {
            _updateTool(PaintTool.Pen);
            final buttonHeight = min(
              80.0,
              MediaQuery.of(context).size.height / 5 - 12,
            );
            var thicknessFuture = showThicknessDialog(
              context,
              buttonHeight,
              20.0,
              _thickness,
            );
            onThicknessChanged(thicknessFuture);
          },
        ),
        const Spacer(),
        ToolButton(
          key: _fillButtonKey,
          iconData: Icons.format_color_fill,
          color: Colors.green.shade900,
          startToggled: _startTool == PaintTool.Fill,
          disabled: kIsWeb == true || AppConfig.isX86_32,
          onPressed: () => _updateTool(PaintTool.Fill),
        ),
        const Spacer(flex: 10),
        ToolButton(
          iconData: Icons.undo,
          color: Colors.blue.shade900,
          onPressed: onUndoCalled,
        ),
        const Spacer(),
        ToolButton(
          iconData: Icons.redo,
          color: Colors.blue.shade900,
          onPressed: onRedoCalled,
        ),
        const Spacer(flex: 10),
        ToolButton(
          iconData: Icons.fullscreen,
          color: Colors.indigo.shade900,
          onPressed: onLockCalled,
        ),
        const Spacer(),
        ToolButton(
          iconData: Icons.menu,
          color: Colors.grey.shade900,
          onPressed: onMenuCalled,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
