import 'dart:ui' as dart_ui;
import 'dart:typed_data';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:bitmap/bitmap.dart';

import 'color.dart';

Future<dart_ui.Image> fillImage(
    dart_ui.Image image,
    ByteData constraintImageData,
    dart_ui.Size size,
    dart_ui.Offset point,
    dart_ui.Color color) async {
  final constraintBuffer = constraintImageData.buffer.asUint8List();
  final base = (point.dx.toInt() + point.dy.toInt() * size.width.ceil()) * 4;
  final colorFromConstraint = Color.fromRgba(
      constraintBuffer[base],
      constraintBuffer[base + 1],
      constraintBuffer[base + 2],
      constraintBuffer[base + 3]);

  final colorBlack = Color.fromColor(Colors.black);
  if (colorFromConstraint.alpha > 100 &&
      colorFromConstraint.difference(colorBlack) < 10) {
    print("Pointed to constraint");
    return null;
  }

  if (image == null) {
    return _perfomFill(null, size, point, color);
  }

  final byteData =
      await image.toByteData(format: dart_ui.ImageByteFormat.rawUnmodified);
  return _perfomFill(byteData, size, point, color);
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

      if (colorToCheck == colorToReplace) {
        final base = (x + y * width) * 4;
        bitmap.content[base] = color.red;
        bitmap.content[base + 1] = color.green;
        bitmap.content[base + 2] = color.blue;
        bitmap.content[base + 3] = color.alpha;
        queue.add([x, y]);
      } else if (colorToCheck != null) {
        var diff = colorToCheck.difference(colorToReplace);
        if (diff < 600) {
          final base = (x + y * width) * 4;
          bitmap.content[base] = ((color.red + colorToCheck.red) / 2).round();
          bitmap.content[base + 1] =
              ((color.green + colorToCheck.green) / 2).round();
          bitmap.content[base + 2] =
              ((color.blue + colorToCheck.blue) / 2).round();
          bitmap.content[base + 3] =
              ((color.alpha + colorToCheck.alpha) / 2).round();
        }
        if (diff < 283) queue.add([x, y]);
      }
    };

    checkNeighbor(x - 1, y);
    checkNeighbor(x + 1, y);
    checkNeighbor(x, y - 1);
    checkNeighbor(x, y + 1);
  }

  return bitmap.buildImage();
}
