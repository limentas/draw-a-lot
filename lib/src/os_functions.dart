import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

class OsFunctions {
  static MethodChannel _platform;

  static Future _callHandler(MethodCall call) {
    switch (call.method) {
    }
    return null;
  }

  static Future<bool> saveToGallery(Future<Image> imageFuture) async {
    final imageBytes = await imageFuture
        .then((image) => image.toByteData(format: ImageByteFormat.png));

    _ensureInit();

    return _platform.invokeMethod('saveImageToGallery',
        {'imagePngData': imageBytes.buffer.asUint8List()});
  }

  static void _ensureInit() {
    if (_platform == null) {
      _platform = MethodChannel('slebe.dev/draw-a-lot');
      _platform.setMethodCallHandler(_callHandler);
    }
  }
}
