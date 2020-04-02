import 'dart:math';

import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  ToolButton(
      {Key key,
      this.imageIcon,
      this.iconData,
      this.color,
      this.onPressed,
      this.disabled: false})
      : super(key: key);

  final double _defaultButtonElevation = 4.0;
  final double _toggledButtonElevation = 0.0;

  final void Function() onPressed;
  final ImageProvider<dynamic> imageIcon;
  final IconData iconData;
  final Color color;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = min(80, MediaQuery.of(context).size.height / 5 - 12);
    return new ButtonTheme(
        height: buttonHeight,
        minWidth: 40,
        child: RaisedButton(
          materialTapTargetSize: buttonHeight < 48 ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
          child: imageIcon != null
              ? ImageIcon(
                  imageIcon,
                  size: 32,
                  color: color,
                )
              : Icon(
                  iconData,
                  size: 40,
                  color: color,
                ),
          color: Colors.white,
          shape: CircleBorder(),
          elevation: _defaultButtonElevation,
          focusElevation: _defaultButtonElevation,
          hoverElevation: _defaultButtonElevation,
          highlightElevation: _toggledButtonElevation,
          onPressed: disabled ? null : onPressed,
        ));
  }
}
