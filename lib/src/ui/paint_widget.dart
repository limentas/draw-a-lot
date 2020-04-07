import 'dart:collection';
import 'dart:io';
import 'dart:ui' as dart_ui;
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bitmap/bitmap.dart';

import 'package:draw_a_lot/src/path_part.dart';
import 'package:draw_a_lot/src/color.dart';

class PaintWidget extends StatefulWidget {
  PaintWidget(this.color, this.penWidth, {key}) : super(key: key) {
    print("create paint widget");
  }

  final dart_ui.Color color;
  final double penWidth;

  @override
  PaintWidgetState createState() =>
      PaintWidgetState(color: color, penWidth: penWidth);
}

enum PaintTool { Pen, Fill }

class PaintWidgetState extends State<PaintWidget> {
  PaintWidgetState({this.color, this.penWidth});

  var color = Colors.black;
  double penWidth = 0.0;
  PaintTool tool = PaintTool.Pen;

  Queue<PathPart> _pathesToDraw = new Queue<PathPart>();
  Queue<PathPart> _pathesDrawn = new Queue<PathPart>();
  Queue<PathPart> _pathesToRedo = new Queue<PathPart>();
  dart_ui.Image _cacheBuffer;

  void undo() {
    if (_pathesToDraw.isNotEmpty) {
      setState(() {
        final lastChange = _pathesToDraw.removeLast();
        lastChange.completed = true;
        _pathesToRedo.add(lastChange);
        if (lastChange.cached) {
          //needs to redraw cache
          _updateCacheBuffer(context, forceUpdateCache: true);
        }
      });
    } else if (_pathesDrawn.isNotEmpty) {
      _pathesToRedo.add(_pathesDrawn.removeLast());
      _updateCacheBuffer(context, forceUpdateCache: true);
    }
  }

  void redo() {
    if (_pathesToRedo.isEmpty) return;
    setState(() {
      _pathesToDraw.add(_pathesToRedo.removeLast());
    });
    _updateCacheBuffer(context);
  }

  void clean() {
    _pathesToRedo = _pathesDrawn;
    _pathesToRedo.addAll(_pathesToDraw);
    _pathesDrawn = new Queue<PathPart>();
    _pathesToDraw.clear();
    _updateCacheBuffer(context, forceUpdateCache: true);
  }

  Future<File> saveToFile(File file) {
    var imageBytes =
        _drawToImage(context, MediaQuery.of(context).devicePixelRatio)
            .then((value) {
      return value.toByteData(format: dart_ui.ImageByteFormat.png);
    });
    return imageBytes.then((bytes) {
      return file.writeAsBytes(bytes.buffer.asUint8List());
    });
  }

  Future<dart_ui.Image> _drawToImage(BuildContext context, double scaleFactor,
      {bool redrawCache: false}) {
    var recorder = new dart_ui.PictureRecorder();
    var imageSize = MediaQuery.of(context).size * scaleFactor;
    var canvas = Canvas(recorder);

    if (scaleFactor != 1) canvas.scale(scaleFactor);

    if (_cacheBuffer == null || redrawCache) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, imageSize.width.ceilToDouble(),
              imageSize.height.ceilToDouble()),
          new Paint()..color = Colors.white);
    } else {
      canvas.drawImage(_cacheBuffer, Offset(0, 0), Paint());
    }

    if (redrawCache) {
      for (var part in _pathesDrawn) {
        canvas.drawPath(
            part.path,
            new Paint()
              ..color = part.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = part.penWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..isAntiAlias = true);
      }
    }

    for (var part in _pathesToDraw) {
      if (!part.completed) continue;
      canvas.drawPath(
          part.path,
          new Paint()
            ..color = part.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = part.penWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..isAntiAlias = true);
      part.cached = true;
    }

    return recorder
        .endRecording()
        .toImage(imageSize.width.ceil(), imageSize.height.ceil());
  }

  void _updateCacheBuffer(BuildContext context,
      {bool forceUpdateCache: false}) {
    if (kIsWeb)
      return; //There is some bug in canvas.drawImage and cache does not work properly

    var imageFuture = _drawToImage(context, 1.0, redrawCache: forceUpdateCache);

    imageFuture.then((value) {
      setState(() {
        _cacheBuffer = value;

        _pathesDrawn.addAll(_pathesToDraw.where((element) => element.cached));
        _pathesToDraw.removeWhere((element) => element.cached);
      });
    }).catchError((error) {
      print("Update cache error $error");
    });
  }

  void _perfomFill(
      BuildContext context, ByteData imageData, Offset mousePosition) {
    final mouseX = mousePosition.dx.toInt();
    final mouseY = mousePosition.dy.toInt();
    final width = MediaQuery.of(context).size.width.ceil();
    final height = MediaQuery.of(context).size.height.ceil();

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
    if (colorToReplace == colorReplaceTo) return;

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


    bitmap.buildImage().then((value) {
      setState(() {
        _cacheBuffer = value;
      });
    });
  }

  void _fillPoint(BuildContext contex, Offset mousePosition) {
    if (_cacheBuffer == null) {
      _perfomFill(contex, null, mousePosition);
      return;
    }
    final byteDataFuture =
        _cacheBuffer.toByteData(format: dart_ui.ImageByteFormat.rawUnmodified);
    byteDataFuture.then((imageData) {
      _perfomFill(context, imageData, mousePosition);
    });
  }

  void _onMouseDown(BuildContext contex, PointerDownEvent event) {
    if (tool == PaintTool.Pen) {
      var pathPart =
          new PathPart(color: color, penWidth: penWidth, path: Path());
      pathPart.path.moveTo(event.position.dx, event.position.dy);
      _pathesToDraw.add(pathPart);
      _pathesToRedo.clear();
    } else if (tool == PaintTool.Fill) {
      _fillPoint(contex, event.position);
    }
  }

  void _onMouseMove(PointerMoveEvent event) {
    if (tool == PaintTool.Pen) {
      setState(() {
        _pathesToDraw.last.path.lineTo(event.position.dx, event.position.dy);
      });
    } else if (tool == PaintTool.Fill) {
      //_fillPoint(event.position);
    }
  }

  void _onMouseUp(PointerUpEvent event) {
    if (tool == PaintTool.Pen) {
      setState(() {
        _pathesToDraw.last.path.lineTo(event.position.dx, event.position.dy);
        _pathesToDraw.last.completed = true;
      });
      try {
        _updateCacheBuffer(context);
      } catch (error) {
        print("err = $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _onMouseDown(context, event);
        },
        onPointerMove: (event) {
          _onMouseMove(event);
        },
        onPointerUp: (event) {
          _onMouseUp(event);
        },
        child: CustomPaint(
          painter: _CustomPainter(_pathesToDraw, _cacheBuffer),
          size: Size.infinite,
          isComplex: true,
        ));
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(Queue<PathPart> pathesToDraw, dart_ui.Image cacheBuffer)
      : _pathesToDraw = pathesToDraw,
        _cacheBuffer = cacheBuffer;

  Queue<PathPart> _pathesToDraw;
  dart_ui.Image _cacheBuffer;

  @override
  void paint(Canvas canvas, Size size) {
    if (_cacheBuffer == null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
          new Paint()..color = Colors.white);
    } else {
      canvas.drawImage(_cacheBuffer, Offset(0, 0), Paint());
    }

    for (var path in _pathesToDraw) {
      canvas.drawPath(
          path.path,
          new Paint()
            ..color = path.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = path.penWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..isAntiAlias = true);
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return null;
  }

  @override
  bool shouldRepaint(_CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_CustomPainter oldDelegate) => false;
}
