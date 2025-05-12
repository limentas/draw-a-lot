import 'dart:collection';
import 'dart:ui' as dart_ui;

import 'pen_path.dart';

class PaintData {
  final Queue<PenPath> pathesToDraw = new Queue<PenPath>();
  dart_ui.Image? currentImage;
  dart_ui.Image? imageForColoring = null;
}
