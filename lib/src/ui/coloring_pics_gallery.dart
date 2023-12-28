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
      "pictures/bird.svg",
      "pictures/cowboy.svg",
      "pictures/crab.svg",
      "pictures/crab2.svg",
      "pictures/deer.svg",
      "pictures/dino.svg",
      //"pictures/dino2.svg",
      "pictures/dinos.svg",
      "pictures/elephant.svg",
      "pictures/fish.svg",
      "pictures/giraffe.svg",
      "pictures/gold_fish.svg",
      "pictures/hares.svg",
      "pictures/lion.svg",
      "pictures/mermaid.svg",
      "pictures/monkey.svg",
      "pictures/mouse.svg",
      "pictures/penguin.svg",
      "pictures/penguin2.svg",
      "pictures/pig.svg",
      "pictures/rabbit.svg",
      "pictures/rabbit2.svg",
      "pictures/snowman.svg",
      "pictures/turtle.svg",
      "pictures/unicorn.svg",
      "pictures/unicorn2.svg",
      "pictures/unicorn3.svg",
      "pictures/unicorn4.svg",
      "pictures/winter_bear.svg",
    ];
  }
}
