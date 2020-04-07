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

  int red;
  int green;
  int blue;
  int alpha;

  //https://www.compuphase.com/cmetric.htm (see "A low-cost approximation")
  double difference(Color other) {
    final rmean = ((red + other.red) ~/ 2);
    final dr = red - other.red;
    final dg = green - other.green;
    final db = blue - other.blue;
    return sqrt((((512 + rmean) * dr * dr) >>
        8) + 4 * dg * dg + (((767 - rmean) * db * db) >>
        8));
  }

  @override
  bool operator ==(dynamic other) {
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
