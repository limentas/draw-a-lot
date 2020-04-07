import 'dart:math';

import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  ToolButton(
      {Key key,
      this.imageIcon,
      this.iconData,
      this.color,
      this.onPressed,
      this.disabled: false,
      this.toggled: false})
      : super(key: key);

  final double _defaultButtonElevation = 4.0;
  final double _toggledButtonElevation = 0.0;

  final void Function() onPressed;
  final ImageProvider<dynamic> imageIcon;
  final IconData iconData;
  final Color color;
  final bool disabled;
  final bool toggled;

  @override
  Widget build(BuildContext context) {
    final buttonSize =
        min(max(40.0, MediaQuery.of(context).size.height / 9 - 4), 80.0);
    return new ButtonTheme(
        height: buttonSize,
        minWidth: buttonSize,
        child: RaisedButton(
          materialTapTargetSize: buttonSize < 48
              ? MaterialTapTargetSize.shrinkWrap
              : MaterialTapTargetSize.padded,
          child: imageIcon != null
              ? ImageIcon(
                  imageIcon,
                  size: buttonSize * 0.55,
                  color: color,
                )
              : Icon(
                  iconData,
                  size: buttonSize * 0.6,
                  color: color,
                ),
          color: toggled ? Colors.yellowAccent[100] : Colors.white,
          highlightColor: Colors.yellowAccent[100],
          shape: CircleBorder(),
          elevation:
              toggled ? _toggledButtonElevation : _defaultButtonElevation,
          focusElevation:
              toggled ? _toggledButtonElevation : _defaultButtonElevation,
          hoverElevation:
              toggled ? _toggledButtonElevation : _defaultButtonElevation,
          highlightElevation: _toggledButtonElevation,
          onPressed: disabled ? null : onPressed,
        ));
  }
}
