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
              trackVisibility: true,
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
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: Text("Cancel", style: TextStyle(fontSize: 24)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  List<String> listPicturesFilePathes() {
    return [
      "pictures/bear.svg",
      "pictures/bird.svg",
      "pictures/bulldozer.svg",
      "pictures/cat.svg",
      "pictures/cat_and_dog.svg",
      "pictures/cow.svg",
      "pictures/cowboy.svg",
      "pictures/crab.svg",
      "pictures/crab2.svg",
      "pictures/deer.svg",
      "pictures/dino.svg",
      "pictures/dinos.svg",
      "pictures/dog.svg",
      "pictures/dragon.svg",
      "pictures/dragon2.svg",
      "pictures/elephant.svg",
      //"pictures/firefighters.svg",
      "pictures/fish.svg",
      "pictures/food.svg",
      "pictures/fruits.svg",
      "pictures/giraffe.svg",
      "pictures/gold_fish.svg",
      "pictures/hares.svg",
      "pictures/ice_cream.svg",
      "pictures/lion.svg",
      "pictures/lion2.svg",
      "pictures/lion3.svg",
      "pictures/lorry.svg",
      "pictures/mermaid.svg",
      "pictures/monkey.svg",
      "pictures/mouse.svg",
      "pictures/mouse2.svg",
      "pictures/mouse3.svg",
      "pictures/penguin.svg",
      "pictures/penguin2.svg",
      "pictures/pig.svg",
      "pictures/planets.svg",
      "pictures/rabbit.svg",
      "pictures/rabbit2.svg",
      "pictures/snake.svg",
      "pictures/snowman.svg",
      "pictures/tractor.svg",
      "pictures/tractor2.svg",
      "pictures/trolleybus.svg",
      "pictures/turtle.svg",
      "pictures/unicorn.svg",
      "pictures/unicorn2.svg",
      "pictures/unicorn3.svg",
      "pictures/unicorn4.svg",
      "pictures/winter_bear.svg",
    ];
  }
}
