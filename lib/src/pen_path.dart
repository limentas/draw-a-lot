import 'package:flutter/painting.dart';

class PenPath {
  PenPath({this.color, this.penWidth, this.pointerId, this.path});

  Color color;
  double penWidth;
  Path path = new Path();
  bool completed = false;
  bool cached = false;
  int pointerId = -1; //id of pointer (for multitouch recognition)
}
