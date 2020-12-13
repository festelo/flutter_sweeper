import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper/blow_field.dart';

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
  int? allBombs;
  int? leftBombs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(flex: 1),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 150,
                  height: 30,
                  child: InkWell(
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
                    onTap: () => fieldKey.currentState?.reset(),
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
                    onBombsCountUpdated: (left, all) => setState(() {
                      allBombs = all;
                      leftBombs = left;
                    }),
                  ),
                ),
              ),
              flex: 10,
            ),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 150,
                  height: 30,
                  child: InkWell(
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
                    onTap: () => fieldKey.currentState?.reset(),
                  ),
                ),
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
