import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'main_view.dart';
import 'app_drawer.dart';
import 'coloring_pics_gallery.dart';

//ignore: must_be_immutable
class ScaffoldWidget extends StatelessWidget {
  MainView? _mainView = null;

  void undo() {
    _mainView?.undo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: false,
      body: _mainView = MainView(),
      drawerEnableOpenDragGesture: false,
      drawer: kIsWeb
          ? null
          : createDrawer(
              context,
              onSaveToGallery: () => _mainView?.saveToGallery(context),
              onBlankCanvasChoosen: () => _mainView?.newBlankCanvas(),
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
                  _mainView?.setImageForColoring(imagePath);
                }
              },
            ),
    );
  }
}
