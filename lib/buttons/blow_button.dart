import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import '../services/field_manager.dart';

class BlowButton extends StatefulWidget {
  final CellState state;
  final VoidCallback onTap;
  final VoidCallback onFlag;

  const BlowButton({
    Key? key,
    required this.state,
    required this.onTap,
    required this.onFlag,
  }) : super(key: key);

  static get fillColor => <CellState, Color>{
        CellState.none: Colors.white,
        CellState.bomb: Colors.red,
        CellState.flag: Colors.grey.shade200,
      };

  static get fontColor => <CellState, Color>{
        CellState.none: Colors.black54,
        CellState.bomb: Colors.grey.shade200,
        CellState.flag: Colors.black,
      };

  @override
  _BlowButtonState createState() => _BlowButtonState();
}

class _BlowButtonState extends State<BlowButton> {
  Timer? longPressTimer;
  static const longPressDuration = Duration(milliseconds: 200);

  Color getFillColor() {
    if (widget.state.hasFlag(CellState.bomb) &&
        widget.state.hasFlag(CellState.open))
      return BlowButton.fillColor[CellState.bomb]!;
    if (widget.state.hasFlag(CellState.flag))
      return BlowButton.fillColor[CellState.flag]!;
    return BlowButton.fillColor[CellState.none]!;
  }

  Color getFontColor() {
    if (widget.state.hasFlag(CellState.bomb) &&
        widget.state.hasFlag(CellState.open))
      return BlowButton.fontColor[CellState.bomb]!;
    if (widget.state.hasFlag(CellState.flag))
      return BlowButton.fontColor[CellState.flag]!;
    return BlowButton.fontColor[CellState.none]!;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: getFillColor(),
        ),
        margin: EdgeInsets.all(1),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: FaIcon(
                () {
                  if (widget.state.hasFlag(CellState.bomb) &&
                      widget.state.hasFlag(CellState.open))
                    return FontAwesomeIcons.bomb;
                  if (widget.state.hasFlag(CellState.flag))
                    return Icons.flag_outlined;
                  return FontAwesomeIcons.question;
                }(),
                size: widget.state.hasFlag(CellState.flag) ? 22 : 18,
                color: getFontColor(),
              ),
            ),
          ),
          onSecondaryTap: widget.onFlag,
          onTapDown: (_) {
            longPressTimer?.cancel();
            longPressTimer = Timer(longPressDuration, () async {
              try {
                final v = await Vibration.hasVibrator();
                if (v ?? false) {
                  Vibration.vibrate(duration: 50, amplitude: 1);
                }
              } catch (_) {}
              widget.onFlag();
            });
          },
          onTapCancel: () {
            longPressTimer?.cancel();
          },
          onTapUp: (_) {
            final wasActive = longPressTimer?.isActive ?? false;
            longPressTimer?.cancel();
            if (wasActive) {
              widget.onTap();
            }
          },
        ),
      ),
    );
  }
}
