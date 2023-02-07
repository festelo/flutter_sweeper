import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/buttons/blow_button.dart';
import 'package:minesweeper/buttons/number_button.dart';

import 'services/field_manager.dart';

class BlowField extends StatefulWidget {
  final int fieldWidth;
  final int fieldHeight;
  final int bombsCount;

  final void Function(int bombsCount)? onStart;
  final void Function(int left, int all) onBombsCountUpdated;
  final void Function() onWin;
  final void Function() onLoose;
  final EdgeInsets margin;

  BlowField({
    Key? key,
    this.fieldHeight = 10,
    this.fieldWidth = 10,
    required this.onBombsCountUpdated,
    required this.onWin,
    required this.onLoose,
    required this.bombsCount,
    this.margin = const EdgeInsets.all(20),
    this.onStart,
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
  late int rows;
  late int columns;
  late int bombsCount;
  bool gameOver = false;

  FieldManager? field;

  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    setState(() {
      field = null;
      gameOver = false;
      rows = widget.fieldWidth;
      columns = widget.fieldHeight;
      bombsCount = widget.bombsCount;
    });
  }

  void checkFlags() {
    if (bombsCount == field!.flagsCount) {
      final flagsCorrect = field!.checkFlags();
      if (flagsCorrect) {
        widget.onWin();
        setState(() {
          gameOver = true;
        });
      }
    }
  }

  void onOpen(Location location) {
    if (field == null) initBombs(except: location);
    if (gameOver) return;
    final currentState = field!.getState(location);
    if (currentState.hasFlag(CellState.open)) return;
    if (currentState.hasFlag(CellState.flag)) return;
    var res = field!.open(location);
    if (!res) {
      widget.onLoose();
      gameOver = true;
    }
    setState(() {});
    checkFlags();
  }

  void onFlag(Location location) {
    if (field == null) initBombs(except: location);
    if (gameOver) return;
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
    widget.onBombsCountUpdated(bombsCount - field!.flagsCount, bombsCount);
    checkFlags();
  }

  void onNumberTap(Location location) {
    if (gameOver) return;
    final currentState = field!.getState(location);
    if (!currentState.hasFlag(CellState.open)) return;
    final number = field!.getOpened(location);
    if (number == 0) return;
    var flagsCounter = 0;
    for (var i = -1; i < 2; i++) {
      final x = location.x + i;
      for (var j = -1; j < 2; j++) {
        final y = location.y + j;
        final state = field!.getState(Location(x, y));
        if (state.hasFlag(CellState.flag)) flagsCounter++;
      }
    }
    if (flagsCounter != number) return;
    for (var i = -1; i < 2; i++) {
      final x = location.x + i;
      for (var j = -1; j < 2; j++) {
        final y = location.y + j;
        final state = field!.getState(Location(x, y));
        if (!state.hasFlag(CellState.flag)) onOpen(Location(x, y));
      }
    }
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
    if (widget.onStart != null) widget.onStart!(bombsCount);
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
      margin: widget.margin,
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
                        final location = Location(j, i);
                        final state =
                            field?.getState(location) ?? CellState.none;
                        if (state.hasFlag(CellState.open) &&
                            !state.hasFlag(CellState.bomb))
                          return NumberButton(
                            number: field!.getOpened(location),
                            onTap: () => onNumberTap(location),
                          );
                        return BlowButton(
                          state: state,
                          onTap: () => onOpen(location),
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
