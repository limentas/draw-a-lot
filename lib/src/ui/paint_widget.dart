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

  PathPart _pathToDraw;
  List<PathPart> _pathesDrawn = new List<PathPart>();
  List<PathPart> _pathesToRedo = new List<PathPart>();
  dart_ui.Image _frameBuffer;
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
      _pathesDrawn = new List<PathPart>();
    });
  }

  Future<File> saveToFile(File file) {
    var imageBytes =
        _drawToImageAll(context, MediaQuery.of(context).devicePixelRatio)
            .then((value) {
      return value.toByteData(format: dart_ui.ImageByteFormat.png);
    });
    return imageBytes.then((bytes) {
      return file.writeAsBytes(bytes.buffer.asUint8List());
    });
  }

  Future<dart_ui.Image> _drawToImageAll(
      BuildContext context, double scaleFactor) {
    var recorder = new dart_ui.PictureRecorder();
    var imageSize = MediaQuery.of(context).size * scaleFactor;
    _paintAll(Canvas(recorder), imageSize, scaleFactor);
    return recorder
        .endRecording()
        .toImage(imageSize.width.toInt(), imageSize.height.toInt());
  }

  Future<dart_ui.Image> _drawToImageIncremental(
      BuildContext context, double scaleFactor) {
    var recorder = new dart_ui.PictureRecorder();
    var imageSize = MediaQuery.of(context).size * scaleFactor;
    _paintIncremental(Canvas(recorder), imageSize);
    return recorder
        .endRecording()
        .toImage(imageSize.width.toInt(), imageSize.height.toInt());
  }

  void _paintAll(Canvas canvas, Size size, double scaleFactor) {
    canvas.scale(scaleFactor);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        new Paint()..color = Colors.white);
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

  void _paintIncremental(Canvas canvas, Size size) {
    canvas.drawImage(_cachedBuffer, Offset(0, 0), Paint());
    canvas.drawPath(
        _pathToDraw.path,
        new Paint()
          ..color = _pathToDraw.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _pathToDraw.penWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true);
  }

  void ensureBuffersCreated(BuildContext context) async {
    dart_ui.Image image;
    if (_frameBuffer == null || _cachedBuffer == null)
      image = await _drawToImageAll(context, 1.0);

    if (_frameBuffer == null) _frameBuffer = image;
    if (_cachedBuffer == null) _cachedBuffer = image;
    print("ensure $_frameBuffer $_cachedBuffer");
  }

  @override
  Widget build(BuildContext context) {
    ensureBuffersCreated(context);

    return new Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _pathToDraw =
              new PathPart(color: color, penWidth: penWidth, path: Path());
          _pathToDraw.path.moveTo(event.position.dx, event.position.dy);
          _pathesToRedo.clear();
          _drawToImageIncremental(context, 1.0).then((newImage) {
            setState(() {
              _frameBuffer = newImage;
            });
          });
        },
        onPointerMove: (event) {
          print("move");
          _pathToDraw.path.lineTo(event.position.dx, event.position.dy);
          var start = DateTime.now();
          _drawToImageIncremental(context, 1.0).then(
            (newImage) {
              print("elapse: ${DateTime.now().difference(start)}");
            setState(() {
              _frameBuffer = newImage;
            });
          });
        },
        onPointerUp: (event) {
          _pathToDraw.path.lineTo(event.position.dx, event.position.dy);
          _drawToImageIncremental(context, 1.0).then((newImage) {
            setState(() {
              _frameBuffer = newImage;
              _cachedBuffer = newImage;
              _pathesDrawn.add(_pathToDraw);
              _pathToDraw = null;
              print("up");
            });
          });
        },
        child: CustomPaint(
          painter: _CustomPainter(
              _cachedBuffer, DateTime.now().millisecondsSinceEpoch),
          size: Size.infinite,
          isComplex: true,
        ));
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(dart_ui.Image frameBuffer, int msSinceEpoch)
      : _frameBuffer = frameBuffer,
        _msSinceEpoch = msSinceEpoch {
    print("ctor $_frameBuffer");
  }

  dart_ui.Image _frameBuffer;
  int _msSinceEpoch;

  @override
  void paint(Canvas canvas, Size size) {
    if (_frameBuffer != null)
      canvas.drawImage(_frameBuffer, Offset(0, 0), Paint());
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return null;
  }

  @override
  bool shouldRepaint(_CustomPainter oldDelegate) =>
      this._msSinceEpoch != oldDelegate._msSinceEpoch;

  @override
  bool shouldRebuildSemantics(_CustomPainter oldDelegate) => false;
}
