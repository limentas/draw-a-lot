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
    final buttonSize = min(max(40.0, MediaQuery.of(context).size.height / 8 - 4), 80.0);
    return new ButtonTheme(
        height: buttonSize,
        minWidth: buttonSize,
        child: RaisedButton(
          materialTapTargetSize: buttonSize < 48 ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
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
