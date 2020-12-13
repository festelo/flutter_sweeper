import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'manager.dart';

class BlowButton extends StatelessWidget {
  final CellState state;
  final VoidCallback onTap;
  final VoidCallback onFlag;

  const BlowButton({
    Key? key,
    required this.state,
    required this.onTap,
    required this.onFlag,
  }) : super(key: key);

  static final fillColor = <CellState, Color>{
    CellState.none: Colors.transparent,
    CellState.bomb: Colors.red,
    CellState.flag: Colors.transparent,
  };

  static final fontColor = <CellState, Color>{
    CellState.none: Colors.black54,
    CellState.bomb: Colors.grey.shade200,
    CellState.flag: Colors.black54,
  };

  Color getFillColor() {
    if (state.hasFlag(CellState.bomb) && state.hasFlag(CellState.open))
      return fillColor[CellState.bomb]!;
    if (state.hasFlag(CellState.flag)) return fillColor[CellState.flag]!;
    return fillColor[CellState.none]!;
  }

  Color getFontColor() {
    if (state.hasFlag(CellState.bomb) && state.hasFlag(CellState.open))
      return fontColor[CellState.bomb]!;
    if (state.hasFlag(CellState.flag)) return fontColor[CellState.flag]!;
    return fontColor[CellState.none]!;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 1,
          ),
          color: getFillColor(),
        ),
        child: InkWell(
          child: Center(
            child: FaIcon(
              () {
                if (state.hasFlag(CellState.bomb) &&
                    state.hasFlag(CellState.open)) return FontAwesomeIcons.bomb;
                if (state.hasFlag(CellState.flag)) return Icons.flag_outlined;
                return FontAwesomeIcons.question;
              }(),
              size: 16,
              color: getFontColor(),
            ),
          ),
          onLongPress: onFlag,
          onTap: onTap,
        ),
      ),
    );
  }
}
