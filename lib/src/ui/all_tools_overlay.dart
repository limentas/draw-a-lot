import 'package:flutter/material.dart';

import 'package:draw_a_lot/src/ui/tools_panel.dart';
import 'package:draw_a_lot/src/paint_tool.dart';
import 'palette_panel.dart';

// The only reason to have this widget stateful is to be able to use AnimationController
class AllToolsOverlay extends StatefulWidget {
  AllToolsOverlay(
    this.startTool,
    this.startColor,
    this.startThickness, {
    required this.onPaintToolChanged,
    required this.onThicknessChanged,
    required this.onUndoCalled,
    required this.onRedoCalled,
    required this.onMenuCalled,
    required this.onColorChanged,
    Key? key,
  }) : super(key: key);

  final PaintTool startTool;
  final Color startColor;
  final double startThickness;

  final void Function(PaintTool) onPaintToolChanged;
  final void Function(double) onThicknessChanged;
  final void Function(Color) onColorChanged;
  final void Function() onUndoCalled;
  final void Function() onRedoCalled;
  final void Function() onMenuCalled;

  @override
  AllToolsOverlayState createState() =>
      AllToolsOverlayState(startTool, startColor, startThickness,
          onPaintToolChanged: onPaintToolChanged,
          onThicknessChanged: onThicknessChanged,
          onColorChanged: onColorChanged,
          onUndoCalled: onUndoCalled,
          onRedoCalled: onRedoCalled,
          onMenuCalled: onMenuCalled);
}

class AllToolsOverlayState extends State<AllToolsOverlay>
    with SingleTickerProviderStateMixin {
  AllToolsOverlayState(this.startTool, this.startColor, this.startThickness,
      {required this.onPaintToolChanged,
      required this.onThicknessChanged,
      required this.onColorChanged,
      required this.onUndoCalled,
      required this.onRedoCalled,
      required this.onMenuCalled});

  final PaintTool startTool;
  final Color startColor;
  final double startThickness;

  final void Function(PaintTool) onPaintToolChanged;
  final void Function(double) onThicknessChanged;
  final void Function(Color) onColorChanged;
  final void Function() onUndoCalled;
  final void Function() onRedoCalled;
  final void Function() onMenuCalled;

  late AnimationController _uiLockingController;
  late Animation<Offset> _uiLockingToolbarAnimation;
  late Animation<Offset> _uiLockingPalletteAnimation;
  late Animation<Offset> _uiLockingUnlockAnimation;

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

    _uiLockingController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _uiLockingToolbarAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-1, 0),
    ).animate(_uiLockingController);
    _uiLockingPalletteAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1, 0),
    ).animate(_uiLockingController);

    _uiLockingUnlockAnimation = Tween<Offset>(
      begin: Offset(0, -2),
      end: Offset.zero,
    ).animate(_uiLockingController);
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: _uiLockingUnlockAnimation,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: ButtonTheme(
                minWidth: 100.0,
                height: 48.0,
                child: ElevatedButton.icon(
                  onPressed: () => _unlockUi(),
                  icon: Icon(Icons.fullscreen_exit, size: 30),
                  label: Text("Show toolbars", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _uiLockingPalletteAnimation,
            child: PalettePanel(startColor, onColorChanged),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: SlideTransition(
            position: _uiLockingToolbarAnimation,
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: ToolsPanel(
                startTool,
                startThickness,
                onPaintToolChanged: onPaintToolChanged,
                onThicknessChanged: onThicknessChanged,
                onUndoCalled: onUndoCalled,
                onRedoCalled: onRedoCalled,
                onLockCalled: () {
                  _lockUi();
                },
                onMenuCalled: onMenuCalled,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
