import 'dart:io';
import 'dart:ui';
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
  PaintWidgetState({this.color, this.penWidth})
      : _pathes = new List<PathPart>() {
    _painter = new _CustomPainter(_pathes);
  }

  Color color = Colors.black;
  double penWidth = 0.0;

  List<PathPart> _pathes;
  List<PathPart> _pathesToRedo = new List<PathPart>();
  _CustomPainter _painter;

  double transformY(double y) {
    //return y - 56;
    return y;
  }

  void undo() {
    if (_pathes.isEmpty) return;
    setState(() {
      _pathesToRedo.add(_pathes.removeLast());
    });
  }

  void redo() {
    if (_pathesToRedo.isEmpty) return;
    _pathes.add(_pathesToRedo.removeLast());
  }

  void clean() {
    _pathesToRedo = _pathes;
    setState(() {
      _pathes = new List<PathPart>();
    });
  }

  Future<void> saveToFile(File file) async {
    var recorder = new PictureRecorder();
    var imageSize = MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    print("image size = $imageSize");
    _painter._paint(Canvas(recorder), imageSize, MediaQuery.of(context).devicePixelRatio);
    var image = await recorder
        .endRecording()
        .toImage(imageSize.width.toInt(), imageSize.height.toInt());
    var imageBytes = await image.toByteData(format: ImageByteFormat.png);
    final buffer = imageBytes.buffer;
    await file.writeAsBytes(buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return new Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          var part =
              new PathPart(color: color, penWidth: penWidth, path: Path());
          part.path.moveTo(event.position.dx, transformY(event.position.dy));
          _pathes.add(part);
          _pathesToRedo.clear();
        },
        onPointerUp: (event) {
          setState(() {
            _pathes.last.path
                .lineTo(event.position.dx, transformY(event.position.dy));
          });
        },
        onPointerMove: (event) {
          setState(() {
            _pathes.last.path
                .lineTo(event.position.dx, transformY(event.position.dy));
          });
        },
        child: CustomPaint(
          painter: _painter = _CustomPainter(_pathes),
          size: Size.infinite,
          isComplex: true,
        ));
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(List<PathPart> pathes) : _pathes = pathes;

  List<PathPart> _pathes;

  void _paint(Canvas canvas, Size size, double scaleFactor) {
    canvas.scale(scaleFactor);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        new Paint()..color = Colors.white);
    for (var part in _pathes) {
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

  @override
  void paint(Canvas canvas, Size size) {
    _paint(canvas, size, 1.0);
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
