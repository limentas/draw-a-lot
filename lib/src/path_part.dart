import 'package:flutter/painting.dart';

class PathPart {
  PathPart({this.color, this.penWidth, this.path});

  Color color;
  double penWidth;
  Path path = new Path();
}