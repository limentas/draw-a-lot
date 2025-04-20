import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToolButton extends StatefulWidget {
  ToolButton({
    Key? key,
    this.svgAssetName,
    this.iconData,
    required this.color,
    required this.onPressed,
    this.disabled = false,
    this.startToggled = false,
  }) : super(key: key);

  final void Function() onPressed;
  final String? svgAssetName;
  final IconData? iconData;
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
    final buttonSize = min(
      max(46.0, MediaQuery.of(context).size.height / 9 - 4),
      80.0,
    );
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
              fixedSize: Size.square(buttonSize),
              backgroundColor:
                  _toggled ? Colors.yellowAccent[100] : Colors.white,
              overlayColor: Colors.yellowAccent[100],
              shape: CircleBorder(),
              padding: const EdgeInsets.all(0),
              tapTargetSize: buttonSize < 48
                  ? MaterialTapTargetSize.shrinkWrap
                  : MaterialTapTargetSize.padded)
          .copyWith(
        elevation: WidgetStateProperty.fromMap(<WidgetStatesConstraint, double>{
          WidgetState.any: _defaultButtonElevation,
          WidgetState.pressed | WidgetState.selected: _toggledButtonElevation,
        }),
      ),
      child: widget.svgAssetName != null
          ? SvgPicture.asset(widget.svgAssetName!,
              width: buttonSize * 0.55,
              colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn))
          : Icon(
              widget.iconData,
              size: buttonSize * 0.6,
              color: widget.color,
            ),
      onPressed: widget.disabled ? null : widget.onPressed,
    );
  }
}
