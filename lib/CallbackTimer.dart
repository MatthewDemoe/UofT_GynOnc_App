import 'package:event/event.dart';
import 'dart:async';

class CallbackTimer {
  CallbackTimer({int durationSeconds}) {
    _timerDuration = durationSeconds;
  }

  int _elapsedTime = 0;
  int _timerDuration = 0;
  Timer _timer;
  final _callbackEvent = new Event();
  final _cancelEvent = new Event();

  void init() {
    _timer = Timer.periodic(Duration(seconds: 1),
        (timer) => (_timerDuration > 0) ? updateTimer() : null);
  }

  //Called every second
  void updateTimer() {
    //increment elapsed time variable
    _elapsedTime += 1;

    //If we've reached the correct amount of time, cancel the timer, and broadcast that the timer is done
    if (_elapsedTime >= _timerDuration) {
      _callbackEvent.broadcast();

      _timer.cancel();
    }
  }

  //External function to subscribe to the local event that will call when the timer completes
  void subscribe(void Function() callback) {
    _callbackEvent.subscribe((args) {
      callback();
    });
  }

  //External function to subscribe to the event that will call when the timer is cancelled
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
