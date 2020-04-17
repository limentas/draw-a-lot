import 'dart:collection';
import 'dart:ui' as dart_ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:draw_a_lot/src/path_part.dart';
import 'package:draw_a_lot/src/history_step.dart';
import 'package:draw_a_lot/src/paint_functions.dart';
import 'package:draw_a_lot/src/paint_tool.dart';
import 'package:flutter/services.dart';

class PaintWidget extends StatefulWidget {
  PaintWidget(this.color, this._paintTool, this._penThickness, {key})
      : super(key: key) {
    print("create paint widget");
  }

  final dart_ui.Color color;
  final PaintTool _paintTool;
  final double _penThickness;

  @override
  PaintWidgetState createState() => PaintWidgetState(
      color: color, paintTool: _paintTool, penThickness: _penThickness);
}

class PaintWidgetState extends State<PaintWidget> {
  PaintWidgetState({this.color, this.paintTool, this.penThickness});

  var color = Colors.black;
  double penThickness = 0.0;
  PaintTool paintTool = PaintTool.Pen;

  Queue<PathPart> _pathesToDraw = new Queue<PathPart>();

  //FIFO - last element was added last
  var _historyToUndo = new DoubleLinkedQueue<HistoryStep>();
  //LIFO - first element in history was las inserted
  var _historyToRedo = new DoubleLinkedQueue<HistoryStep>();

  dart_ui.Image _cacheBuffer;

  final _cacheHistoryLimit = 7;
  var _currentCachesInUndoHistory = 0;
  var _currentCachesInRedoHistory = 0;

  dart_ui.Image _imageForColoring;
  ByteData _imageForColoringByteData;
  var _loadedImageForColoringName;
  var _fillFinished = true;

  void undo() {
    if (_pathesToDraw.isNotEmpty) {
      setState(() {
        final lastChange = _pathesToDraw.removeLast();
        lastChange.completed = true;
        _historyToRedo.addLast(HistoryStep.fromPath(lastChange));
        if (lastChange.cached) {
          //needs to redraw cache
          _updateCacheBuffer(context, forceUpdateCache: true);
        }
      });
    } else if (_historyToUndo.isNotEmpty &&
        (_historyToUndo.length != 1 ||
            _historyToUndo.first.stepType != StepType.Cache)) {
      var last = _historyToUndo.removeLast();
      //for redo this step in case of cache we should add current cache to redo list
      if (last.stepType == StepType.Cache) {
        --_currentCachesInUndoHistory;
        ++_currentCachesInRedoHistory;
        _historyToRedo.addFirst(HistoryStep.fromCache(_cacheBuffer));
      } else {
        _historyToRedo.addFirst(last);
      }
      _updateCacheBuffer(context, forceUpdateCache: true);
    }
  }

  void redo() {
    if (_historyToRedo.isEmpty) return;
    var first = _historyToRedo.removeFirst();
    if (first.stepType == StepType.Cache) {
      ++_currentCachesInUndoHistory;
      --_currentCachesInRedoHistory;
    }
    _historyToUndo.addLast(first);
    _updateCacheBuffer(context, forceUpdateCache: true);
  }

  void clean() {
    _historyToRedo = _historyToUndo;
    _historyToUndo = new DoubleLinkedQueue<HistoryStep>();
    _currentCachesInRedoHistory = _currentCachesInUndoHistory;
    _currentCachesInUndoHistory = 0;
    _pathesToDraw.clear();
    _updateCacheBuffer(context, forceUpdateCache: true);
  }

  Future<dart_ui.Image> saveToImage() {
    return _drawToImage(context, MediaQuery.of(context).devicePixelRatio);
  }

  void setImageForColoring(String newImageForColoringName) {
    setState(() {
      if (newImageForColoringName == _loadedImageForColoringName) return;
      _loadedImageForColoringName = newImageForColoringName;
      if (newImageForColoringName == null || newImageForColoringName.isEmpty) {
        //switching to blank canvas mode
        _imageForColoringByteData = null;
        _imageForColoring = null;
        clean();
        return;
      }

      rootBundle.loadString(newImageForColoringName).then((svgStr) {
        return svg.fromSvgString(svgStr, null);
      }).then((drawable) {
        print(
            "viewport = ${drawable.viewport} rec = ${drawable.viewport.viewBoxRect}");
        return drawable.toPicture(size: MediaQuery.of(context).size);
      }).then((picture) {
        return picture.toImage(MediaQuery.of(context).size.width.ceil(),
            MediaQuery.of(context).size.height.ceil());
      }).then((image) {
        print(
            "image size = ${image.width}*${image.height} desired ${MediaQuery.of(context).size}");
        image
            .toByteData(format: dart_ui.ImageByteFormat.rawUnmodified)
            .then((byteData) {
          _imageForColoringByteData = byteData;
          setState(() {
            _imageForColoring = image;
          });
          clean();
        });
      });
    });
  }

  Future<dart_ui.Image> _drawToImage(BuildContext context, double scaleFactor,
      {bool redrawCache: false}) {
    var recorder = new dart_ui.PictureRecorder();
    var imageSize = MediaQuery.of(context).size * scaleFactor;
    var canvas = Canvas(recorder);

    if (scaleFactor != 1) canvas.scale(scaleFactor);

    if (redrawCache) {
      var entry = _historyToUndo.lastEntry();
      while (entry != null && entry.element.stepType != StepType.Cache) {
        entry = entry.previousEntry();
      }

      if (entry != null) {
        canvas.drawImage(entry.element.cache, Offset(0, 0), Paint());
        entry = entry.nextEntry(); //begining from next to cache path
      } else {
        //no cache image in history
        canvas.drawRect(
            Rect.fromLTWH(0, 0, imageSize.width.ceilToDouble(),
                imageSize.height.ceilToDouble()),
            new Paint()..color = Colors.white);
        entry = _historyToUndo.firstEntry(); //begining from first entry
      }

      while (entry != null) {
        final part = entry.element.path;
        canvas.drawPath(
            part.path,
            new Paint()
              ..color = part.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = part.penWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..isAntiAlias = true);
        entry = entry.nextEntry();
      }
    } else if (_cacheBuffer == null) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, imageSize.width.ceilToDouble(),
              imageSize.height.ceilToDouble()),
          new Paint()..color = Colors.white);
    } else {
      canvas.drawImage(_cacheBuffer, Offset(0, 0), Paint());
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

    if (_imageForColoring != null)
      canvas.drawImage(_imageForColoring, Offset(0, 0),
          Paint()..blendMode = BlendMode.darken);

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

        var cachedPathes = _pathesToDraw.where((element) => element.cached);
        for (var path in cachedPathes)
          _historyToUndo.add(HistoryStep.fromPath(path));

        _pathesToDraw.removeWhere((element) => element.cached);
      });
    }).catchError((error) {
      print("Update cache error $error");
    });
  }

  void _fillImage(BuildContext contex, Offset mousePosition) {
    if (!_fillFinished) return;
    _fillFinished = false;
    try {
      PaintFunctions.fillImage(_cacheBuffer, _imageForColoringByteData,
              MediaQuery.of(context).size, mousePosition, color)
          .catchError((e) {
        print("Fill color error catched: $e");
        _fillFinished = true;
      }).then((image) {
        if (image == null) {
          _fillFinished = true;
          return;
        }
        setState(() {
          if (_currentCachesInUndoHistory + _currentCachesInRedoHistory ==
              _cacheHistoryLimit) {
            HistoryStep
                item; //removing all items from begin untill and including first cache
            do {
              item = _historyToUndo.removeFirst();
            } while (item.stepType != StepType.Cache);
          } else {
            ++_currentCachesInUndoHistory;
          }
          _historyToUndo.add(HistoryStep.fromCache(image));
          _cacheBuffer = image;
          _fillFinished = true;
        });
      });
    } catch (err) {
      print("Fill color error: $err");
      _fillFinished = true;
    }
  }

  void _onMouseDown(BuildContext contex, PointerDownEvent event) {
    if (paintTool == PaintTool.Pen) {
      var pathPart =
          new PathPart(color: color, penWidth: penThickness, path: Path());
      pathPart.path.moveTo(event.position.dx, event.position.dy);
      _pathesToDraw.add(pathPart);
    } else if (paintTool == PaintTool.Fill) {
      _fillImage(contex, event.position);
    }

    if (_historyToRedo.isNotEmpty) {
      _historyToRedo.clear();
      _currentCachesInRedoHistory = 0;
    }
  }

  void _onMouseMove(PointerMoveEvent event) {
    if (paintTool == PaintTool.Pen) {
      setState(() {
        _pathesToDraw.last.path.lineTo(event.position.dx, event.position.dy);
      });
    } else if (paintTool == PaintTool.Fill) {}
  }

  void _onMouseUp(PointerUpEvent event) {
    if (paintTool == PaintTool.Pen) {
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
          painter:
              _CustomPainter(_pathesToDraw, _cacheBuffer, _imageForColoring),
          size: Size.infinite,
          isComplex: true,
        ));
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(Queue<PathPart> pathesToDraw, dart_ui.Image cacheBuffer,
      dart_ui.Image imageForColoring)
      : _pathesToDraw = pathesToDraw,
        _cacheBuffer = cacheBuffer,
        _imageForColoring = imageForColoring;

  Queue<PathPart> _pathesToDraw;
  dart_ui.Image _cacheBuffer;
  dart_ui.Image _imageForColoring;

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

    if (_imageForColoring != null)
      canvas.drawImage(_imageForColoring, Offset(0, 0),
          Paint()..blendMode = BlendMode.darken);
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
