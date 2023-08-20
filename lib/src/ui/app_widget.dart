import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_view.dart';
import 'scaffold_widget.dart';

class AppWidget extends StatelessWidget {
  final _mainWidgetKey = GlobalKey<MainViewState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return MaterialApp(
        title: 'DrawA̲lot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            buttonColor: Colors.grey[800],
            buttonTheme: ButtonThemeData(height: 60)),
        home: WillPopScope(
            onWillPop: () {
              print("Back button clicked");
              _mainWidgetKey.currentState.undo();
              return new Future(() => false);
            },
            child: ScaffoldWidget(_mainWidgetKey)));
  }
}
