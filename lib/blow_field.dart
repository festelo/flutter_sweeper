import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/blow_button.dart';
import 'package:minesweeper/number_button.dart';

import 'manager.dart';

class BlowField extends StatefulWidget {
  final int fieldWidth;
  final int fieldHeight;
  final void Function(int left, int all) onBombsCountUpdated;
  final void Function() onWin;
  final void Function() onLoose;

  BlowField({
    Key? key,
    this.fieldHeight = 10,
    this.fieldWidth = 10,
    required this.onBombsCountUpdated,
    required this.onWin,
    required this.onLoose,
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
  int flagsSet = 0;
  int bombsCount = 20;
  bool gameOver = false;

  FieldManager? field;

  void onTap(Location location) {
    if (field == null) initBombs(except: location);
    if (gameOver) return;
    final currentState = field!.getState(location);
    if (currentState.hasFlag(CellState.open)) return;
    var res = field!.open(location);
    if (!res) {
      widget.onLoose();
      gameOver = true;
    }
    setState(() {});
  }

  void onFlag(Location location) {
    if (field == null) initBombs(except: location);
    final currentState = field!.getState(location);
    if (currentState.hasFlag(CellState.open)) return;
    if (currentState.hasFlag(CellState.flag)) {
      setState(() {
        field!.unflag(location);
        flagsSet--;
      });
    } else {
      setState(() {
        field!.flag(location);
        flagsSet++;
      });
    }
    widget.onBombsCountUpdated(bombsCount - flagsSet, bombsCount);
    if (bombsCount == flagsSet) {
      final flagsCorrect = field!.checkFlags();
      if (flagsCorrect) {
        widget.onWin();
        setState(() {
          gameOver = true;
        });
      }
    }
  }

  void reset() {
    setState(() {
      field = null;
      gameOver = false;
    });
  }

  List<Location> generateBombs(int bombsCount, Set<Location> except) {
    final bombs = <Location>[];
    final random = Random();
    for (var i = 0; i < bombsCount; i++) {
      while (true) {
        var x = random.nextInt(widget.fieldWidth);
        var y = random.nextInt(widget.fieldHeight);
        final location = Location(x, y);
        if (bombs.contains(location) || except.contains(location)) continue;
        bombs.add(location);
        break;
      }
    }
    return bombs;
  }

  void initBombs({Location? except}) {
    Map<Location, CellState> fieldStates = {};
    final exceptSet = <Location>{};
    if (except != null) {
      for (var i = -1; i < 2; i++) {
        final x = except.x + i;
        for (var j = -1; j < 2; j++) {
          final y = except.y + j;
          exceptSet.add(Location(x, y));
        }
      }
    }
    final bombs = generateBombs(bombsCount, exceptSet);
    for (final b in bombs) {
      fieldStates[b] = CellState.bomb;
    }
    field = FieldManager(
      fieldStates,
      widget.fieldWidth,
      widget.fieldHeight,
    );
    widget.onBombsCountUpdated(bombsCount, bombsCount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 3,
        ),
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
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
                        final state =
                            field?.getState(location) ?? CellState.none;
                        if (state.hasFlag(CellState.open) &&
                            !state.hasFlag(CellState.bomb))
                          return NumberButton(
                              number: field!.getOpened(location));
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
      ),
    );
  }
}
