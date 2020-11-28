import 'dart:collection';
import 'dart:ui' as dart_ui;
import 'package:flutter_svg/flutter_svg.dart';

import 'pen_path.dart';

class PaintData {
  final Queue<PenPath> pathesToDraw = new Queue<PenPath>();
  dart_ui.Image cacheBuffer;
  dart_ui.Image imageForColoring;
  dart_ui.Picture pictureForColoring;
  DrawableRoot rootForColoring;
}
