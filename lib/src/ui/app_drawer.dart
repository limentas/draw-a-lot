import 'package:draw_a_lot/src/app_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

Drawer createDrawer(BuildContext context,
    {void Function() onSaveToGallery,
    void Function() onBlankCanvasChoosen,
    void Function() onColoringPicChoosen}) {
  return Drawer(
      semanticLabel: "Menu",
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                  height: 80,
                  child: DrawerHeader(
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
                  )),
              ListTile(
                leading: Icon(Icons.brush),
                title: Text('New blank canvas',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onTap: () {
                  Navigator.pop(context);
                  onBlankCanvasChoosen();
                },
              ),
              AppConfig.isX86_32
                  ? ListTile() //disable coloring mode
                  : ListTile(
                      leading: Icon(Icons.image),
                      title: Text('Coloring mode',
                          style: TextStyle(
                            fontSize: 18,
                          )),
                      onTap: () {
                        Navigator.pop(context);
                        onColoringPicChoosen();
                      },
                    ),
              ListTile(), //spacer
              ListTile(
                leading: Icon(Icons.save),
                title: Text('Save to the gallery',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onTap: () {
                  Navigator.pop(context);
                  onSaveToGallery();
                },
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
          SizedBox(height: 20)
        ],
      ));
}
