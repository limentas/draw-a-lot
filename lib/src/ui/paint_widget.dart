import 'dart:collection';
import 'dart:ui' as dart_ui;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';

import 'package:draw_a_lot/src/pen_path.dart';
import 'package:draw_a_lot/src/history_step.dart';
import 'package:draw_a_lot/src/paint_functions.dart';
import 'package:draw_a_lot/src/paint_tool.dart';
import 'package:draw_a_lot/src/paint_data.dart';

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

  //FIFO - last element was added last
  var _historyToUndo = new DoubleLinkedQueue<HistoryStep>();
  //LIFO - first element in history was las inserted
  var _historyToRedo = new DoubleLinkedQueue<HistoryStep>();

  final _cacheHistoryLimit = 7;
  var _currentCachesInUndoHistory = 0;
  var _currentCachesInRedoHistory = 0;

  final PaintData _paintData = new PaintData();
  ByteData _imageForColoringByteData;
  var _loadedImageForColoringName;
  var _fillFinished = true;
  var _repaintNotifier = new ChangeNotifier();
  var _cacheUpdateInProgress = false;
  var _updateCacheEnqueued = false;
  var _forceUpdateCacheEnqueued = false;
  Size _screenPhysicalSize;
  Size _screenLogicalSize;
  double _devicePixelRatio; //Look at MediaQuery.of(context).devicePixelRatio

  void undo() {
    if (_paintData.pathesToDraw.isNotEmpty) {
      final lastChange = _paintData.pathesToDraw.removeLast();
      lastChange.completed = true;
      _historyToRedo.addLast(HistoryStep.fromPath(lastChange));
      if (lastChange.cached) {
        //needs to redraw cache
        _enqueueUpdateCacheBuffer(forceUpdate: true);
      } else {
        repaint();
      }
    } else if (_historyToUndo.isNotEmpty) {
      var last = _historyToUndo.removeLast();
      //for redo this step in case of cache we should add current cache to redo list
      if (last.stepType == StepType.Cache) {
        --_currentCachesInUndoHistory;
        ++_currentCachesInRedoHistory;
        _historyToRedo.addFirst(HistoryStep.fromCache(_paintData.cacheBuffer));
      } else {
        _historyToRedo.addFirst(last);
      }
      _enqueueUpdateCacheBuffer(forceUpdate: true);
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
    _enqueueUpdateCacheBuffer(forceUpdate: true);
  }

  void clean() {
    _historyToRedo = _historyToUndo;
    _historyToUndo = new DoubleLinkedQueue<HistoryStep>();
    _currentCachesInRedoHistory = _currentCachesInUndoHistory;
    _currentCachesInUndoHistory = 0;
    _paintData.pathesToDraw.clear();
    _enqueueUpdateCacheBuffer(forceUpdate: true);
  }

  Future<dart_ui.Image> saveToImage() {
    //return Future.value(_paintData.imageForColoring);
    return _drawToImage(_screenPhysicalSize);
  }

  void setImageForColoring(String newImageForColoringName) {
    if (newImageForColoringName == null || newImageForColoringName.isEmpty) {
      //switching to blank canvas mode
      _loadedImageForColoringName = newImageForColoringName;
      _imageForColoringByteData = null;
      _paintData.imageForColoring = null;
      clean();
      repaint();
      return;
    }
    if (newImageForColoringName == _loadedImageForColoringName) return;
    _loadedImageForColoringName = newImageForColoringName;

    rootBundle.loadString(newImageForColoringName).then((svgStr) {
      return svg.fromSvgString(svgStr, null);
    }).then((drawable) {
      print(
          "viewport = ${drawable.viewport} rec = ${drawable.viewport.viewBoxRect}");
      _paintData.rootForColoring = drawable;
      return drawable.toPicture(size: _screenPhysicalSize, clipToViewBox: true);
    }).then((picture) {
      _paintData.pictureForColoring = picture;
      return picture.toImage((_screenPhysicalSize.width).ceil(),
          (_screenPhysicalSize.height).ceil());
    }).then((image) {
      image
          .toByteData(format: dart_ui.ImageByteFormat.rawUnmodified)
          .then((byteData) {
        _imageForColoringByteData = byteData;
        _paintData.imageForColoring = image;

        clean();
        repaint();
      });
    });
  }

  Future<dart_ui.Image> _drawToImage(Size imageSize,
      {bool redrawCache: false}) {
    var recorder = new dart_ui.PictureRecorder();
    var canvas = Canvas(recorder);

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
        canvas.drawColor(Colors.white, BlendMode.src);
        // canvas.drawRect(
        //     Rect.fromLTWH(0, 0, imageSize.width.ceilToDouble(),
        //         imageSize.height.ceilToDouble()),
        //     new Paint()..color = Colors.white);
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
    } else if (_paintData.cacheBuffer == null) {
      // canvas.drawRect(
      //     Rect.fromLTWH(0, 0, imageSize.width.ceilToDouble(),
      //         imageSize.height.ceilToDouble()),
      //     new Paint()..color = Colors.white);
      canvas.drawColor(Colors.white, BlendMode.src);
    } else {
      canvas.drawImage(_paintData.cacheBuffer, Offset(0, 0), Paint());
    }

    canvas.save();
    canvas.scale(_devicePixelRatio);
    for (var path in _paintData.pathesToDraw) {
      if (!path.completed) continue;
      canvas.drawPath(
          path.path,
          new Paint()
            ..color = path.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = path.penWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..isAntiAlias = true);
      path.cached = true;
    }
    canvas.restore();

    // if (_paintData.imageForColoring != null)
    //   canvas.drawImage(_paintData.imageForColoring, Offset(0, 0),
    //       Paint()..blendMode = BlendMode.darken);

    return recorder
        .endRecording()
        .toImage(imageSize.width.ceil(), imageSize.height.ceil());
  }

  void _enqueueUpdateCacheBuffer({bool forceUpdate: false}) {
    if (_cacheUpdateInProgress) {
      _updateCacheEnqueued = true;
      //if new update is forced, then enqueue force update
      if (forceUpdate) _forceUpdateCacheEnqueued = true;
      return;
    }

    _cacheUpdateInProgress = true;
    _updateCacheBuffer(forceUpdate: forceUpdate).then((value) {
      _cacheUpdateInProgress = false;
      if (_updateCacheEnqueued) {
        _updateCacheEnqueued = false;
        _enqueueUpdateCacheBuffer(forceUpdate: _forceUpdateCacheEnqueued);
      }
    });
  }

  Future<void> _updateCacheBuffer({bool forceUpdate: false}) {
    if (kIsWeb)
      return new Future
          .value(); //There is some bug in canvas.drawImage and cache does not work properly

    var imageFuture =
        _drawToImage(_screenPhysicalSize, redrawCache: forceUpdate);

    return imageFuture.then((value) {
      _paintData.cacheBuffer = value;

      var cachedPathes =
          _paintData.pathesToDraw.where((element) => element.cached);
      for (var path in cachedPathes)
        _historyToUndo.add(HistoryStep.fromPath(path));

      _paintData.pathesToDraw.removeWhere((element) => element.cached);
      repaint();
    }).catchError((error) {
      print("Update cache error $error");
    });
  }

  void _fillImage(BuildContext contex, Offset mouseLogicalPosition) {
    if (!_fillFinished) return;
    _fillFinished = false;
    try {
      final stopwatch = Stopwatch()..start();
      PaintFunctions.fillImage(
              _paintData.cacheBuffer,
              _imageForColoringByteData,
              _screenPhysicalSize,
              mouseLogicalPosition * _devicePixelRatio,
              color)
          .catchError((e) {
        print("Fill color error catched: $e");
        _fillFinished = true;
      }).then((image) {
        if (image == null) {
          _fillFinished = true;
          return;
        }
        print("Image filled for ${stopwatch.elapsed}");
        if (_currentCachesInUndoHistory + _currentCachesInRedoHistory ==
            _cacheHistoryLimit) {
          //removing all items from begin untill and including first cache
          HistoryStep item;
          do {
            item = _historyToUndo.removeFirst();
          } while (item.stepType != StepType.Cache);
        } else {
          ++_currentCachesInUndoHistory;
        }
        _historyToUndo.add(HistoryStep.fromCache(image));
        _paintData.cacheBuffer = image;
        _fillFinished = true;
        repaint();
        print("Image filled2 for ${stopwatch.elapsed}");
      });
    } catch (err) {
      print("Fill color error: $err");
      _fillFinished = true;
    }
  }

  void _onMouseDown(BuildContext contex, PointerDownEvent event) {
    if (paintTool == PaintTool.Pen) {
      var pathPart = new PenPath(
          color: color,
          penWidth: penThickness,
          pointerId: event.pointer,
          path: Path());
      pathPart.path.moveTo(event.position.dx, event.position.dy);
      _paintData.pathesToDraw.add(pathPart);
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
      var path = _paintData.pathesToDraw
          .firstWhere((element) => element.pointerId == event.pointer);
      if (path == null) return;
      path.path.lineTo(event.position.dx, event.position.dy);
      repaint();
    } else if (paintTool == PaintTool.Fill) {}
  }

  void _onMouseUp(PointerUpEvent event) {
    if (paintTool == PaintTool.Pen) {
      var path = _paintData.pathesToDraw
          .firstWhere((element) => element.pointerId == event.pointer);
      if (path == null) return;
      path.path.lineTo(event.position.dx, event.position.dy);
      path.completed = true;
      try {
        _enqueueUpdateCacheBuffer();
      } catch (error) {
        print("err = $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenLogicalSize = MediaQuery.of(context).size;
    _devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    _screenPhysicalSize = _screenLogicalSize * _devicePixelRatio;

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
          painter: _CustomPainter(_paintData, _repaintNotifier),
          size: _screenLogicalSize,
          isComplex: true,
        ));
  }

  void repaint() {
    _repaintNotifier.notifyListeners();
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(this._paintData, Listenable repaint) : super(repaint: repaint);

  final PaintData _paintData;

  @override
  void paint(Canvas canvas, Size size) {
    if (_paintData.cacheBuffer == null) {
      // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      //     new Paint()..color = Colors.white);
      canvas.drawColor(Colors.white, BlendMode.src);
    } else {
      canvas.drawImageRect(
          _paintData.cacheBuffer,
          Rect.fromLTRB(0, 0, _paintData.cacheBuffer.width.toDouble(),
              _paintData.cacheBuffer.height.toDouble()),
          Rect.fromLTRB(0, 0, size.width, size.height),
          Paint());
    }

    for (var path in _paintData.pathesToDraw) {
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

    if (_paintData.imageForColoring != null)
      canvas.drawImageRect(
          _paintData.imageForColoring,
          Rect.fromLTRB(0, 0, _paintData.imageForColoring.width.toDouble(),
              _paintData.imageForColoring.height.toDouble()),
          Rect.fromLTRB(0, 0, size.width, size.height),
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
