import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ColoringPicPreview extends StatelessWidget {
  ColoringPicPreview({@required this.path, this.onClicked});

  final String path;
  final void Function(String) onClicked;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              onClicked(path);
            },
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueGrey[900], width: 1),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blueGrey[600], offset: Offset(5.0, 5.0))
                    ]),
                child: SvgPicture.asset(path, placeholderBuilder: (context) {
                  return Icon(Icons.image, size: 128, color: Colors.black);
                }))));
  }
}
