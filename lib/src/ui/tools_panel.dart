import 'dart:math';

import 'package:draw_a_lot/src/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:draw_a_lot/src/paint_tool.dart';
import 'tool_button.dart';
import 'thickness_dialog.dart';

class ToolsPanel extends StatefulWidget {
  ToolsPanel(
    this.startTool,
    this.startThickness, {
    required this.onPaintToolChanged,
    required this.onThicknessChanged,
    required this.onUndoCalled,
    required this.onRedoCalled,
    required this.onLockCalled,
    required this.onMenuCalled,
  });

  final PaintTool startTool;
  final double startThickness;

  final void Function(PaintTool) onPaintToolChanged;
  final void Function(double) onThicknessChanged;

  final void Function() onUndoCalled;
  final void Function() onRedoCalled;

  final void Function() onLockCalled;
  final void Function() onMenuCalled;

  @override
  State<StatefulWidget> createState() {
    return ToolsPanelState(
        startTool,
        startThickness,
        onPaintToolChanged,
        onThicknessChanged,
        onUndoCalled,
        onRedoCalled,
        onLockCalled,
        onMenuCalled);
  }
}

class ToolsPanelState extends State<ToolsPanel> {
  ToolsPanelState(
      this._tool,
      this._thickness,
      this.onPaintToolChanged,
      this.onThicknessChanged,
      this.onUndoCalled,
      this.onRedoCalled,
      this.onLockCalled,
      this.onMenuCalled);

  PaintTool _tool;
  double _thickness;

  final void Function(PaintTool) onPaintToolChanged;
  final void Function(double) onThicknessChanged;

  final void Function() onUndoCalled;
  final void Function() onRedoCalled;

  final void Function() onLockCalled;
  final void Function() onMenuCalled;

  void _updateTool(PaintTool tool) {
    onPaintToolChanged(tool);
    setState(() {
      _tool = tool;
    });
  }

  void _updateThickness(double thickness) {
    onThicknessChanged(thickness);
    setState(() {
      _thickness = thickness;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        ToolButton(
          color: Colors.black,
          svgAssetName: 'icons/brush_thickness.svg',
          toggled: _tool == PaintTool.Pen,
          onPressed: () async {
            // When we switch to this tool, we don't show thickness dialog
            if (_tool != PaintTool.Pen) {
              _updateTool(PaintTool.Pen);
            } else {
              // If we are already in this tool, show thickness dialog
              final buttonHeight = min(
                80.0,
                MediaQuery.of(context).size.height / 5 - 12,
              );
              var thickness = await showThicknessDialog(
                context,
                buttonHeight,
                20.0,
                _thickness,
              );
              if (thickness != null) _updateThickness(thickness);
            }
          },
        ),
        const Spacer(),
        ToolButton(
          iconData: Icons.format_color_fill,
          color: Colors.green.shade900,
          toggled: _tool == PaintTool.Fill,
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
        Visibility(
            visible: kDebugMode,
            child: ToolButton(
              iconData: Icons.bug_report,
              color: Colors.indigo.shade900,
              toggled: _tool == PaintTool.Debug,
              onPressed: () => _updateTool(PaintTool.Debug),
            )),
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
