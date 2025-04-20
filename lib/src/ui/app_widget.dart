import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_view.dart';
import 'scaffold_widget.dart';

class AppWidget extends StatelessWidget {
  final _mainWidgetKey = GlobalKey<MainViewState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide status and bottom bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return MaterialApp(
      title: 'DrawA̲lot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(height: 60),
      ),
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
