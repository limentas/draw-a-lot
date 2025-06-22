import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'pen_path.dart';

class PaintData {
  final Queue<PenPath> pathesToDraw = new Queue<PenPath>();
  dart_ui.Image? currentImage;
  ByteData? currentImageBytes = null;
  dart_ui.Image? imageForColoring = null;
  ByteData? imageForColoringBytes = null;
}
