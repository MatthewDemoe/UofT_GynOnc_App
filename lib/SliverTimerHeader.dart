import 'package:flutter/material.dart';
import 'VisualTimer.dart';

class SliverTimerHeader extends SliverPersistentHeaderDelegate {
  SliverTimerHeader(VisualTimer timer) {
    _timer = timer;
  }

  VisualTimer _timer;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.75,
        child: _timer,
      );
    });
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;
}
