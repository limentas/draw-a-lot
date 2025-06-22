import 'dart:collection';
import 'dart:ui' as dart_ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:draw_a_lot/src/pen_path.dart';
import 'package:draw_a_lot/src/history_step.dart';
import 'package:draw_a_lot/src/paint_functions.dart';
import 'package:draw_a_lot/src/paint_tool.dart';
import 'package:draw_a_lot/src/paint_data.dart';
import 'package:draw_a_lot/src/color.dart' as my_color;

class PaintWidget extends StatefulWidget {
  PaintWidget(this.paintTool, this.color, this.penThickness, {key})
      : super(key: key);

  final PaintTool paintTool;
  final dart_ui.Color color;
  final double penThickness;

  @override
  PaintWidgetState createState() =>
      PaintWidgetState(paintTool, color, penThickness);
}

class RepaintNotifier extends ChangeNotifier {
  void repaint() {
    notifyListeners();
  }
}

class PaintWidgetState extends State<PaintWidget> {
  PaintWidgetState(this.paintTool, this.color, this.penThickness) {}

  PaintTool paintTool;
  dart_ui.Color color;
  double penThickness;

  //FIFO - last element was added last
  var _historyToUndo = new DoubleLinkedQueue<HistoryStep>();
  //LIFO - first element in history was las inserted
  var _historyToRedo = new DoubleLinkedQueue<HistoryStep>();

  final _cacheHistoryLimit = 7;
  var _currentCachesInUndoHistory = 0;
  var _currentCachesInRedoHistory = 0;

  final PaintData _paintData = PaintData();
  var _loadedImageForColoringName;
  var _fillFinished = true;
  var _repaintNotifier = new RepaintNotifier();
  var _cacheUpdateInProgress = false;
  var _updateCacheEnqueued = false;
  var _forceUpdateCacheEnqueued = false;
  late Size _screenPhysicalSize;
  late Size _screenLogicalSize;
  //Look at MediaQuery.of(context).devicePixelRatio
  late double _devicePixelRatio;

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
      //to redo this step in case of cache we should add current cache to redo list
      if (last.stepType == StepType.Cache) {
        if (_paintData.currentImage != null) {
          --_currentCachesInUndoHistory;
          ++_currentCachesInRedoHistory;
          _historyToRedo.addFirst(
            HistoryStep.fromCache(_paintData.currentImage!),
          );
        }
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
    return _drawToImage(_screenPhysicalSize);
  }

  void setImageForColoring(String newImageForColoringName) async {
    if (newImageForColoringName.isEmpty) {
      //switching to blank canvas mode
      _loadedImageForColoringName = newImageForColoringName;
      _paintData.imageForColoring = null;
      _paintData.imageForColoringBytes = null;
      clean();
      repaint();
      return;
    }
    if (newImageForColoringName == _loadedImageForColoringName) return;
    _loadedImageForColoringName = newImageForColoringName;

    final stopwatch = Stopwatch()..start();
    _paintData.imageForColoring = await PaintFunctions.rasterizeSvgFromAsset(
        newImageForColoringName,
        _screenPhysicalSize.width.ceil(),
        _screenPhysicalSize.height.ceil());
    print("Rasterizing vector image took ${stopwatch.elapsed}");
    _paintData.imageForColoringBytes = await _paintData.imageForColoring!
        .toByteData(format: dart_ui.ImageByteFormat.rawUnmodified);

    clean();
    repaint();
  }

  Future<dart_ui.Image> _drawToImage(
    Size imageSize, {
    bool redrawCache = false,
  }) {
    final recorder = dart_ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (redrawCache) {
      var entry = _historyToUndo.lastEntry();
      while (entry != null && entry.element.stepType != StepType.Cache) {
        entry = entry.previousEntry();
      }

      if (entry != null) {
        canvas.drawImage(entry.element.cache!, Offset(0, 0), Paint());
        entry = entry.nextEntry(); //begining from next to cache path
      } else {
        //no cache image in history
        canvas.drawColor(Colors.white, BlendMode.src);
        entry = _historyToUndo.firstEntry(); //begining from first entry
      }

      canvas.save();
      canvas.scale(_devicePixelRatio);
      while (entry != null) {
        final part = entry.element.path;
        if (part != null)
          canvas.drawPath(
            part.path,
            new Paint()
              ..color = part.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = part.penWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..isAntiAlias = true,
          );
        entry = entry.nextEntry();
      }
      canvas.restore();
    } else if (_paintData.currentImage == null) {
      canvas.drawColor(Colors.white, BlendMode.src);
    } else {
      canvas.drawImage(_paintData.currentImage!, Offset(0, 0), Paint());
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
          ..isAntiAlias = true,
      );
      path.cached = true;
    }
    canvas.restore();

    if (_paintData.imageForColoring != null) {
      canvas.drawImage(
        _paintData.imageForColoring!,
        Offset(0, 0),
        Paint()..blendMode = BlendMode.darken,
      );
    }

    return recorder.endRecording().toImage(
          imageSize.width.ceil(),
          imageSize.height.ceil(),
        );
  }

  void _enqueueUpdateCacheBuffer({bool forceUpdate = false}) async {
    if (_cacheUpdateInProgress) {
      _updateCacheEnqueued = true;
      //if new update is forced, then enqueue force update
      if (forceUpdate) _forceUpdateCacheEnqueued = true;
      return;
    }

    _cacheUpdateInProgress = true;
    _updateCacheBuffer(forceUpdate: forceUpdate);
    _cacheUpdateInProgress = false;
    if (_updateCacheEnqueued) {
      _updateCacheEnqueued = false;
      _enqueueUpdateCacheBuffer(forceUpdate: _forceUpdateCacheEnqueued);
    }
  }

  void _updateCacheBuffer({bool forceUpdate = false}) async {
    // There is some bug in canvas.drawImage and cache does not work properly
    // This needs to be checked. A lot of time has passed since then.
    if (kIsWeb) return;

    try {
      _paintData.currentImage = await _drawToImage(
        _screenPhysicalSize,
        redrawCache: forceUpdate,
      );

      _paintData.currentImageBytes = await _paintData.currentImage!
          .toByteData(format: dart_ui.ImageByteFormat.rawUnmodified);

      // Now we pass pen paths to cached image to optimize further redraws
      final cachedPathes = _paintData.pathesToDraw.where(
        (element) => element.cached,
      );
      for (final path in cachedPathes)
        _historyToUndo.add(HistoryStep.fromPath(path));

      _paintData.pathesToDraw.removeWhere((element) => element.cached);
      repaint();
    } catch (error) {
      print("Update cache error $error");
    }
  }

  void _addPointToPath(int pointerId, Offset point, bool lastPoint) {
    var path = _paintData.pathesToDraw.firstWhereOrNull(
      (element) => element.pointerId == pointerId,
    );
    if (path == null) return;
    path.path.lineTo(point.dx, point.dy);
    path.completed = lastPoint;
  }

  void _fillImage(BuildContext contex, Offset mouseLogicalPosition) async {
    if (!_fillFinished) return;
    _fillFinished = false;
    try {
      final stopwatch = Stopwatch()..start();
      final touchPoint = mouseLogicalPosition * _devicePixelRatio;
      var image = await PaintFunctions.fillImage(
        _paintData.currentImage,
        _paintData.imageForColoringBytes,
        (
          width: _screenPhysicalSize.width.ceil(),
          height: _screenPhysicalSize.height.ceil(),
        ),
        (x: touchPoint.dx.ceil(), y: touchPoint.dy.ceil()),
        color,
      );
      if (identical(image, _paintData.currentImage)) {
        _fillFinished = true;
        return;
      }
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
      _paintData.currentImage = image;
      if (kDebugMode) {
        _paintData.currentImageBytes = await _paintData.currentImage!
            .toByteData(format: dart_ui.ImageByteFormat.rawUnmodified);
      }
      _fillFinished = true;
      repaint();
      print("Image filled for ${stopwatch.elapsed}");
    } catch (err) {
      print("Fill image error catched: $err");
      _fillFinished = true;
    }
  }

  void _debugTouchPoint(int pointerId, Offset point) {
    final touchPoint = point * _devicePixelRatio;
    final imageColor = my_color.Color.fromRgbaInt(
      _paintData.currentImageBytes?.buffer.asUint32List()[
              (touchPoint.dy * _screenPhysicalSize.width.ceil() + touchPoint.dx)
                  .toInt()] ??
          0,
    );
    final outlineColor = my_color.Color.fromRgbaInt(
      _paintData.imageForColoringBytes?.buffer.asUint32List()[
              (touchPoint.dy * _screenPhysicalSize.width.ceil() + touchPoint.dx)
                  .toInt()] ??
          0,
    );

    print(
        "_debugTouchPoint ${touchPoint}. Color: ${imageColor}, Outline: ${outlineColor}");
  }

  void _onMouseDown(BuildContext contex, PointerDownEvent event) {
    if (paintTool == PaintTool.Pen) {
      var pathPart = new PenPath(
        color: color,
        penWidth: penThickness,
        pointerId: event.pointer,
        path: Path(),
      );
      pathPart.path.moveTo(event.position.dx, event.position.dy);
      _paintData.pathesToDraw.add(pathPart);
    } else if (paintTool == PaintTool.Fill) {
      _fillImage(contex, event.position);
    } else if (paintTool == PaintTool.Debug) {
      _debugTouchPoint(event.pointer, event.position);
    }

    if (_historyToRedo.isNotEmpty) {
      _historyToRedo.clear();
      _currentCachesInRedoHistory = 0;
    }
  }

  void _onMouseMove(PointerMoveEvent event) {
    if (paintTool == PaintTool.Pen) {
      _addPointToPath(event.pointer, event.position, false);
      repaint();
    } else if (paintTool == PaintTool.Fill) {
    } else if (paintTool == PaintTool.Debug) {
      _debugTouchPoint(event.pointer, event.position);
    }
  }

  void _onMouseUp(PointerUpEvent event) {
    if (paintTool == PaintTool.Pen) {
      _addPointToPath(event.pointer, event.position, true);
      _enqueueUpdateCacheBuffer();
    } else if (paintTool == PaintTool.Debug) {
      _debugTouchPoint(event.pointer, event.position);
    }
  }

  @override
  @override
  void dispose() {
    _repaintNotifier.dispose();
    super.dispose();
  }

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
      ),
    );
  }

  void repaint() {
    _repaintNotifier.repaint();
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(this._paintData, Listenable repaint) : super(repaint: repaint);

  final PaintData _paintData;

  @override
  void paint(Canvas canvas, Size size) {
    if (_paintData.currentImage == null) {
      canvas.drawColor(Colors.white, BlendMode.src);
    } else {
      canvas.drawImageRect(
        _paintData.currentImage!,
        Rect.fromLTRB(
          0,
          0,
          _paintData.currentImage!.width.toDouble(),
          _paintData.currentImage!.height.toDouble(),
        ),
        Rect.fromLTRB(0, 0, size.width, size.height),
        Paint(),
      );
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
          ..isAntiAlias = true,
      );
    }

    if (_paintData.imageForColoring != null) {
      canvas.drawImageRect(
        _paintData.imageForColoring!,
        Rect.fromLTRB(
          0,
          0,
          _paintData.imageForColoring!.width.toDouble(),
          _paintData.imageForColoring!.height.toDouble(),
        ),
        Rect.fromLTRB(0, 0, size.width, size.height),
        Paint()..blendMode = BlendMode.darken,
      );
    }
  }

  @override
  bool shouldRepaint(_CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_CustomPainter oldDelegate) => false;
}
