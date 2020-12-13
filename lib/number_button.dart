import 'package:flutter/material.dart';

class NumberButton extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const NumberButton({
    Key? key,
    required this.number,
    required this.onTap,
  }) : super(key: key);

  static get fillColor => <int, Color>{
        8: Colors.tealAccent,
        7: Colors.teal,
        6: Colors.teal.shade300,
        5: Colors.cyan,
        4: Colors.orange.shade300,
        3: Colors.yellow,
        2: Colors.green.shade300,
        1: Colors.grey.shade300,
        0: Colors.grey.shade200,
      };

  static const fontColor = <int, Color>{
    8: Colors.white,
    7: Colors.white,
    6: Colors.white,
    5: Colors.white,
    4: Colors.black45,
    3: Colors.black45,
    2: Colors.white,
    1: Colors.black45,
    0: Colors.transparent,
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: fillColor[number] ?? Colors.black,
        ),
        margin: EdgeInsets.all(1),
        child: InkWell(
          child: Center(
            child: Text(
              number.toString(),
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: fontColor[number],
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
