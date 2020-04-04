import 'dart:collection';
import 'dart:io';
import 'dart:ui' as dart_ui;
import 'package:flutter/foundation.dart';
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

    canvas.scale(scaleFactor);

    if (_cacheBuffer == null || redrawCache) {
      canvas.drawRect(Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
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
        .toImage(imageSize.width.toInt(), imageSize.height.toInt());
  }

  void _updateCacheBuffer(BuildContext context,
      {bool forceUpdateCache: false}) {
    if (kIsWeb) return; //There is some bug in canvas.drawImage and cache does not work properly

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
    print("cache = $_cacheBuffer");
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
