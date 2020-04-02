import 'package:flutter/material.dart';

Future<double> showThicknessDialog(
    BuildContext context, double x, double y) async {
  return showGeneralDialog<double>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Color.fromARGB(0, 1, 1, 1),
      transitionDuration: Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) {
        return new Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.only(left: x, top: y),
                child: Row(children: <Widget>[
                  ThicknessButton(1),
                  ThicknessButton(2),
                  ThicknessButton(4),
                  ThicknessButton(6),
                  ThicknessButton(8),
                  ThicknessButton(12),
                  ThicknessButton(16),
                  ThicknessButton(20),
                  ThicknessButton(24),
                  ThicknessButton(28),
                  ThicknessButton(36),
                  ThicknessButton(48),
                ])));
      });
}

class ThicknessButton extends StatelessWidget {
  ThicknessButton(this.thickness);

  final double thickness;

  final double _defaultElevation = 1;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        height: 80,
        child: RaisedButton(
            color: Colors.white,
            elevation: _defaultElevation,
            focusElevation: _defaultElevation,
            hoverElevation: _defaultElevation * 3,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            onPressed: () {
              Navigator.of(context).pop(thickness);
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                decoration: ShapeDecoration(
                    shape: CircleBorder(
                        side: BorderSide(
                            color: Colors.blueGrey[900], width: thickness / 2))),
              ),
              SizedBox(height: 5),
              Text("$thickness")
            ])));
  }
}
