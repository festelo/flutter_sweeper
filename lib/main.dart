import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minesweeper/blow_field.dart';
import 'package:minesweeper/services/field_manager.dart';
import 'package:minesweeper/panels/panel.dart';
import 'package:minesweeper/panels/settings_panel_content.dart';
import 'package:minesweeper/panels/statistic_panel_content.dart';
import 'package:minesweeper/services/game_solver.dart';
import 'package:minesweeper/services/statistic_service.dart';

import 'constants.dart';

void main() async {
  final statisticService = await StatisticService.load();
  runApp(SweeperApp(statisticService: statisticService));
}

class SweeperApp extends StatelessWidget {
  final StatisticService statisticService;

  SweeperApp({Key? key, required this.statisticService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SweeperPage(
        title: 'Tawer\'s Sweeper',
        statisticService: statisticService,
      ),
    );
  }
}

class SweeperPage extends StatefulWidget {
  final String title;
  final StatisticService statisticService;

  SweeperPage({
    Key? key,
    required this.title,
    required this.statisticService,
  }) : super(key: key);

  @override
  _SweeperPageState createState() => _SweeperPageState();
}

class _SweeperPageState extends State<SweeperPage> {
  final GlobalKey<BlowFieldState> fieldKey = GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  StatisticService get statisticService => widget.statisticService;

  FieldSize fieldSize = defaultFieldSize;
  int bombsCount = defaultBombs;
  int? allBombs;
  int? leftBombs;

  void onReset() {
    fieldKey.currentState?.reset();
  }

  void onSolve() {
    final field = fieldKey.currentState?.field;
    if (field == null) return;
    GameSolverService(field).makeTurn();
    fieldKey.currentState?.checkFlags();
    setState(() {
      leftBombs = bombsCount - field.flagsCount;
    });
  }

  void onStart(int bombsCount) {
    final size = fieldKey.currentState?.field?.fieldSize;
    assert(size != null, 'unexpected behavior, size must not be null');
    statisticService.registerGame(size!);
    setState(() {
      allBombs = bombsCount;
      leftBombs = bombsCount;
    });
  }

  void onWin() {
    final size = fieldKey.currentState?.field?.fieldSize;
    assert(size != null, 'unexpected behavior, size must not be null');
    statisticService.registerWin(size!);
    showEndDialog(win: true);
  }

  void onLoose() {
    final size = fieldKey.currentState?.field?.fieldSize;
    assert(size != null, 'unexpected behavior, size must not be null');
    statisticService.registerLoose(size!);
    showEndDialog(win: false);
  }

  void showEndDialog({required bool win}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('You ${win ? 'won' : 'lost'}'),
        content: Text('Press "Reset" button to restart'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Widget verticalLayout() {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(flex: 1),
            Expanded(
              child: Center(
                child: allBombs == null
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 150,
                        height: 30,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'Bombs left: $leftBombs / $allBombs',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BlowField(
                    key: fieldKey,
                    fieldHeight: fieldSize.height,
                    fieldWidth: fieldSize.width,
                    bombsCount: bombsCount,
                    onLoose: onLoose,
                    onWin: onWin,
                    onStart: onStart,
                    onBombsCountUpdated: (left, all) => setState(() {
                      allBombs = all;
                      leftBombs = left;
                    }),
                  ),
                ),
              ),
              flex: 10,
            ),
            Center(
              child: Panel(
                actionText: 'Reset',
                onAction: this.onReset,
                width: 200,
                content: SettingsContent(
                  bombsCount: this.bombsCount,
                  fieldSize: this.fieldSize,
                  onBombsCountUpdated: (c) =>
                      setState(() => this.bombsCount = c),
                  onFieldSizeUpdated: (f, c) => setState(() {
                    this.bombsCount = c;
                    this.fieldSize = f;
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: this.onSolve, child: Text('Solve')),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget horizontalLayout() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.blue,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(
          children: [
            Positioned(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 15,
                        top: 8,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SafeArea(
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (allBombs != null) ...[
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blue, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: 150,
                                height: 30,
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Bombs left: $leftBombs / $allBombs',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        ?.copyWith(color: Colors.blue),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                            Panel(
                              actionText: 'Statistic',
                              expandable: false,
                              content: StatisticContent(
                                statisticService: statisticService,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: BlowField(
                          key: fieldKey,
                          fieldHeight: fieldSize.height,
                          fieldWidth: fieldSize.width,
                          bombsCount: bombsCount,
                          onLoose: onLoose,
                          onWin: onWin,
                          onStart: onStart,
                          onBombsCountUpdated: (left, all) => setState(() {
                            allBombs = all;
                            leftBombs = left;
                          }),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Panel(
                        actionText: 'Reset',
                        onAction: this.onReset,
                        expandable: false,
                        content: SettingsContent(
                          bombsCount: this.bombsCount,
                          fieldSize: this.fieldSize,
                          onBombsCountUpdated: (c) =>
                              setState(() => this.bombsCount = c),
                          onFieldSizeUpdated: (f, c) => setState(() {
                            this.bombsCount = c;
                            this.fieldSize = f;
                          }),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, cnstr) {
        if (cnstr.maxWidth / cnstr.maxHeight <= 16 / 9) {
          return verticalLayout();
        }
        return horizontalLayout();
      },
    );
  }
}
