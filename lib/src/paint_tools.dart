import 'dart:ui' as dart_ui;
import 'dart:typed_data';
import 'dart:collection';

import 'package:bitmap/bitmap.dart';

import 'color.dart';

Future<dart_ui.Image> fillImage(dart_ui.Image image, dart_ui.Size size,
    dart_ui.Offset point, dart_ui.Color color) async {
  if (image == null) {
    return _perfomFill(null, size, point, color);
  }
  final byteDataFuture =
      await image.toByteData(format: dart_ui.ImageByteFormat.rawUnmodified);

  return _perfomFill(byteDataFuture, size, point, color);
}

Future<dart_ui.Image> _perfomFill(ByteData imageData, dart_ui.Size size,
    dart_ui.Offset point, dart_ui.Color color) {
  final mouseX = point.dx.toInt();
  final mouseY = point.dy.toInt();
  final width = size.width.ceil();
  final height = size.height.ceil();

  final bitmap = imageData == null
      ? Bitmap.blank(width, height)
      : Bitmap.fromHeadless(width, height, imageData.buffer.asUint8List());

  final getImageColorSafe = (x, y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return null;
    final base = (x + y * width) * 4;

    return Color.fromRgba(bitmap.content[base], bitmap.content[base + 1],
        bitmap.content[base + 2], bitmap.content[base + 3]);
  };
  final colorToReplace = getImageColorSafe(mouseX, mouseY);
  final colorReplaceTo = Color.fromColor(color);
  if (colorToReplace == colorReplaceTo) return null;

  final queue = DoubleLinkedQueue.of([
    [mouseX, mouseY]
  ]);

  while (queue.isNotEmpty) {
    final item = queue.removeFirst();
    final x = item.first;
    final y = item.last;

    //check neighbors (left, right, top, bottom)
    final checkNeighbor = (x, y) {
      final colorToCheck = getImageColorSafe(x, y);
      if (colorToCheck == colorReplaceTo) return;

      if (colorToCheck == colorToReplace ||
          colorToCheck != null &&
              colorToCheck.difference(colorToReplace) < 260) {
        final base = (x + y * width) * 4;
        bitmap.content[base] = color.red;
        bitmap.content[base + 1] = color.green;
        bitmap.content[base + 2] = color.blue;
        bitmap.content[base + 3] = color.alpha;
        queue.add([x, y]);
      }
    };

    checkNeighbor(x - 1, y);
    checkNeighbor(x + 1, y);
    checkNeighbor(x, y - 1);
    checkNeighbor(x, y + 1);
  }

  return bitmap.buildImage();
}
