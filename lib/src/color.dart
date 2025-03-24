import 'dart:ui' as dart_ui;
import 'dart:math';

//Yet another Color, because dart:ui color is very ugly
class Color {
  Color();
  Color.fromColor(dart_ui.Color color)
    : red = color.red,
      green = color.green,
      blue = color.blue,
      alpha = color.alpha;

  Color.fromRgba(this.red, this.green, this.blue, this.alpha);
  Color.fromRgbaInt(int rgba) {
    red = rgba & 0xFF;
    green = (rgba & 0xFF00) >> 8;
    blue = (rgba & 0xFF0000) >> 16;
    alpha = (rgba & 0xFF000000) >> 24;
  }

  int red = 0;
  int green = 0;
  int blue = 0;
  int alpha = 0;

  //https://www.compuphase.com/cmetric.htm (see "A low-cost approximation")
  double difference(Color other) {
    final rmean = ((red + other.red) ~/ 2);
    final dr = red - other.red;
    final dg = green - other.green;
    final db = blue - other.blue;
    return sqrt(
      (((512 + rmean) * dr * dr) >> 8) +
          4 * dg * dg +
          (((767 - rmean) * db * db) >> 8),
    );
  }

  //red is less significant byte
  int toRgbaInt() {
    return (red & 0xFF) |
        ((green & 0xFF) << 8) |
        ((blue & 0xFF) << 16) |
        ((alpha & 0xFF) << 24);
  }

  @override
  String toString() {
    return "($red, $green, $blue, $alpha)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Color &&
        red == other.red &&
        green == other.green &&
        blue == other.blue &&
        alpha == other.alpha;
  }

  @override
  int get hashCode =>
      red.hashCode << 24 |
      green.hashCode << 16 |
      blue.hashCode << 8 |
      alpha.hashCode;
}
