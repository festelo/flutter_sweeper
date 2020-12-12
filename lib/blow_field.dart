import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/blow_button.dart';
import 'package:minesweeper/number_button.dart';

import 'manager.dart';

class BlowField extends StatefulWidget {
  final int fieldWidth;
  final int fieldHeight;

  BlowField({
    Key? key,
    this.fieldHeight = 10,
    this.fieldWidth = 10,
  }) : super(key: key);

  static BlowFieldState of(BuildContext context, {bool nullOk = false}) {
    final result = context.findAncestorStateOfType<BlowFieldState>();
    if (result != null) return result;
    throw Exception('Not found');
  }

  @override
  BlowFieldState createState() => BlowFieldState();
}

class BlowFieldState extends State<BlowField> {
  int get rows => widget.fieldWidth;
  int get columns => widget.fieldHeight;

  FieldManager? field;

  void onTap(Location location) {
    if (field == null) initBombs(except: location);
    final currentState = field!.getState(location);
    if (currentState.hasFlag(CellState.open)) return;
    setState(() {
      field!.open(location);
    });
  }

  void onFlag(Location location) {
    if (field == null) initBombs(except: location);
    final currentState = field!.getState(location);
    if (currentState.hasFlag(CellState.open)) return;
    if (currentState.hasFlag(CellState.flag)) {
      setState(() {
        field!.unflag(location);
      });
    } else {
      setState(() {
        field!.flag(location);
      });
    }
  }

  void reset() {
    setState(() => field = null);
  }

  List<Location> generateBombs() {
    final bombs = <Location>[];
    final random = Random();
    for (var i = 0; i < widget.fieldHeight; i++) {
      for (var j = 0; j < widget.fieldWidth; j++) {
        if (random.nextInt(100) < 30) bombs.add(Location(j, i));
      }
    }
    return bombs;
  }

  void initBombs({Location? except}) {
    Map<Location, CellState> fieldStates = {};
    final bombs = generateBombs();
    if (except != null) {
      for (var i = -1; i < 2; i++) {
        final x = except.x + i;
        for (var j = -1; j < 2; j++) {
          final y = except.y + j;
          bombs.remove(Location(x, y));
        }
      }
    }
    for (final b in bombs) {
      fieldStates[b] = CellState.bomb;
    }
    field = FieldManager(
      fieldStates,
      widget.fieldWidth,
      widget.fieldHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < columns; i++)
            Row(
              children: [
                for (var j = 0; j < rows; j++)
                  Expanded(
                    child: () {
                      final location = Location(i, j);
                      final state = field?.getState(location) ?? CellState.none;
                      if (state.hasFlag(CellState.open) &&
                          !state.hasFlag(CellState.bomb))
                        return NumberButton(number: field!.getOpened(location));
                      return BlowButton(
                        state: state,
                        onTap: () => onTap(location),
                        onFlag: () => onFlag(location),
                      );
                    }(),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
