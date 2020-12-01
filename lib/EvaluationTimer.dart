import 'package:event/event.dart';
import 'dart:async';

class EvaluationTimer {
  EvaluationTimer({int durationSeconds}) {
    _timerDuration = durationSeconds;
  }

  int _elapsedTime = 0;
  int _timerDuration = 0;
  Timer _timer;
  final _callbackEvent = new Event();
  final _cancelEvent = new Event();

  void init() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => updateTimer());
  }

  void updateTimer() {
    _elapsedTime += 1;

    if (_elapsedTime >= _timerDuration) {
      print('BROADCASTING EVENT');
      _callbackEvent.broadcast();

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
}
