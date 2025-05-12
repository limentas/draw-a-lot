import 'dart:ui' as dart_ui;
import 'dart:typed_data';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'color.dart';

class PaintFunctions {
  static Uint32List _visitedPixels = Uint32List(0);
  static int _curUsedValueForVisited = 0;

  static final _maxUsedValueForVisited = pow(2, 31);

  // Make "fill" operation and returns result image.
  // If there is nothing to do, then this method returns the same `image` object
  // outlineForColoring - is the image containig picture for coloring (usually only contour lines)
  // image and outlineForColoring have the same size passed via imageSize
  static Future<dart_ui.Image?> fillImage(
    dart_ui.Image? image,
    ByteData? outlineForColoring,
    ({int width, int height}) imageSize,
    ({int x, int y}) touchPoint,
    dart_ui.Color targetColor,
  ) async {
    Future<dart_ui.Image>? result;
    ByteData? imageData = null;
    Uint32List? u32ImageBuffer = null;
    Uint32List? u32OutlineBuffer = null;

    if (image != null) {
      imageData = await image.toByteData(
        format: dart_ui.ImageByteFormat.rawUnmodified,
      );
      if (imageData == null) throw Exception("Couldn't covert image to RAW?");
      u32ImageBuffer = imageData.buffer.asUint32List();
    }

    if (outlineForColoring != null) {
      u32OutlineBuffer = outlineForColoring.buffer.asUint32List();
    }

    var correctedTouchPoint = _correctFillPoint(
        u32ImageBuffer, u32OutlineBuffer, imageSize, touchPoint, targetColor);

    if (correctedTouchPoint == null) return image;

    print(
        "Touch point corrected from ${touchPoint.toString()} to ${correctedTouchPoint.toString()}");
    touchPoint = correctedTouchPoint;

    result = _perfomFill(
      imageData,
      outlineBuffer,
      imageSize,
      touchPoint,
      targetColor,
    );
    if (result == null) return image;
    return result;
  }

  // Rasterizes an SVG file from assets to Image with specified pixel size
  static Future<dart_ui.Image> rasterizeSvgFromAsset(
      String assetPath, int targetWidth, int targetHeight) async {
    final rawSvg = await rootBundle.loadString(assetPath);
    final pictureInfo = await vg.loadPicture(SvgStringLoader(rawSvg), null);
    final scale = min(
      targetWidth / pictureInfo.size.width,
      targetHeight / pictureInfo.size.height,
    );
    final scaledSvgWidth = pictureInfo.size.width * scale;
    final scaledSvgHeight = pictureInfo.size.height * scale;

    print("Picture for coloring original size = ${pictureInfo.size}, "
        "scale = ${scale}, "
        "scaled size: ${scaledSvgWidth} x ${scaledSvgHeight}");

    final recorder = dart_ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final dx = (targetWidth - scaledSvgWidth) / 2;
    final dy = (targetHeight - scaledSvgHeight) / 2;
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.drawPicture(pictureInfo.picture);
    final rasterPicture = recorder.endRecording();
    return rasterPicture.toImage(targetWidth, targetHeight);
  }

  // It happens a lot that sensor screen doesn't give us correct point
  // a user wanted to color. He we try to correct this. If user clicked
  // outline or on a segment of the same color we try to find a closest
  // point that is not part of outline and that has another color.
  // Returns null if there is no such point in cosidered neighbourhood.
  static ({int x, int y})? _correctFillPoint(
      Uint32List? u32ImageBuffer,
      Uint32List? u32OutlineBuffer,
      ({int width, int height}) imageSize,
      ({int x, int y}) touchPoint,
      dart_ui.Color targetColor) {
    final checkPoint = (({int x, int y}) point) {
      if (point.x < 0 ||
          point.x >= imageSize.width ||
          point.y < 0 ||
          point.y >= imageSize.height) return false;
      if (u32OutlineBuffer != null) {
        final colorFromConstraint = Color.fromRgbaInt(
          u32OutlineBuffer[point.x + point.y * imageSize.width],
        );
        if (_checkConstraintApprox(colorFromConstraint)) return false;
      }

      if (u32ImageBuffer != null) {
        final colorFromImage = Color.fromRgbaInt(
          u32ImageBuffer[point.x + point.y * imageSize.width],
        );
        if (targetColor == colorFromImage) return false;
      }
      return true;
    };

    // Check touch point itself. Maybe we don't need to correct it.
    if (checkPoint(touchPoint)) return touchPoint;

    // We don't use Euclidean distance here. To simplify integer math
    // we just go over squares with size 0, 3, 5, ... with center in touchPoint
    const maxRadiusToCheck = 10;
    for (var squareSize = 1; squareSize <= maxRadiusToCheck; ++squareSize) {
      // At first we check points that lie on horizontal and vertical axes
      var point = (x: touchPoint.x - squareSize, y: touchPoint.y);
      if (checkPoint(point)) return point;
      point = (x: touchPoint.x + squareSize, y: touchPoint.y);
      if (checkPoint(point)) return point;
      point = (x: touchPoint.x, y: touchPoint.y - squareSize);
      if (checkPoint(point)) return point;
      point = (x: touchPoint.x, y: touchPoint.y + squareSize);
      if (checkPoint(point)) return point;

      // No we start to go over the square of size squareSize
      // The order of the process:
      // TODO:
      for (var axisDistance = 1; axisDistance <= squareSize; ++axisDistance) {
        var point =
            (x: touchPoint.x - squareSize, y: touchPoint.y - axisDistance);
        if (checkPoint(point)) return point;
        point = (x: touchPoint.x - squareSize, y: touchPoint.y + axisDistance);
        if (checkPoint(point)) return point;
        point = (x: touchPoint.x + squareSize, y: touchPoint.y - axisDistance);
        if (checkPoint(point)) return point;
        point = (x: touchPoint.x + squareSize, y: touchPoint.y + axisDistance);
        if (checkPoint(point)) return point;
        point = (x: touchPoint.x - axisDistance, y: touchPoint.y - squareSize);
        if (checkPoint(point)) return point;
        point = (x: touchPoint.x + axisDistance, y: touchPoint.y - squareSize);
        if (checkPoint(point)) return point;
        point = (x: touchPoint.x - axisDistance, y: touchPoint.y + squareSize);
        if (checkPoint(point)) return point;
        point = (x: touchPoint.x + axisDistance, y: touchPoint.y + squareSize);
        if (checkPoint(point)) return point;
      }
    }

    // We couldn't find a point satisfying the criteria above.
    return null;
  }

  // Return null if there is nothing to do
  static Future<dart_ui.Image>? _perfomFill(
    ByteData? imageData,
    Uint32List? constraintBuffer,
    dart_ui.Size constraintImageSize,
    dart_ui.Offset fillPoint,
    dart_ui.Color color,
  ) {
    final mouseX = fillPoint.dx.toInt();
    final mouseY = fillPoint.dy.toInt();
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

    final colorToReplaceRgba = imageBufferUint32[mouseX + mouseY * width];
    if (colorToReplaceRgba == colorReplaceToRgba) return null;

    final colorToReplace = Color.fromRgbaInt(colorToReplaceRgba);

    print(
        "colorToReplace = ${colorToReplace} colorReplaceToRgba = ${colorReplaceTo}");

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

        if (_checkConstraintExact(colorFromConstraint)) {
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

    return imageFromBuffer(width, height, imageBufferUint8);
  }

  static bool _checkConstraintExact(Color colorFromConstraint) {
    final colorBlack = Color.fromColor(Colors.black);
    return colorFromConstraint.alpha > 100 &&
        colorFromConstraint.difference(colorBlack) < 300;
  }

  static bool _checkConstraintApprox(Color colorFromConstraint) {
    final colorBlack = Color.fromColor(Colors.black);
    return colorFromConstraint.alpha > 100 &&
        colorFromConstraint.difference(colorBlack) < 600;
  }

  static Future<dart_ui.Image> imageFromBuffer(
      int width, int height, Uint8List data) async {
    final buffer = await dart_ui.ImmutableBuffer.fromUint8List(data);
    try {
      final descriptor = dart_ui.ImageDescriptor.raw(buffer,
          width: width,
          height: height,
          pixelFormat: dart_ui.PixelFormat.rgba8888);
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      buffer.dispose();
    }
  }
}
