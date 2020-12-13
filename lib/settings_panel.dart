import 'package:flutter/material.dart';

import 'manager.dart';

class SettingsPanel extends StatefulWidget {
  final void Function(FieldSize size, int count) onReset;

  static const defaultFieldSize = FieldSize(10, 10);
  static const defaultBombs = 20;

  const SettingsPanel({
    Key? key,
    required this.onReset,
  }) : super(key: key);

  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with TickerProviderStateMixin {
  final bombsOptions = {
    FieldSize(5, 5): [5, 10],
    FieldSize(10, 10): [10, 20, 30],
    FieldSize(15, 15): [20, 30, 40],
  };
  final fieldSizes = [FieldSize(5, 5), FieldSize(10, 10), FieldSize(15, 15)];
  late FieldSize selectedFieldSize;
  late int selectedBombs;

  bool expanded = false;

  late AnimationController _controller;
  late Animation<double> _heightTransition;

  final animationsDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    selectedFieldSize = SettingsPanel.defaultFieldSize;
    selectedBombs = SettingsPanel.defaultBombs;

    _controller = AnimationController(
      duration: animationsDuration,
      vsync: this,
    );
    _heightTransition = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  void setExpanded(bool val) {
    if (val) {
      _controller.forward(from: _controller.value);
    } else {
      _controller.reverse(from: _controller.value);
    }
    setState(() => expanded = val);
  }

  void setFieldSize(FieldSize size) {
    setState(() {
      selectedFieldSize = size;
      selectedBombs = bombsOptions[selectedFieldSize]!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedSize(
        vsync: this,
        duration: animationsDuration,
        curve: Curves.easeInOutCubic,
        child: SizedBox(
          width: expanded ? 220 : 170,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 35,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Row(
                          children: [
                            SizedBox(width: 35),
                            Expanded(
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  'Reset',
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      ?.copyWith(color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () =>
                            widget.onReset(selectedFieldSize, selectedBombs),
                      ),
                    ),
                    SizedBox(
                      width: 35,
                      child: InkWell(
                        child: Center(
                          child: Icon(
                            Icons.settings,
                            color: Colors.blue,
                            size: 17,
                          ),
                        ),
                        onTap: () => setExpanded(!expanded),
                      ),
                    )
                  ],
                ),
              ),
              AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 300),
                child: SizeTransition(
                  sizeFactor: _heightTransition,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bombs count:'),
                      SizedBox(height: 5),
                      Container(
                        height: 35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) {
                            final count = bombsOptions[selectedFieldSize]![i];
                            return Container(
                              width: 35,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueAccent,
                                  width: 1,
                                ),
                                color: selectedBombs == count
                                    ? Colors.lightBlue
                                    : null,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              margin: EdgeInsets.all(5),
                              child: InkWell(
                                child: Center(
                                  child: Text(
                                    count.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.copyWith(
                                          color: selectedBombs == count
                                              ? Colors.white
                                              : null,
                                        ),
                                  ),
                                ),
                                onTap: () =>
                                    setState(() => selectedBombs = count),
                              ),
                            );
                          },
                          itemCount: bombsOptions[selectedFieldSize]!.length,
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
                                color: selectedFieldSize == fieldSize
                                    ? Colors.lightBlue
                                    : null,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              margin: EdgeInsets.all(5),
                              child: InkWell(
                                child: Center(
                                  child: Text(
                                    '${fieldSize.width}x${fieldSize.height}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.copyWith(
                                          color: selectedFieldSize == fieldSize
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
