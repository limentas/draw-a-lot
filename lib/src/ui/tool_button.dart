import 'dart:math';

import 'package:flutter/material.dart';

class ToolButton extends StatefulWidget {
  ToolButton(
      {Key key,
      this.imageIcon,
      this.iconData,
      this.color,
      this.onPressed,
      this.disabled: false,
      this.startToggled: false})
      : super(key: key);

  final void Function() onPressed;
  final ImageProvider<dynamic> imageIcon;
  final IconData iconData;
  final Color color;
  final bool disabled;
  final bool startToggled;

  void toggle(bool toggled) {}

  @override
  ToolButtonState createState() => ToolButtonState(startToggled);
}

class ToolButtonState extends State<ToolButton> {
  ToolButtonState(this._toggled);

  final double _defaultButtonElevation = 4.0;
  final double _toggledButtonElevation = 0.0;

  bool _toggled;

  void setToggled(bool toggled) {
    setState(() {
      _toggled = toggled;
    });
  }

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
            child: widget.imageIcon != null
                ? ImageIcon(
                    widget.imageIcon,
                    size: buttonSize * 0.55,
                    color: widget.color,
                  )
                : Icon(
                    widget.iconData,
                    size: buttonSize * 0.6,
                    color: widget.color,
                  ),
            color: _toggled ? Colors.yellowAccent[100] : Colors.white,
            highlightColor: Colors.yellowAccent[100],
            shape: CircleBorder(),
            elevation:
                _toggled ? _toggledButtonElevation : _defaultButtonElevation,
            focusElevation:
                _toggled ? _toggledButtonElevation : _defaultButtonElevation,
            hoverElevation:
                _toggled ? _toggledButtonElevation : _defaultButtonElevation,
            highlightElevation: _toggledButtonElevation,
            onPressed: widget.disabled ? null : widget.onPressed));
  }
}
