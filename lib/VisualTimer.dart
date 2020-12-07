import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CallbackTimer.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

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

    if (widget.timerDuration > 0) {
      aController.forward();
    }

    widget.eTimer.init();

    widget.eTimer.subscribeCancelEvent(() {
      aController.stop();
    });
  }

  @override
  dispose() {
    widget.eTimer.cancel();
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
                  children: <Widget>[
                        LinearProgressIndicator(
                          minHeight: 10,
                          value: aController.value,
                        ),
                      ] +
                      ((widget.timerDuration > 0)
                          ? [
                              Positioned(
                                left: (MediaQuery.of(context).size.width / 2) -
                                    35,
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
                                        ))),
                              )
                            ]
                          : [
                              Positioned(
                                  top: -20,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      CupertinoIcons.infinite,
                                      color: Colors.grey[800],
                                      size: 48,
                                    ),
                                  ))
                            ])));
        });
  }

  void startTimer() {
    aController.forward();
  }

  String buildTimerText() {
    int timeLeft =
        (widget.eTimer.getDuration() - widget.eTimer.getElapsedTime());

    int minutesLeft = widget.timerDuration > 0 ? timeLeft ~/ 60 : 0;
    int secondsLeft = widget.timerDuration > 0 ? timeLeft % 60 : 0;

    String timeString;
    if (minutesLeft < 1)
      timeString = secondsLeft.toString();
    else
      timeString = minutesLeft.toString() + ' : ' + secondsLeft.toString();

    return timeString;
  }
}
