import 'package:flutter/material.dart';

import 'coloring_pic_preview.dart';

class ColoringPicsGallery extends StatelessWidget {
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                child: Scrollbar(
                    controller: _scrollController,
                    isAlwaysShown: true,
                    child: GridView.count(
                        controller: _scrollController,
                        crossAxisCount: 3,
                        padding: EdgeInsets.all(20),
                        children: listPicturesFilePathes().map<Widget>((path) {
                          return ColoringPicPreview(
                            path: path,
                            onClicked: (chosedPath) {
                              Navigator.of(context).pop(chosedPath);
                            },
                          );
                        }).toList()))),
            SizedBox(height: 20),
            OutlineButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text("Cancel", style: TextStyle(fontSize: 24))),
            SizedBox(height: 20)
          ],
        ));
  }

  List<String> listPicturesFilePathes() {
    return [
      "pictures/cowboy.svg",
      "pictures/crab.svg",
      "pictures/dinos.svg",
      "pictures/rabbit.svg",
      "pictures/monkey.svg",
      "pictures/elephant.svg",
      "pictures/giraffe.svg",
      "pictures/mouse.svg"
    ];
  }
}
