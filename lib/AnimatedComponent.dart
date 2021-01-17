import 'package:flutter/material.dart';
import 'package:event/event.dart';

class AnimatedComponent extends StatefulWidget {
  AnimatedComponent({Key key, this.child}) : super(key: key);

  final Widget child;
  final int duration = 1;

  final Event transitionEvent = new Event();
  final Event transitionCompleteEvent = new Event();

  void transition({Function whenComplete}) {
    transitionEvent.broadcast();

    transitionCompleteEvent.subscribe((args) {
      print(
          '---------------------TRANSITION COMPLETE--------------------------');
      whenComplete();
    });
  }

  @override
  _AnimatedComponentState createState() => _AnimatedComponentState();
}

class _AnimatedComponentState extends State<AnimatedComponent>
    with TickerProviderStateMixin {
  AnimationController _aController;
  Animation<Offset> _rightInAnimation;

  @override
  void initState() {
    _aController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );

    _rightInAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: Offset(1.25, 0.0),
    ).animate(CurvedAnimation(
      parent: _aController,
      curve: Curves.easeInOut,
    ));

    _aController.addStatusListener((status) {
      if ((status == AnimationStatus.dismissed) ||
          (status == AnimationStatus.completed)) {
        widget.transitionCompleteEvent.broadcast();

        widget.transitionCompleteEvent.unsubscribeAll();

        _aController.reset();
        _aController.forward();
      }
    });

    widget.transitionEvent.subscribe((args) {
      if ((_aController.status != AnimationStatus.reverse) ||
          (_aController.status != AnimationStatus.forward)) {
        print('------------------STARTING TRANSITION---------------------');
        _aController.reverse();
      }
    });

    _aController.reset();
    _aController.forward();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _aController.reset();
    _aController.forward();
    return SlideTransition(
      position: _rightInAnimation,
      child: widget.child,
    );
  }
}
