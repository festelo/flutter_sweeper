import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/blow_field.dart';
import 'package:minesweeper/manager.dart';
import 'package:minesweeper/settings_panel.dart';

void main() {
  runApp(SweeperApp());
}

class SweeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SweeperPage(title: 'Tawer\'s Sweeper'),
    );
  }
}

class SweeperPage extends StatefulWidget {
  SweeperPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SweeperPageState createState() => _SweeperPageState();
}

class _SweeperPageState extends State<SweeperPage> {
  final GlobalKey<BlowFieldState> fieldKey = GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  FieldSize fieldSize = SettingsPanel.defaultFieldSize;
  int bombsCount = SettingsPanel.defaultBombs;
  int? allBombs;
  int? leftBombs;

  void onReset(FieldSize fieldSize, int bombsCount) {
    setState(() {
      this.fieldSize = fieldSize;
      this.bombsCount = bombsCount;
    });
    fieldKey.currentState?.reset();
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

  @override
  Widget build(BuildContext context) {
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
                    onLoose: () => showEndDialog(win: false),
                    onWin: () => showEndDialog(win: true),
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
              child: SettingsPanel(
                onReset: onReset,
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
