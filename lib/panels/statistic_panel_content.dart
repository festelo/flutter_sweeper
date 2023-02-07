import 'package:flutter/material.dart';
import 'package:minesweeper/constants.dart';
import 'package:minesweeper/services/field_manager.dart';
import 'package:minesweeper/services/statistic_service.dart';

class StatisticContent extends StatelessWidget {
  final StatisticService statisticService;

  const StatisticContent({
    Key? key,
    required this.statisticService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<Map<FieldSize, int>>(
          initialData: statisticService.winsCount.value,
          stream: statisticService.winsCount,
          builder: (ctx, snap) {
            final winsCount = snap.data ?? {};
            return StreamBuilder<Map<FieldSize, int>>(
              initialData: statisticService.loosesCount.value,
              stream: statisticService.loosesCount,
              builder: (ctx, snap) {
                final loosesCount = snap.data ?? {};
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Table(
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Size',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ),
                          for (final size in fieldSizes)
                            TableCell(
                              child: Text(
                                '${size.width}x${size.height}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Win',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ),
                          for (final size in fieldSizes)
                            TableCell(
                              child: Text(
                                (winsCount[size] ?? 0).toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Loose',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ),
                          for (final size in fieldSizes)
                            TableCell(
                              child: Text(
                                (loosesCount[size] ?? 0).toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
