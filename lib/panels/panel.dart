import 'package:flutter/material.dart';

class Panel extends StatefulWidget {
  final void Function()? onAction;
  final bool expandable;
  final Widget content;
  final String actionText;
  final double? width;

  const Panel({
    Key? key,
    required this.actionText,
    required this.content,
    this.expandable = true,
    this.onAction,
    this.width,
  }) : super(key: key);

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> with TickerProviderStateMixin {
  bool expanded = false;

  late AnimationController _controller;
  late Animation<double> _heightTransition;

  final animationsDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: animationsDuration,
      vsync: this,
    );

    _heightTransition = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    if (!widget.expandable) {
      _controller.animateTo(1);
    }
  }

  void setExpanded(bool val) {
    if (val) {
      _controller.forward(from: _controller.value);
    } else {
      _controller.reverse(from: _controller.value);
    }
    setState(() => expanded = val);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      width: widget.width,
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
                        if (widget.expandable) SizedBox(width: 35),
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              widget.actionText,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: widget.onAction,
                  ),
                ),
                if (widget.expandable)
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
              child: widget.content,
            ),
          ),
        ],
      ),
    );
  }
}
