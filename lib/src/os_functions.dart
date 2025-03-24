import 'dart:async';
import 'dart:ui';

import 'package:draw_a_lot/src/system_info.dart';
import 'package:flutter/services.dart';

class OsFunctions {
  static MethodChannel? _platform = null;

  static Future<bool> saveToGallery(Future<Image> imageFuture) async {
    final imageBytes = await imageFuture.then(
      (image) => image.toByteData(format: ImageByteFormat.png),
    );

    if (imageBytes == null) {
      throw Exception("Couldn't convert image to png");
    }

    _ensureInit();

    return _platform!.invokeMethod('saveImageToGallery', {
          'imagePngData': imageBytes.buffer.asUint8List(),
        })
        as bool;
  }

  static Future<SystemInfo> getSystemInfo() async {
    _ensureInit();

    final result = new SystemInfo();
    final resultMap = await _platform!.invokeMethod('getSystemInfo');
    result.supportedABIs = resultMap['SUPPORTED_ABIS'] as String;
    final abis = result.supportedABIs.split(',');
    //If the most preferred ABI is x86 then flag this
    if (abis.length > 0 && abis[0].toLowerCase() == 'x86') {
      result.isX86_32 = true;
    }

    final buildTimestamp = int.tryParse((resultMap['TIME'] as String));
    if (buildTimestamp != null) {
      result.buildTime = DateTime.fromMillisecondsSinceEpoch(buildTimestamp);
    }

    result.tags = resultMap['TAGS'] as String;
    result.hardware = resultMap['HARDWARE'] as String;
    result.device = resultMap['DEVICE'] as String;
    result.brand = resultMap['BRAND'] as String;
    return result;
  }

  static void _ensureInit() {
    if (_platform == null) {
      _platform = MethodChannel('slebe.dev/draw-a-lot');
    }
  }
}
