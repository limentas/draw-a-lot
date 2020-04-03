import 'dart:collection';
import 'dart:io';
import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';

import 'package:draw_a_lot/src/path_part.dart';

class PaintWidget extends StatefulWidget {
  PaintWidget(this.color, this.penWidth, {key}) : super(key: key) {
    print("create paint widget");
  }

  final Color color;
  final double penWidth;

  @override
  PaintWidgetState createState() =>
      PaintWidgetState(color: color, penWidth: penWidth);
}

class PaintWidgetState extends State<PaintWidget> {
  PaintWidgetState({this.color, this.penWidth});

  Color color = Colors.black;
  double penWidth = 0.0;

  Queue<PathPart> _pathesToDraw = new Queue<PathPart>();
  Queue<PathPart> _pathesDrawn = new Queue<PathPart>();
  Queue<PathPart> _pathesToRedo = new Queue<PathPart>();
  dart_ui.Image _cachedBuffer;

  void undo() {
    if (_pathesDrawn.isEmpty) return;
    setState(() {
      _pathesToRedo.add(_pathesDrawn.removeLast());
    });
  }

  void redo() {
    if (_pathesToRedo.isEmpty) return;
    _pathesDrawn.add(_pathesToRedo.removeLast());
  }

  void clean() {
    _pathesToRedo = _pathesDrawn;
    setState(() {
      _pathesDrawn = new Queue<PathPart>();
    });
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

  Future<dart_ui.Image> _drawToImage(BuildContext context, double scaleFactor) {
    var recorder = new dart_ui.PictureRecorder();
    var imageSize = MediaQuery.of(context).size * scaleFactor;
    var canvas = Canvas(recorder);

    canvas.scale(scaleFactor);
    if (_cachedBuffer == null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
          new Paint()..color = Colors.white);
    } else {
      _cachedBuffer.toByteData(format: dart_ui.ImageByteFormat.rawRgba).then((value){print("use cache = ${value.buffer.asUint8List()}");});
      canvas.drawImage(_cachedBuffer, Offset(0, 0), Paint());
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
        .toImage(imageSize.width.toInt(), imageSize.height.toInt());
  }

  void _updateCacheBuffer(BuildContext context) {
    var imageFuture = _drawToImage(context, 1.0);

    imageFuture.then((value) {
      setState(() {
        _cachedBuffer = value;

        _pathesDrawn.addAll(_pathesToDraw.where((element) => element.cached));
        _pathesToDraw.removeWhere((element) {
          return element.cached;
        });
      });
    }).catchError((error) {
      print("Error $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          var pathPart =
              new PathPart(color: color, penWidth: penWidth, path: Path());
          pathPart.path.moveTo(event.position.dx, event.position.dy);
          _pathesToDraw.add(pathPart);
          _pathesToRedo.clear();
        },
        onPointerMove: (event) {
          setState(() {
            _pathesToDraw.last.path
                .lineTo(event.position.dx, event.position.dy);
          });
        },
        onPointerUp: (event) {
          print("up");
          setState(() {
            _pathesToDraw.last.path
                .lineTo(event.position.dx, event.position.dy);
            _pathesToDraw.last.completed = true;
          });
          try {
            _updateCacheBuffer(context);
          } catch (error) {
            print("err = $error");
          }
        },
        child: CustomPaint(
          painter: _CustomPainter(_pathesToDraw, _cachedBuffer),
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
      canvas.drawImage(
          _cacheBuffer, Offset(0, 0), Paint());
    }

    print("size = ${_pathesToDraw.length}");

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
