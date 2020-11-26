import 'package:flutter/material.dart';
import 'HelperFunctions.dart';
import 'EvaluationBottomSheet.dart';

class EvaluationFAB extends StatefulWidget {
  @override
  _EvaluationFABState createState() => _EvaluationFABState();
}

class _EvaluationFABState extends State<EvaluationFAB> {
  bool showFab = true;

  @override
  Widget build(BuildContext context) {
    return showFab
        ? FloatingActionButton(
            backgroundColor: getAppColor(),
            child: Icon(Icons.timer, color: Colors.white),
            onPressed: () {
              var bottomSheetController = showBottomSheet(
                  context: context,
                  builder: (context) => EvaluationBottomSheet());

              showFloatingActionButton(false);

              bottomSheetController.closed.then((value) {
                showFloatingActionButton(true);
              });
            },
          )
        : Container();
  }

  void showFloatingActionButton(bool val) {
    setState(() {
      showFab = val;
    });
  }
}
