import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/field_manager.dart';

class SettingsContent extends StatelessWidget {
  final void Function(FieldSize size, int bombsCount) onFieldSizeUpdated;
  final void Function(int count) onBombsCountUpdated;

  final FieldSize fieldSize;
  final int bombsCount;

  const SettingsContent({
    Key? key,
    required this.onFieldSizeUpdated,
    required this.onBombsCountUpdated,
    required this.fieldSize,
    required this.bombsCount,
  }) : super(key: key);

  void setFieldSize(FieldSize size) {
    onFieldSizeUpdated(size, bombsOptions[size]!.first);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Bombs count:'),
        SizedBox(height: 5),
        Container(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, i) {
              final count = bombsOptions[fieldSize]![i];
              return Container(
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 1,
                  ),
                  color: bombsCount == count ? Colors.lightBlue : null,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: EdgeInsets.all(5),
                child: InkWell(
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: bombsCount == count ? Colors.white : null,
                          ),
                    ),
                  ),
                  onTap: () => onBombsCountUpdated(count),
                ),
              );
            },
            itemCount: bombsOptions[fieldSize]!.length,
          ),
        ),
        SizedBox(height: 5),
        Text('Field size:'),
        SizedBox(height: 5),
        Container(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, i) {
              final fieldSize = fieldSizes[i];
              return Container(
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 1,
                  ),
                  color: this.fieldSize == fieldSize ? Colors.lightBlue : null,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: EdgeInsets.all(5),
                child: InkWell(
                  child: Center(
                    child: Text(
                      '${fieldSize.width}x${fieldSize.height}',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: this.fieldSize == fieldSize
                                ? Colors.white
                                : null,
                          ),
                    ),
                  ),
                  onTap: () => setFieldSize(fieldSize),
                ),
              );
            },
            itemCount: fieldSizes.length,
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
