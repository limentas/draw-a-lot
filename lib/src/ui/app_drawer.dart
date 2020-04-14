import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

Drawer createDrawer(BuildContext context,
    {void Function() onBlankCanvasChoosen,
    void Function() onColoringPicChoosen}) {
  return Drawer(
      semanticLabel: "Menu",
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'DrawA̲lot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.brush),
                title: Text('Blank canvas'),
                onTap: onBlankCanvasChoosen,
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Coloring mode'),
                onTap: onColoringPicChoosen
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ],
          )),
          RichText(
              text: TextSpan(children: [
            TextSpan(
              text: 'Privacy policy (opens in browser) ',
              style: TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pop(context);
                  launch(
                      'https://slebe.dev/draw-a-lot/mobile_app_privacy_policy.html');
                },
            ),
            WidgetSpan(
              child: Icon(Icons.launch, size: 14),
            ),
          ])),
          SizedBox(height: 30)
        ],
      ));
}
