import 'dart:async';
import 'dart:ui';

import 'package:draw_a_lot/src/system_info.dart';
import 'package:flutter/services.dart';

class OsFunctions {
  static MethodChannel? _platform = null;

  static Future<bool> saveToGallery(Future<Image> imageFuture) async {
    final image = await imageFuture;
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    if (pngBytes == null) {
      throw Exception("Couldn't convert image to png");
    }

    _ensureInit();

    return await _platform!.invokeMethod('saveImageToGallery', {
      'imagePngData': pngBytes.buffer.asUint8List(),
    }) as bool;
  }

  static Future<SystemInfo> getSystemInfo() async {
    _ensureInit();

    final result = new SystemInfo();
    final resultMap = await _platform!.invokeMethod('getSystemInfo');
    final abisDynamic = resultMap['SUPPORTED_ABIS'];
    if (abisDynamic != null) {
      result.supportedABIs = abisDynamic as String;
      final abis = result.supportedABIs.split(',');
      //If the most preferred ABI is x86 then flag this
      if (abis.length > 0 && abis[0].toLowerCase() == 'x86') {
        result.isX86_32 = true;
      }
    }

    final timeDynamic = resultMap['TIME'];
    if (timeDynamic != null) {
      final buildTimestamp = int.tryParse(timeDynamic as String);
      if (buildTimestamp != null) {
        result.buildTime = DateTime.fromMillisecondsSinceEpoch(buildTimestamp);
      }
    }

    final tagsDynamic = resultMap['TAGS'];
    if (tagsDynamic != null) result.tags = tagsDynamic as String;
    final hardwareDynamic = resultMap['HARDWARE'];
    if (hardwareDynamic != null) result.hardware = hardwareDynamic as String;
    final deviceDynamic = resultMap['DEVICE'];
    if (deviceDynamic != null) result.device = deviceDynamic as String;
    final brandDynamic = resultMap['BRAND'];
    if (brandDynamic != null) result.brand = brandDynamic as String;
    return result;
  }

  static void _ensureInit() {
    if (_platform == null) {
      _platform = MethodChannel('slebe.dev/draw-a-lot');
    }
  }
}
