import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:intl/intl.dart';

import 'package:flutter/services.dart';

class OsFunctions {
  static MethodChannel _platform;
  static const String _DIRECTORY_PICTURES = "Pictures";

  static Completer<bool> _permissionRequestResult;

  static Future _callHandler(MethodCall call) {
    switch (call.method) {
      case 'setPermissionRequestResult':
        _setPermissionRequestResultHandler(call.arguments[0]);
        return null;
    }
    return null;
  }

  static Future<bool> checkAndRequestWritePermissions() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }

    _ensureInit();

    _permissionRequestResult = Completer<bool>();
    var immidiateResult =
        await _platform.invokeMethod('checkAndRequestWritePermissions');
    if (immidiateResult) {
      print("Write permissions granted already");
      return true;
    }
    return _permissionRequestResult.future;
  }

  static Future<bool> saveToGallery(Future<Image> imageFuture) async {
    final imageBytes = await imageFuture
        .then((image) => image.toByteData(format: ImageByteFormat.png));

    return _platform.invokeMethod('saveImageToGallery',
        {'imagePngData': imageBytes.buffer.asUint8List()});
  }

  static Future<String> saveImage(Future<Image> imageFuture) async {
    final picturesPath =
        await _getExternalStoragePublicDirectory(_DIRECTORY_PICTURES);
    final myImagePath = '$picturesPath/DrawALot';
    final myImgDir = new Directory(myImagePath).create();

    String newFileName;
    var i = 0;
    var formatter = new DateFormat('yyyyMMdd');
    do {
      newFileName =
          "$myImagePath/drawing_${formatter.format(DateTime.now())}_${i++}.png";
    } while (FileSystemEntity.typeSync(newFileName) !=
        FileSystemEntityType.notFound);

    var file = await myImgDir.then((value) => new File(newFileName).create());
    var imageBytes = await imageFuture
        .then((image) => image.toByteData(format: ImageByteFormat.png));
    file
        .writeAsBytes(imageBytes.buffer.asUint8List())
        .whenComplete(() => _rescanGallery(file.path));
    return file.path;
  }

  static void _ensureInit() {
    if (_platform == null) {
      _platform = MethodChannel('slebe.dev/draw-a-lot');
      _platform.setMethodCallHandler(_callHandler);
    }
  }

  static void _setPermissionRequestResultHandler(bool result) {
    print("_setPermissionRequestResultHandler res = $result");
    _permissionRequestResult.complete(result);
  }

  static Future<String> _getExternalStoragePublicDirectory(String type) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }

    _ensureInit();

    return await _platform
        .invokeMethod('getExternalStoragePublicDirectory', {'type': type});
  }

  static void _rescanGallery(String path) {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }

    _ensureInit();

    try {
      _platform.invokeMethod('rescanGallery', <String, dynamic>{'path': path});
    } catch (e) {
      print("Failed to rescan gallery: $e");
    }
  }
}
