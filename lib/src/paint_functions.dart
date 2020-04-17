import 'dart:ui' as dart_ui;
import 'dart:typed_data';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bitmap/bitmap.dart';

import 'color.dart';

class PaintFunctions {
  static List<List<int>> _visitedPixels;
  static int _curUsedValueForVisited = 0;

  static final _maxUsedValueForVisited = pow(2, 52);

  static Future<dart_ui.Image> fillImage(
      dart_ui.Image image,
      ByteData constraintImageData,
      dart_ui.Size size,
      dart_ui.Offset point,
      dart_ui.Color color) async {
    if (constraintImageData != null) {
      //checking for constraint hit
      final constraintBuffer = constraintImageData.buffer.asUint8List();
      final base =
          (point.dx.toInt() + point.dy.toInt() * size.width.ceil()) * 4;
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
    }

    if (image == null) {
      //no cache value
      return _perfomFill(null, size, point, color);
    }

    final byteData =
        await image.toByteData(format: dart_ui.ImageByteFormat.rawUnmodified);
    return _perfomFill(byteData, size, point, color);
  }

  static Future<dart_ui.Image> _perfomFill(ByteData imageData,
      dart_ui.Size size, dart_ui.Offset point, dart_ui.Color color) {
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

    if (_visitedPixels == null ||
        _visitedPixels.length != width ||
        _visitedPixels[0].length != height ||
        _curUsedValueForVisited > _maxUsedValueForVisited) {
      _visitedPixels = new List.generate(width, (_) => new List(height));
    }

    ++_curUsedValueForVisited;
    _visitedPixels[mouseX][mouseY] = _curUsedValueForVisited;

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

          if (_visitedPixels[x][y] != _curUsedValueForVisited) {
            queue.add([x, y]);
            _visitedPixels[x][y] = _curUsedValueForVisited;
          }
        } else if (colorToCheck != null) {
          var diff = colorToCheck.difference(colorToReplace);
          if (diff < 800) {
            final base = (x + y * width) * 4;
            bitmap.content[base] = color.red;
            bitmap.content[base + 1] = color.green;
            bitmap.content[base + 2] = color.blue;
            bitmap.content[base + 3] = color.alpha;
          }
          if (diff < 283 && _visitedPixels[x][y] != _curUsedValueForVisited) {
            final base = (x + y * width) * 4;
            bitmap.content[base] = ((color.red + colorToCheck.red) / 2).round();
            bitmap.content[base + 1] =
                ((color.green + colorToCheck.green) / 2).round();
            bitmap.content[base + 2] =
                ((color.blue + colorToCheck.blue) / 2).round();
            bitmap.content[base + 3] =
                ((color.alpha + colorToCheck.alpha) / 2).round();
            queue.add([x, y]);
            _visitedPixels[x][y] = _curUsedValueForVisited;
          }
        }
      };

      checkNeighbor(x - 1, y);
      checkNeighbor(x + 1, y);
      checkNeighbor(x, y - 1);
      checkNeighbor(x, y + 1);
    }

    return bitmap.buildImage();
  }
}
