import 'package:minesweeper/services/field_manager.dart';
import 'package:rxdart/rxdart.dart';

class StatisticService {
  final BehaviorSubject<Map<FieldSize, int>> winsCount;
  final BehaviorSubject<Map<FieldSize, int>> loosesCount;
  final BehaviorSubject<Map<FieldSize, int>> gamesCount;

  StatisticService({
    required Map<FieldSize, int> winsCount,
    required Map<FieldSize, int> loosesCount,
    required Map<FieldSize, int> gamesCount,
  })   : winsCount = BehaviorSubject.seeded(winsCount),
        loosesCount = BehaviorSubject.seeded(loosesCount),
        gamesCount = BehaviorSubject.seeded(gamesCount);

  static Future<StatisticService> load() async {
    final wins = <FieldSize, int>{};
    final games = <FieldSize, int>{};
    final looses = <FieldSize, int>{};
    return StatisticService(
      winsCount: wins,
      loosesCount: looses,
      gamesCount: games,
    );
  }

  void _increaseSubject(
      BehaviorSubject<Map<FieldSize, int>> subject, FieldSize size) {
    subject.add({...subject.value, size: (subject.value[size] ?? 0) + 1});
  }

  void registerWin(FieldSize size) {
    _increaseSubject(winsCount, size);
  }

  void registerLoose(FieldSize size) {
    _increaseSubject(loosesCount, size);
  }

  void registerGame(FieldSize size) {
    _increaseSubject(gamesCount, size);
  }
}
