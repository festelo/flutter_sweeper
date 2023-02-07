import 'package:minesweeper/services/field_manager.dart';

class GameSolverService {
  final FieldManager fieldManager;
  GameSolverService(this.fieldManager);

  int setFlags() {
    var actions = 0;
    var globalActions = 0;
    do {
      globalActions += actions;
      actions = 0;
      for (var i = 0; i < fieldManager.fieldHeight; i++) {
        for (var j = 0; j < fieldManager.fieldWidth; j++) {
          final location = Location(j, i);
          final state = fieldManager.getState(location);
          final bombsNear = fieldManager.getOpened(location);

          final freeCells = <Location>[];
          if (!state.hasFlag(CellState.open) || bombsNear == 0) continue;

          for (var a = -1; a < 2; a++) {
            for (var b = -1; b < 2; b++) {
              final nearLocation = Location(j + a, i + b);
              if (nearLocation == location) continue;
              final nearState = fieldManager.getState(nearLocation);
              if (!nearState.hasFlag(CellState.open)) {
                freeCells.add(nearLocation);
              }
            }
          }

          if (freeCells.length == bombsNear) {
            for (final cell in freeCells) {
              final state = fieldManager.getState(cell);
              if (!state.hasFlag(CellState.flag)) {
                fieldManager.flag(cell);
                actions++;
              }
            }
          }
        }
      }
    } while (actions != 0);
    return globalActions;
  }

  int openCells() {
    var actions = 0;
    var globalActions = 0;
    do {
      globalActions += actions;
      actions = 0;
      for (var i = 0; i < fieldManager.fieldHeight; i++) {
        for (var j = 0; j < fieldManager.fieldWidth; j++) {
          final location = Location(j, i);
          final state = fieldManager.getState(location);
          final bombsNear = fieldManager.getOpened(location);

          final flagCells = <Location>[];
          if (!state.hasFlag(CellState.open) || bombsNear == 0) continue;

          for (var a = -1; a < 2; a++) {
            for (var b = -1; b < 2; b++) {
              final nearLocation = Location(j + a, i + b);
              if (nearLocation == location) continue;
              final nearState = fieldManager.getState(nearLocation);
              if (!nearState.hasFlag(CellState.open) &&
                  nearState.hasFlag(CellState.flag)) {
                flagCells.add(nearLocation);
              }
            }
          }

          if (flagCells.length == bombsNear) {
            for (var i = -1; i < 2; i++) {
              final x = location.x + i;
              for (var j = -1; j < 2; j++) {
                final y = location.y + j;
                final nearLocation = Location(x, y);
                final state = fieldManager.getState(nearLocation);
                if (!state.hasFlag(CellState.flag) &&
                    !state.hasFlag(CellState.open)) {
                  fieldManager.open(nearLocation);
                  actions++;
                }
              }
            }
          }
        }
      }
    } while (actions != 0);
    return globalActions;
  }

  void makeTurn() {
    var actions = 0;
    do {
      actions = 0;
      actions += setFlags();
      actions += openCells();
    } while (actions != 0);
  }
}
