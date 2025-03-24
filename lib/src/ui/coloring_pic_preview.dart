import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ColoringPicPreview extends StatelessWidget {
  ColoringPicPreview({required this.path, required this.onClicked});

  final String path;
  final void Function(String) onClicked;

  final _busyIndicator = SpinKitFadingCircle(color: Colors.grey[800]);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onClicked(path);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            //border: Border.all(color: Colors.grey[900], width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[400]!,
                offset: Offset(5.0, 5.0),
                blurRadius: 5.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: SvgPicture.asset(
            path,
            placeholderBuilder: (context) {
              return _busyIndicator;
            },
          ),
        ),
      ),
    );
  }
}
