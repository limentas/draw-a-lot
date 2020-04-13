import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

Drawer createDrawer() {
  return Drawer(
    semanticLabel: "Menu",
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
          title: Text('Empty canvas'),
        ),
        ListTile(
          leading: Icon(Icons.image),
          title: Text('Coloring mode'),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),
        Spacer(),
        ListTile(title: RichText(
            text: TextSpan(
                  text: 'Privacy policy',
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () { launch('https://slebe.dev/draw-a-lot/mobile_app_privacy_policy.html');
                  },
                ),))
      ],
    ),
  );
}
