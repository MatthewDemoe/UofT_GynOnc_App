import 'package:flutter/material.dart';
import 'CallbackTimer.dart';
import 'package:bordered_text/bordered_text.dart';

class VisualTimer extends StatefulWidget {
  VisualTimer({this.timerDuration, this.eTimer});

  final int timerDuration;

  final CallbackTimer eTimer;

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
  _VisualTimerState createState() => _VisualTimerState();
}

class _VisualTimerState extends State<VisualTimer>
    with TickerProviderStateMixin {
  AnimationController aController;

  @override
  void initState() {
    super.initState();

    aController = AnimationController(
      vsync: this,
      duration: Duration(minutes: widget.timerDuration),
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
              child: Stack(
                  alignment: Alignment.center,
                  overflow: Overflow.visible,
                  children: [
                    LinearProgressIndicator(
                      minHeight: 10,
                      value: aController.value,
                    ),
                    Positioned(
                      left: (MediaQuery.of(context).size.width / 2) - 35,
                      child: Container(
                        constraints: BoxConstraints(minHeight: 25),
                        height: 25,
                        alignment: Alignment.center,
                        child: BorderedText(
                            strokeWidth: 3,
                            strokeColor: Colors.black,
                            child: Text(
                              buildTimerText(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            )),
                      ),
                    )
                  ]));
        });
  }

  void startTimer() {
    aController.forward();
  }

  String buildTimerText() {
    int timeLeft =
        (widget.eTimer.getDuration() - widget.eTimer.getElapsedTime());

    int minutesLeft = timeLeft ~/ 60;
    int secondsLeft = timeLeft % 60;

    String timeString;
    if (minutesLeft < 1)
      timeString = secondsLeft.toString();
    else
      timeString = minutesLeft.toString() + ' : ' + secondsLeft.toString();

    return timeString;
  }
}
