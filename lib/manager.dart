import 'package:quiver/core.dart';

class Location {
  final x;
  final y;

  Location(this.x, this.y);

  bool operator ==(o) => o is Location && x == o.x && y == o.y;
  int get hashCode => hash2(x.hashCode, y.hashCode);
}

class CellState {
  static const CellState none = CellState(0);
  static const CellState bomb = CellState(1);
  static const CellState open = CellState(2);
  static const CellState flag = CellState(4);

  final int val;
  const CellState(this.val);

  CellState operator &(CellState o) => CellState(val & o.val);
  CellState operator |(CellState o) => CellState(val | o.val);
  CellState operator ~() => CellState(~val);

  bool operator ==(o) {
    if (o is int) return val == o;
    if (o is CellState) return val == o.val;
    return false;
  }

  int get hashCode => val.hashCode;

  bool hasFlag(CellState state) {
    return this & state != 0;
  }
}

class FieldManager {
  Map<Location, CellState> _states;
  final int fieldWidth;
  final int fieldHeight;
  final Map<Location, int> _opened = {};

  FieldManager(this._states, this.fieldWidth, this.fieldHeight);

  bool inside(Location location) {
    return location.x >= 0 &&
        location.y >= 0 &&
        location.x < fieldWidth &&
        location.y < fieldHeight;
  }

  CellState getState(Location location) {
    return _states[location] ?? CellState.none;
  }

  int getOpened(Location location) {
    return _opened[location] ?? 0;
  }

  void _openOk(Location location) {
    final currentState = getState(location);
    if (currentState.hasFlag(CellState.open)) return;
    _states[location] = currentState | CellState.open;
    var counter = 0;
    for (var i = -1; i < 2; i++) {
      final x = location.x + i;
      for (var j = -1; j < 2; j++) {
        final y = location.y + j;
        if (getState(Location(x, y)).hasFlag(CellState.bomb)) {
          counter++;
        }
      }
    }
    if (counter == 0) {
      for (var i = -1; i < 2; i++) {
        final x = location.x + i;
        for (var j = -1; j < 2; j++) {
          final y = location.y + j;
          if (i == 0 && j == 0) continue;
          final newLocation = Location(x, y);
          if (inside(newLocation)) _openOk(Location(x, y));
        }
      }
    }
    _opened[location] = counter;
  }

  void _openBomb(Location location) {
    for (var i = 0; i < fieldHeight; i++)
      for (var j = 0; j < fieldWidth; j++) {
        final location = Location(j, i);
        final state = getState(location);
        if (state.hasFlag(CellState.bomb))
          _states[location] = getState(location) | CellState.open;
      }
  }

  bool open(Location location) {
    final currentState = getState(location);
    if (currentState.hasFlag(CellState.open)) return true;
    if (currentState.hasFlag(CellState.bomb)) {
      _openBomb(location);
      return false;
    } else {
      _openOk(location);
      return true;
    }
  }

  void flag(Location location) {
    final currentState = getState(location);
    _states[location] = currentState | CellState.flag;
  }

  void unflag(Location location) {
    final currentState = getState(location);
    _states[location] = currentState & ~CellState.flag;
  }

  bool checkFlags() {
    for (final s in _states.values) {
      if (s.hasFlag(CellState.bomb) && !s.hasFlag(CellState.flag)) return false;
    }
    return true;
  }
}
