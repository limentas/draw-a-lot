import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_view.dart';
import 'scaffold_widget.dart';

// This widget is the root of the application.
class AppWidget extends StatelessWidget {
  final _mainWidgetKey = GlobalKey<MainViewState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide status and bottom bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // This callback is called whenever status or navigation bar appears.
    // We hide it back in callback body.
    SystemChrome.setSystemUIChangeCallback((bool systemOverlaysAreVisible) {
      //SystemChrome.restoreSystemUIOverlays();
      return Future.value();
    });
    var style = SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.grey,
        systemNavigationBarContrastEnforced: false);
    SystemChrome.setSystemUIOverlayStyle(style);
    return MaterialApp(
      title: 'DrawA̲lot',
      theme: ThemeData(
          primarySwatch: Colors.blue, buttonTheme: ButtonThemeData(height: 60)),
      home: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          print("Back button clicked");
          _mainWidgetKey.currentState?.undo();
        },
        child: ScaffoldWidget(_mainWidgetKey),
      ),
    );
  }
}
