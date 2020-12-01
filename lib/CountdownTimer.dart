import 'package:flutter/material.dart';
import 'EvaluationTimer.dart';

class CountdownTimer extends StatefulWidget {
  CountdownTimer({this.timerDuration, this.eTimer});

  final int timerDuration;

  final EvaluationTimer eTimer;

  void subscribe(void Function() callback) {
    eTimer.subscribe(callback);
  }

  void subscribeCancelEvent(void Function() callback) {
    eTimer.subscribe(callback);
  }

  void init() {
    eTimer.init();
  }

  void cancel() {
    eTimer.cancel();
  }

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with TickerProviderStateMixin {
  AnimationController aController;

  @override
  void initState() {
    super.initState();

    aController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timerDuration),
    );

    aController.forward();

    widget.eTimer.subscribeCancelEvent(() {
      aController.stop();
    });
  }

  @override
  dispose() {
    aController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: aController,
        child: Container(),
        builder: (BuildContext context, Widget child) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: LinearProgressIndicator(
              value: aController.value,
            ),
          );
        });
  }

  void startTimer() {
    aController.forward();
  }
}
