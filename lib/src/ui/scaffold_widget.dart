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
      resizeToAvoidBottomInset: false,
      //drawerEdgeDragWidth: 0,
      body: MainView(key: _mainWidgetKey),
      drawerEnableOpenDragGesture: false,
      drawer: kIsWeb
          ? null
          : createDrawer(
              context,
              onSaveToGallery: () =>
                  _mainWidgetKey.currentState?.saveToGallery(),
              onBlankCanvasChoosen: () {
                _mainWidgetKey.currentState?.paintWidgetKey.currentState
                    ?.setImageForColoring("");
              },
              onColoringPicChoosen: () async {
                var imagePath = await showGeneralDialog<String>(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: "",
                  transitionDuration: Duration(milliseconds: 100),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return ColoringPicsGallery();
                  },
                );
                if (imagePath != null) {
                  _mainWidgetKey.currentState?.paintWidgetKey.currentState
                      ?.setImageForColoring(imagePath);
                }
              },
            ),
    );
  }
}
