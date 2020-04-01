import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {  
  ToolButton({Key key, this.icon, this.onPressed, this.disabled: false}):
    super(key: key);

  final double _defaultButtonElevation = 4.0;
  final double _toggledButtonElevation = 0.0;

  final void Function() onPressed;
  final IconData icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
      child: Icon(icon, size: 40,),
      color: Colors.white,
      shape: CircleBorder(),
      elevation: _defaultButtonElevation,
      focusElevation: _defaultButtonElevation,
      hoverElevation: _defaultButtonElevation,
      highlightElevation: _toggledButtonElevation,
      onPressed: disabled ? null : onPressed,
    );
  }
}