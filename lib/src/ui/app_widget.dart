import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_view.dart';

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
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          buttonColor: Colors.grey[800],
          buttonTheme: ButtonThemeData(height: 60)),
      home: WillPopScope(
        onWillPop: () {
          print("Back button clicked");
          _mainWidgetKey.currentState.undo();
          return new Future(() => false);
        },
        child: Scaffold(
            extendBodyBehindAppBar: false,
            resizeToAvoidBottomPadding: false,
            body: MainView(title: 'DrawA̲lot'),
        )
    ));
  }
}
