import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'main_view.dart';
import 'app_drawer.dart';
import 'coloring_pics_gallery.dart';

class ScaffoldWidget extends StatelessWidget {
  ScaffoldWidget(GlobalKey<MainViewState> mainWidgetKey)
      : _mainWidgetKey = mainWidgetKey;

  final GlobalKey<MainViewState> _mainWidgetKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        resizeToAvoidBottomPadding: false,
        //drawerEdgeDragWidth: 0,
        body: MainView(key: _mainWidgetKey, title: 'DrawA̲lot'),
        drawer: kIsWeb || true
            ? null
            : createDrawer(context, onBlankCanvasChoosen: () {
                _mainWidgetKey.currentState.paintWidgetKey.currentState
                    .setImageForColoring(null);
              }, onColoringPicChoosen: () {
                showGeneralDialog<String>(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "",
                    transitionDuration: Duration(milliseconds: 100),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return ColoringPicsGallery();
                    }).then((path) {
                  if (path != null) {
                    _mainWidgetKey.currentState.paintWidgetKey.currentState
                        .setImageForColoring(path);
                    Navigator.of(context).pop();
                  }
                });
              }));
  }
}
