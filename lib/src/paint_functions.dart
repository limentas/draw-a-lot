import 'dart:ui' as dart_ui;
import 'dart:typed_data';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bitmap/bitmap.dart';

import 'color.dart';

class PaintFunctions {
  static Uint32List _visitedPixels = Uint32List(0);
  static int _curUsedValueForVisited = 0;

  static final _maxUsedValueForVisited = pow(2, 31);

  // Make "fill" operation and returns result image.
  // If there is nothing to do, then this method returns the same `image` object
  static Future<dart_ui.Image?> fillImage(
    dart_ui.Image? image,
    ByteData? constraintImageData,
    dart_ui.Size constraintImageSize,
    dart_ui.Offset physicalPoint,
    dart_ui.Color color,
  ) async {
    Uint32List? constraintBuffer = null;
    if (constraintImageData != null) {
      //checking for constraint hit
      constraintBuffer = constraintImageData.buffer.asUint32List();
      final colorFromConstraint = Color.fromRgbaInt(
        constraintBuffer[physicalPoint.dx.toInt() +
            physicalPoint.dy.toInt() * constraintImageSize.width.ceil()],
      );

      //print("colorFromConstraint " + colorFromConstraint.toString());
      //final colorBlack = Color.fromColor(Colors.black);
      //print("color diff " +
      //    colorFromConstraint.difference(colorBlack).toString());
      if (checkConstraintApprox(colorFromConstraint)) {
        var correctedPhysicalPoint = correctPhysicalPoint(
          constraintImageData,
          constraintImageSize,
          physicalPoint,
        );
        if (correctedPhysicalPoint == null) {
          print("Couldn't correct physicall point");
          throw new Exception("Couldn't correct physicall point");
        }
      }
    }

    Future<dart_ui.Image>? result;
    if (image == null) {
      //no cache value
      result = _perfomFill(
        null,
        constraintBuffer,
        constraintImageSize,
        physicalPoint,
        color,
      );
    } else {
      final byteData = await image.toByteData(
        format: dart_ui.ImageByteFormat.rawUnmodified,
      );
      result = _perfomFill(
        byteData,
        constraintBuffer,
        constraintImageSize,
        physicalPoint,
        color,
      );
    }
    if (result == null) return image;
    return result;
  }

  static dart_ui.Offset? correctPhysicalPoint(
    ByteData constraintImageData,
    dart_ui.Size constraintImageSize,
    dart_ui.Offset physicalPoint,
  ) {
    final constraintBuffer = constraintImageData.buffer.asUint32List();
    final width = constraintImageSize.width.ceil();
    final height = constraintImageSize.height.ceil();
    final checkNeighbor = (offset) {
      if (offset.dx < 0 ||
          offset.dx >= width ||
          offset.dy < 0 ||
          offset.dy >= height)
        return false;
      final colorFromConstraint = Color.fromRgbaInt(
        constraintBuffer[offset.dx.toInt() +
            offset.dy.toInt() * constraintImageSize.width.ceil()],
      );
      return !checkConstraintApprox(colorFromConstraint);
    };
    for (int radiusDist = 1; radiusDist < width; ++radiusDist) {
      var radiusDistDouble = radiusDist.toDouble();
      var point = physicalPoint.translate(radiusDistDouble, 0);
      if (checkNeighbor(point)) return point;
      point = physicalPoint.translate(-radiusDistDouble, 0);
      if (checkNeighbor(point)) return point;
      point = physicalPoint.translate(0, radiusDistDouble);
      if (checkNeighbor(point)) return point;
      point = physicalPoint.translate(0, -radiusDistDouble);
      if (checkNeighbor(point)) return point;

      for (int chordDist = 1; chordDist <= radiusDist; ++chordDist) {
        var chortDistDouble = chordDist.toDouble();
        var point = physicalPoint.translate(radiusDistDouble, chortDistDouble);
        if (checkNeighbor(point)) return point;
        point = physicalPoint.translate(radiusDistDouble, -chortDistDouble);
        if (checkNeighbor(point)) return point;
        point = physicalPoint.translate(-radiusDistDouble, chortDistDouble);
        if (checkNeighbor(point)) return point;
        point = physicalPoint.translate(-radiusDistDouble, -chortDistDouble);
        if (checkNeighbor(point)) return point;
        point = physicalPoint.translate(chortDistDouble, radiusDistDouble);
        if (checkNeighbor(point)) return point;
        point = physicalPoint.translate(-chortDistDouble, radiusDistDouble);
        if (checkNeighbor(point)) return point;
        point = physicalPoint.translate(chortDistDouble, -radiusDistDouble);
        if (checkNeighbor(point)) return point;
        point = physicalPoint.translate(-chortDistDouble, -radiusDistDouble);
        if (checkNeighbor(point)) return point;
      }
    }
    return null;
  }

  // Return null if there is nothing to do
  static Future<dart_ui.Image>? _perfomFill(
    ByteData? imageData,
    Uint32List? constraintBuffer,
    dart_ui.Size constraintImageSize,
    dart_ui.Offset physicalPoint,
    dart_ui.Color color,
  ) {
    final mouseX = physicalPoint.dx.toInt();
    final mouseY = physicalPoint.dy.toInt();
    final width = constraintImageSize.width.ceil();
    final height = constraintImageSize.height.ceil();

    Uint8List imageBufferUint8;
    Uint32List imageBufferUint32;

    final colorReplaceTo = Color.fromColor(color);
    final colorReplaceToRgba = colorReplaceTo.toRgbaInt();

    if (imageData == null) {
      if (colorReplaceToRgba == 0) return null;

      var byteData = ByteData(width * height * 4);
      imageBufferUint8 = byteData.buffer.asUint8List();
      imageBufferUint32 = byteData.buffer.asUint32List();
    } else {
      imageBufferUint8 = imageData.buffer.asUint8List();
      imageBufferUint32 = imageData.buffer.asUint32List();
    }

    final colorToReplace = Color.fromRgbaInt(
      imageBufferUint32[mouseX + mouseY * width],
    );

    final colorToReplaceRgba = colorToReplace.toRgbaInt();
    if (colorToReplaceRgba == colorReplaceToRgba) return null;

    imageBufferUint32[mouseX + mouseY * width] = colorReplaceToRgba;

    final capacity = max(width, height);
    final queue = ListQueue(capacity);
    queue.addLast([mouseX, mouseY]);

    if (_visitedPixels.length != width * height ||
        _curUsedValueForVisited > _maxUsedValueForVisited) {
      print("Recreate _visitedPixels array");
      _visitedPixels = Uint32List(width * height);
      _curUsedValueForVisited = 1;
    } else {
      ++_curUsedValueForVisited;
    }
    _visitedPixels[mouseX + mouseY * width] = _curUsedValueForVisited;

    //check neighbors (left, right, top, bottom)
    final checkNeighbor = (x, y) {
      if (x < 0 || x >= width || y < 0 || y >= height) return;
      final uint32PixelIndex = x + y * width;
      if (_visitedPixels[uint32PixelIndex] == _curUsedValueForVisited) return;

      if (constraintBuffer != null) {
        final colorFromConstraint = Color.fromRgbaInt(
          constraintBuffer[uint32PixelIndex],
        );

        if (checkConstraintExact(colorFromConstraint)) {
          _visitedPixels[uint32PixelIndex] = _curUsedValueForVisited;
          return;
        }
      }

      final colorToCheckRgba = imageBufferUint32[uint32PixelIndex];
      if (colorToCheckRgba == colorToReplaceRgba) {
        //need to change this particular color
        imageBufferUint32[uint32PixelIndex] = colorReplaceToRgba;
        queue.addLast([x, y]);
      } else {
        final colorToCheck = Color.fromRgbaInt(colorToCheckRgba);
        var diff = colorToCheck.difference(colorToReplace);
        if (diff < 600) {
          imageBufferUint32[uint32PixelIndex] = colorReplaceToRgba;
        } else if (diff < 283) {
          final base = uint32PixelIndex * 4;
          imageBufferUint8[base] = ((color.red + colorToCheck.red) / 2).round();
          imageBufferUint8[base + 1] =
              ((color.green + colorToCheck.green) / 2).round();
          imageBufferUint8[base + 2] =
              ((color.blue + colorToCheck.blue) / 2).round();
          imageBufferUint8[base + 3] =
              ((color.alpha + colorToCheck.alpha) / 2).round();
          //queue.add([x, y]);
        }
      }

      _visitedPixels[uint32PixelIndex] = _curUsedValueForVisited;
    };

    while (queue.isNotEmpty) {
      final item = queue.removeFirst();
      final x = item.first;
      final y = item.last;

      checkNeighbor(x - 1, y);
      checkNeighbor(x + 1, y);
      checkNeighbor(x, y - 1);
      checkNeighbor(x, y + 1);
    }

    final bitmap = Bitmap.fromHeadless(width, height, imageBufferUint8);
    return bitmap.buildImage();
  }
}

bool checkConstraintExact(Color colorFromConstraint) {
  final colorBlack = Color.fromColor(Colors.black);
  return colorFromConstraint.alpha > 100 &&
      colorFromConstraint.difference(colorBlack) < 300;
}

bool checkConstraintApprox(Color colorFromConstraint) {
  final colorBlack = Color.fromColor(Colors.black);
  return colorFromConstraint.alpha > 100 &&
      colorFromConstraint.difference(colorBlack) < 600;
}
