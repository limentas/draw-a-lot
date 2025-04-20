import 'package:draw_a_lot/src/app_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:url_launcher/url_launcher.dart';

Drawer createDrawer(
  BuildContext context, {
  required void Function() onSaveToGallery,
  required void Function() onBlankCanvasChoosen,
  required void Function() onColoringPicChoosen,
}) {
  return Drawer(
    semanticLabel: "Menu",
    width: 350,
    child: Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: 80,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DrawA̲lot',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )),
                ),
              ),
              ListTile(
                leading: SvgPicture.asset('icons/pencil.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.blue.shade900, BlendMode.srcIn),
                    width: 36),
                title: Text('New blank canvas', style: TextStyle(fontSize: 25)),
                minVerticalPadding: 20,
                onTap: () {
                  Navigator.pop(context);
                  onBlankCanvasChoosen();
                },
              ),
              AppConfig.isX86_32
                  ? ListTile() //disable coloring mode
                  : ListTile(
                      leading: SvgPicture.asset('icons/flower.svg',
                          colorFilter: ColorFilter.mode(
                              Colors.green.shade800, BlendMode.srcIn),
                          width: 36),
                      title: Text(
                        'Coloring mode',
                        style: TextStyle(fontSize: 25),
                      ),
                      minVerticalPadding: 20,
                      onTap: () {
                        Navigator.pop(context);
                        onColoringPicChoosen();
                      },
                    ),
              ListTile(), //spacer
              ListTile(
                leading:
                    Icon(Icons.favorite_outline, color: Colors.red, size: 36),
                title: Text(
                  'Save to the gallery',
                  style: TextStyle(fontSize: 25),
                ),
                minVerticalPadding: 20,
                onTap: () {
                  Navigator.pop(context);
                  onSaveToGallery();
                },
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Privacy policy (opens in browser) ',
                style: TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pop(context);
                    launch(
                      'https://slebe.dev/draw-a-lot/mobile_app_privacy_policy.html',
                    );
                  },
              ),
              WidgetSpan(child: Icon(Icons.launch, size: 14)),
            ],
          ),
        ),
        SizedBox(height: 30),
      ],
    ),
  );
}
