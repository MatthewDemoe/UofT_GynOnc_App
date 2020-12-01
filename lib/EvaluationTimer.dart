import 'package:event/event.dart';
//import 'package:flutter/material.dart';

import 'dart:async';

//import 'package:pausable_timer/pausable_timer.dart';

class EvaluationTimer {
  EvaluationTimer({int duration}) {
    _timerDuration = duration;
  }

  int _elapsedTime = 0;
  int _timerDuration = 0;
  Timer _timer;
  final _callbackEvent = new Event<EvaluationEventArgs>();
  final _cancelEvent = new Event<EvaluationEventArgs>();

  void init() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => updateTimer());
  }

  void updateTimer() {
    _elapsedTime += 1;

    //print('In Timer: ' + getPercent().toString());

    if (_elapsedTime >= _timerDuration) {
      print('BROADCASTING EVENT');
      _callbackEvent.broadcast(EvaluationEventArgs());

      _timer.cancel();
    }
  }

  void subscribe(void Function() callback) {
    _callbackEvent.subscribe((args) {
      callback();
    });
  }

  void subscribeCancelEvent(void Function() callback) {
    _cancelEvent.subscribe((args) {
      callback();
    });
  }

  int getElapsedTime() {
    return _elapsedTime;
  }

  int getDuration() {
    return _timerDuration;
  }

  double getPercent() {
    return (_elapsedTime.toDouble() / _timerDuration.toDouble());
  }

  void cancel() {
    _cancelEvent.broadcast();

    _timer.cancel();
  }

  /* @override
  _EvaluationTimerState createState() => _EvaluationTimerState();*/
}

/*class _EvaluationTimerState extends State<EvaluationTimer> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}*/

class EvaluationEventArgs extends EventArgs {
  EvaluationEventArgs();
}
